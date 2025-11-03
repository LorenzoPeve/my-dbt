
/*
-------------------------------------------------------------------------------
DATA SETUP --------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Create schema if it doesn't exist
DROP SCHEMA IF EXISTS dev CASCADE;
CREATE SCHEMA IF NOT EXISTS dev;

-- Create table inside the dev schema
CREATE TABLE IF NOT EXISTS dev.orders (
    order_id INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_item_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO dev.orders (order_id, username, order_status, order_item_id, order_date, total_amount, updated_at)
VALUES
    (1001, 'alice',  'pending',   501, '2025-09-10',  59.99, CURRENT_TIMESTAMP AT TIME ZONE 'CST'),
    (1002, 'bob',    'shipped',   502, '2025-09-11', 120.00, CURRENT_TIMESTAMP AT TIME ZONE 'CST'),
    (1003, 'charlie','cancelled', 503, '2025-09-12',  35.50, CURRENT_TIMESTAMP AT TIME ZONE 'CST'),
    (1004, 'alice',  'delivered', 504, '2025-09-12',  89.95, CURRENT_TIMESTAMP AT TIME ZONE 'CST'),
    (1005, 'diana',  'pending',   505, '2025-09-13',  42.75, CURRENT_TIMESTAMP AT TIME ZONE 'CST');

-------------------------------------------------------------------------------
UPDATE DATA -------------------------------------------------------------------
-------------------------------------------------------------------------------

INSERT INTO dev.orders (order_id, username, order_status, order_item_id, order_date, total_amount, updated_at)
VALUES
    (1006, 'emily',  'pending',  506, '2025-09-14', 79.99, CURRENT_TIMESTAMP AT TIME ZONE 'CST'),
    (1007, 'frank',  'processing', 507, '2025-09-15', 49.50, CURRENT_TIMESTAMP AT TIME ZONE 'CST');

UPDATE dev.orders
SET 
    order_status = 'delivered',
    total_amount = 77.77,
    updated_at = CURRENT_TIMESTAMP AT TIME ZONE 'CST'
WHERE order_id IN (1001, 1005);

-------------------------------------------------------------------------------
EXPECTED ----------------------------------------------------------------------
-------------------------------------------------------------------------------
- These two records will be picked up on the next incremental run
- 1001 won’t be updated since its order_date is before the cutoff date
- 1005 will be updated since its order_date is after the cutoff date
*/
{{ 
    config(  
        materialized="incremental",
        incremental_strategy="delete+insert",
        unique_key="order_id"
    )
}}
SELECT *
FROM {{ source('online_store', 'orders') }}

{% if is_incremental() %}
    WHERE order_date > '2025-09-12'
{% endif %}