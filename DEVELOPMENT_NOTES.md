# Development Notes — ShipFlow

## AI Tooling Used

### Cursor / GitHub Copilot
- Generated initial migration boilerplate for all 4 tables
- Suggested composite index on `(origin_country, destination_country)` after reviewing query patterns
- Auto-completed Filament Resource column/filter definitions
- Generated PHPUnit test stubs for PackageService status transition logic

### Before/After: Query Optimization Example

**Before (N+1 problem):**
```php
$packages = Package::all();
foreach ($packages as $package) {
    echo $package->warehouse->name; // hits DB on every iteration
}
```

**After (Eager loading — suggested by Copilot):**
```php
$packages = Package::with(['warehouse', 'logs'])->paginate(20);
```

---

## MySQL EXPLAIN Output

Query: Find all in_sorting packages for US→HK route
```sql
EXPLAIN SELECT * FROM packages
WHERE status = 'in_sorting'
AND origin_country = 'US'
AND destination_country = 'HK';
```

Result: Uses `idx_origin_dest` composite index — type: `ref`, rows examined: ~12 (not full scan).

---

## Key Business Logic Decisions

### Status Forward-Only Validation
```php
// PackageService.php
private const STATUS_ORDER = [
    'pending', 'received_overseas', 'in_sorting',
    'dispatched', 'out_for_delivery', 'delivered'
];

public function canTransition(string $from, string $to): bool
{
    $fromIndex = array_search($from, self::STATUS_ORDER);
    $toIndex   = array_search($to, self::STATUS_ORDER);
    return $toIndex > $fromIndex;
}
```

### SQS Job Retry Strategy
- 3 max attempts
- Exponential backoff: 10s, 30s, 60s
- `failed()` method logs to CloudWatch + alerts ops team
- Dead Letter Queue configured in SQS for permanently failed jobs

### S3 Invoice Security
- Bucket ACL: private (no public access)
- Signed URLs expire in 30 minutes
- Only `super_admin` and `warehouse_manager` can request invoice URLs
- S3 path stored in DB: `invoices/{package_id}/{timestamp}.pdf`
