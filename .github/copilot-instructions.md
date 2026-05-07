# ShipFlow – GitHub Copilot Instructions
# Laravel Internal Logistics Operations System (BuyandShip demo project)

## Project Overview
ShipFlow is a pure internal B2B backend system simulating BuyandShip's
global warehouse and fulfillment operations. No public customer registration.
All users are internal staff (warehouse staff, sorting staff, admins, 3PL operators).

## Tech Stack
- Laravel 11 / PHP 8.2+
- MySQL 8.0 (local Docker) → AWS RDS (production)
- Redis (local queue) → AWS SQS (production)
- Local disk (local storage) → AWS S3 (production)
- Laravel Sanctum (API token auth)
- Filament v3 (admin panel)
- Livewire + Alpine.js (minimal — Filament handles most UI)
- Docker Compose (local dev)
- EC2 + Nginx + Supervisor (production)

## Architecture Rules
- Keep API controllers thin — business logic goes in app/Services/
- Every package status change MUST create a shipment_log record (use Model observer)
- Every status change MUST dispatch a SQS job (non-blocking)
- Staff can only see packages in their assigned warehouse (use Eloquent Global Scope)
- Status can only move FORWARD — never backward (validate in PackageService)
- Store only S3 path in DB, never full URLs
- Use API Resources for ALL JSON responses — never return raw Eloquent models
- Use Form Requests for ALL input validation

## Folder Conventions
- app/Http/Controllers/Api/V1/     → API controllers (JSON responses only)
- app/Http/Controllers/Web/        → Blade/Filament web controllers
- app/Jobs/                        → SQS async jobs
- app/Services/                    → Business logic layer
- app/Models/                      → Eloquent models
- app/Filament/Resources/          → Filament admin resources
- app/Http/Requests/               → Form Request validation classes
- app/Http/Resources/              → API Resource classes
- app/Observers/                   → Model observers

## Naming Conventions
- Models: singular PascalCase (Package, ShipmentLog, Warehouse)
- Controllers: plural PascalCase + Controller (PackagesController)
- Jobs: descriptive + Job suffix (ShipmentStatusUpdatedJob)
- Services: descriptive + Service suffix (PackageService)
- Migrations: snake_case descriptive (create_packages_table)
- Requests: action + model + Request (StorePackageRequest, UpdatePackageStatusRequest)
- Resources: model + Resource (PackageResource, ShipmentLogResource)

## User Roles (ENUM)
super_admin, warehouse_manager, warehouse_staff, sorting_staff, api_operator

## Package Status Flow (ENUM — forward only, never backward)
pending → received_overseas → in_sorting → dispatched → out_for_delivery → delivered

## Key Business Rules
1. Status update → auto-insert shipment_log → dispatch ShipmentStatusUpdatedJob to SQS
2. Status = delivered → dispatch InvoiceGenerationJob to SQS → PDF → upload to S3
3. warehouse_staff/sorting_staff can only update packages in their assigned warehouse
4. api_operator role: POST /api/v1/webhooks/3pl only
5. Invoice S3 URL must be signed temporary URL (30 min expiry) — never public ACL
6. Jobs must have $tries = 3 and $backoff = [10, 30, 60]
7. Jobs must implement failed() method with Log::error()

## API Route Conventions
- All API routes prefixed: /api/v1/
- Auth routes: /api/v1/auth/*
- Resource routes: /api/v1/packages, /api/v1/warehouses
- Admin routes: /api/v1/admin/* (requires role:admin middleware)
- Webhook routes: /api/v1/webhooks/*

## Local Dev Environment
- QUEUE_CONNECTION=redis (swap to sqs in production)
- FILESYSTEM_DISK=local (swap to s3 in production)
- MAIL_MAILER=log (swap to ses/mailgun in production)
- docker compose up -d
- docker compose exec app php artisan migrate --seed
- docker compose exec app php artisan queue:work redis
