# dbt Snapshots

## Setting up the Python Environment

```bash
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
```

## Setting up PostgreSQL in Docker

To set up PostgreSQL in Docker, you can use the following command:

```bash
docker run --name my_postgres -d -p 5432:5432 -e POSTGRES_PASSWORD=mypass123  -v my_postgres_data:/var/lib/postgresql/data postgres
```

## Resolving dbt Profile Directory Error

If you encounter the following error:

```
Error: Invalid value for '--profiles-dir': Path '/Users/lorenzopeve/.dbt' does not exist.
```

Create the following environment variables in your shell:

```bash
export DBT_PROFILES_DIR=$PWD/.dbt/ 
```

This error occurs because dbt searches for the `profiles.yml` file in `~/Users/name/.dbt/` by default. By setting the `DBT_PROFILES_DIR` environment variable, you can specify a different directory for dbt to look for the profiles.yml file.

## Creating source tables
```sql
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
```

### Modifying the schema
```sql
-- Remove the total_amount column
ALTER TABLE dev.orders
DROP COLUMN total_amount;

-- Add a new column for item_category
ALTER TABLE dev.orders
ADD COLUMN item_category VARCHAR(50);
```

### Simulating changes to existing data
#### Timebased snapshot
```
UPDATE dev.orders
SET
    item_category = 'footwear',
    updated_at = TIMESTAMP '2026-12-31 09:00'
WHERE order_id = 1005;
```
#### Check-based snapshot
```sql
UPDATE dev.orders
SET
    order_status = 'delivered'
WHERE order_id = 1005;
```

### Inserting new data to simulate changes
```sql
INSERT INTO dev.orders (order_id, username, order_status, order_item_id, order_date, updated_at)
VALUES
    (1006, 'carlos',  'delivered',   44, '2025-09-10', CURRENT_TIMESTAMP AT TIME ZONE 'CST');
```