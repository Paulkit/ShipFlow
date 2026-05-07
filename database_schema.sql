-- ShipFlow Database Schema
-- Run this for reference only — use Laravel migrations in actual project

CREATE TABLE users (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(150) UNIQUE NOT NULL,
    password        VARCHAR(255) NOT NULL,
    role            ENUM('super_admin','warehouse_manager','warehouse_staff','sorting_staff','api_operator') NOT NULL,
    warehouse_id    BIGINT UNSIGNED NULL,
    is_active       TINYINT(1) DEFAULT 1,
    created_at      TIMESTAMP NULL,
    updated_at      TIMESTAMP NULL
);

CREATE TABLE warehouses (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    country     CHAR(2) NOT NULL,
    type        ENUM('overseas','sorting','redemption') NOT NULL,
    address     TEXT NULL,
    is_active   TINYINT(1) DEFAULT 1,
    created_at  TIMESTAMP NULL,
    updated_at  TIMESTAMP NULL
);

CREATE TABLE packages (
    id                      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tracking_number         VARCHAR(100) UNIQUE NOT NULL,
    current_warehouse_id    BIGINT UNSIGNED NULL,
    status                  ENUM('pending','received_overseas','in_sorting','dispatched','out_for_delivery','delivered') DEFAULT 'pending',
    weight_kg               DECIMAL(8,2),
    declared_value          DECIMAL(10,2),
    origin_country          CHAR(2),
    destination_country     CHAR(2),
    recipient_name          VARCHAR(150),
    recipient_email         VARCHAR(150),
    recipient_phone         VARCHAR(50),
    invoice_s3_path         VARCHAR(500) NULL,
    created_at              TIMESTAMP NULL,
    updated_at              TIMESTAMP NULL,
    deleted_at              TIMESTAMP NULL,

    FOREIGN KEY (current_warehouse_id) REFERENCES warehouses(id),
    INDEX idx_status            (status),
    INDEX idx_tracking_number   (tracking_number),
    INDEX idx_origin_dest       (origin_country, destination_country)
);

CREATE TABLE shipment_logs (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    package_id          BIGINT UNSIGNED NOT NULL,
    from_status         VARCHAR(50) NULL,
    to_status           VARCHAR(50) NOT NULL,
    from_warehouse_id   BIGINT UNSIGNED NULL,
    to_warehouse_id     BIGINT UNSIGNED NULL,
    handled_by          BIGINT UNSIGNED NOT NULL,
    note                TEXT NULL,
    created_at          TIMESTAMP NULL,

    FOREIGN KEY (package_id) REFERENCES packages(id),
    FOREIGN KEY (handled_by) REFERENCES users(id),
    INDEX idx_package_id (package_id)
);

CREATE TABLE third_party_providers (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    api_key     VARCHAR(255) UNIQUE NOT NULL,
    webhook_url VARCHAR(500) NULL,
    is_active   TINYINT(1) DEFAULT 1,
    created_at  TIMESTAMP NULL,
    updated_at  TIMESTAMP NULL
);
