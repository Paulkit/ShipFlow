# ShipFlow 🚚

> Internal Laravel logistics operations backend — built as a portfolio demo for BuyandShip.

ShipFlow is a **pure internal B2B system** used by warehouse staff, sorting centre operators,
and 3PL integrations to manage the end-to-end journey of a parcel from an overseas warehouse
to the recipient's doorstep.

---

## Tech Stack

| Layer         | Local Dev         | AWS Production     |
|---------------|-------------------|--------------------|
| App Server    | Docker + Nginx    | EC2 + Nginx        |
| Database      | MySQL 8 (Docker)  | RDS MySQL          |
| Queue         | Redis             | SQS                |
| File Storage  | Local disk        | S3                 |
| Admin Panel   | Filament v3       | Filament v3        |
| Auth          | Laravel Sanctum   | Laravel Sanctum    |

---

## Package Status Flow

```
pending → received_overseas → in_sorting → dispatched → out_for_delivery → delivered
```

Every status transition:
1. Creates an immutable `shipment_log` record (who changed it, when, from where)
2. Dispatches a SQS job to send email notification to recipient
3. On `delivered`: generates PDF invoice → uploads to S3

---

## User Roles

| Role               | Access                                          |
|--------------------|-------------------------------------------------|
| super_admin        | Full system access                              |
| warehouse_manager  | Manage own warehouse packages + staff           |
| warehouse_staff    | Update status for packages in own warehouse     |
| sorting_staff      | Update status at sorting centre                 |
| api_operator       | 3PL webhook integration (API only)              |

---

## Local Development Setup

### Prerequisites
- Docker Desktop
- PHP 8.2+ & Composer (for artisan commands outside Docker)

### Steps

```bash
git clone https://github.com/yourname/shipflow.git
cd shipflow
cp .env.example .env
docker compose up -d
docker compose exec app composer install
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate --seed
docker compose exec app php artisan queue:work redis
```

Visit: http://localhost:8080/admin
Admin login: admin@shipflow.test / password

---

## API Endpoints

### Auth
```
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
```

### Packages
```
GET    /api/v1/packages                  List packages (scoped to your warehouse)
POST   /api/v1/packages                  Register new incoming package
GET    /api/v1/packages/{tracking}       Lookup by tracking number
PATCH  /api/v1/packages/{id}/status      Update status (triggers SQS job)
GET    /api/v1/packages/{id}/logs        Full shipment audit trail
GET    /api/v1/packages/{id}/invoice     Signed S3 URL (30 min expiry)
```

### Warehouses
```
GET    /api/v1/warehouses                List active warehouses
```

### 3PL Webhook
```
POST   /api/v1/webhooks/3pl             Receive status update from DHL/FedEx/SF Express
```

---

## Key Design Decisions

### MySQL Indexes
- `packages.tracking_number` — unique index for O(1) lookups
- `packages.(status)` — for status-based filtering
- `packages.(origin_country, destination_country)` — for route reporting
- `shipment_logs.(package_id)` — for audit trail queries
See `DEVELOPMENT_NOTES.md` for EXPLAIN query output.

### Why SQS?
Status updates are high-frequency. Dispatching email + PDF generation synchronously
would block the API response. SQS decouples these operations — the API returns instantly,
jobs process in the background with 3 retries + exponential backoff.

### Why Filament?
Internal admin panel for warehouse managers. Auto-generates CRUD UI from Eloquent models.
Warehouse-scoped data via Eloquent Global Scopes — staff only see their own warehouse packages.

---

## AWS Architecture

```
[Staff / 3PL System]
        │
        ▼
[EC2 — Laravel API + Filament Admin (Nginx + PHP-FPM)]
        │
   ┌────┴──────────────────────┐
   ▼                           ▼
[RDS MySQL]              [SQS Queue]
                               │
                    ┌──────────┴───────────┐
                    ▼                      ▼
         ShipmentStatusUpdatedJob   InvoiceGenerationJob
                    │                      │
               Send email              Generate PDF
                                           │
                                       Upload to [S3]
```

---

## Development Notes
See `DEVELOPMENT_NOTES.md` for:
- How Cursor/Copilot was used during development
- MySQL EXPLAIN query screenshots
- Performance decisions

---

## Local Postman Collection
Import `shipflow.postman_collection.json` to test all endpoints.
