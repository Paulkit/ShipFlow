# ShipFlow — Artisan Commands Cheatsheet

## Initial Setup
composer create-project laravel/laravel shipflow
cd shipflow
composer require filament/filament
php artisan filament:install --panels
php artisan install:api
php artisan queue:failed-table
php artisan migrate

## Generate Models + Migrations
php artisan make:model Warehouse -m
php artisan make:model Package -mf          # -f creates Factory too
php artisan make:model ShipmentLog -m
php artisan make:model ThirdPartyProvider -m

## Generate Filament Resources (auto-builds CRUD admin UI)
php artisan make:filament-resource Package --generate
php artisan make:filament-resource Warehouse --generate
php artisan make:filament-resource User --generate

## Generate API Controllers
php artisan make:controller Api/V1/AuthController
php artisan make:controller Api/V1/PackageController --api
php artisan make:controller Api/V1/WarehouseController --api
php artisan make:controller Api/V1/WebhookController

## Generate Form Requests
php artisan make:request Api/StorePackageRequest
php artisan make:request Api/UpdatePackageStatusRequest
php artisan make:request Api/WebhookRequest

## Generate API Resources
php artisan make:resource PackageResource
php artisan make:resource PackageCollection
php artisan make:resource ShipmentLogResource

## Generate Jobs (SQS)
php artisan make:job ShipmentStatusUpdatedJob
php artisan make:job InvoiceGenerationJob

## Generate Mail
php artisan make:mail ShipmentStatusUpdatedMail

## Generate Services (manual — no artisan command)
# Create manually: app/Services/PackageService.php
# Create manually: app/Services/InvoiceService.php

## Generate Seeders
php artisan make:seeder WarehouseSeeder
php artisan make:seeder UserSeeder
php artisan make:seeder PackageSeeder

## Database
php artisan migrate                          # run migrations
php artisan migrate:fresh --seed             # wipe + reseed (dev only)
php artisan db:seed --class=WarehouseSeeder  # run specific seeder

## Daily Dev
php artisan serve                            # local server (if not using Docker)
php artisan queue:work redis                 # process jobs locally
php artisan route:list --path=api            # list all API routes
php artisan cache:clear                      # clear cache
php artisan config:clear                     # clear config cache
php artisan view:clear                       # clear compiled views
php artisan optimize                         # cache everything for production
