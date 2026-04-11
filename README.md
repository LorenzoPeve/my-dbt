# dbt Incremental `insert_overwrite` — Monthly Partitions + Daily Runs

This branch demonstrates a common pitfall with dbt's `insert_overwrite` incremental strategy on BigQuery: **data loss when partition granularity (monthly) does not match the incremental load granularity (daily).**

## Prerequisites

```bash
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
```

This branch requires `dbt-bigquery`. Authenticate with:

```bash
gcloud auth application-default login
```

Then edit `.dbt/profiles.yml` and replace `<your-gcp-project-id>` with your GCP project ID. Switch the active target to BigQuery:

```bash
export DBT_PROFILES_DIR=$PWD/.dbt/
```

Run dbt with the BigQuery target:

```bash
dbt seed --target bigquery --project-dir my_online_store
```

## Seed Data

`seeds/raw_orders.csv` — 10 orders across March and April 2024:

```csv
order_id,customer_id,order_date,amount
1,100,2024-03-01,50.00
2,101,2024-03-02,75.00
3,102,2024-03-03,30.00
4,103,2024-03-10,120.00
5,104,2024-03-15,45.00
6,105,2024-03-20,90.00
7,106,2024-03-25,60.00
8,107,2024-04-01,80.00
9,108,2024-04-02,55.00
10,109,2024-04-05,110.00
```

| Partition (month) | Rows | Days |
|---|---|---|
| `202403` | 7 | Mar 1, 2, 3, 10, 15, 20, 25 |
| `202404` | 3 | Apr 1, 2, 5 |

## The Model

`models/fct_orders_monthly.sql`:

```sql
{{
    config(
        materialized='incremental',
        incremental_strategy='insert_overwrite',
        partition_by={
            "field": "order_date",
            "data_type": "date",
            "granularity": "month"
        }
    )
}}

select
    order_id,
    customer_id,
    order_date,
    amount
from {{ ref('raw_orders') }}

{% if is_incremental() %}
    -- Simulating a daily run: only pick up orders from March 10
    where order_date = '2024-03-10'
{% endif %}
```

The model is partitioned by **month** but the incremental filter selects only a **single day** (simulating a daily scheduled run).

## Reproducing the Issue

### Step 1 — Full Refresh (Initial Load)

```bash
dbt run --full-refresh -s fct_orders_monthly --target bigquery --project-dir my_online_store
```

`is_incremental()` returns `false`, so all 10 rows are loaded.

Verify:

```sql
-- In BigQuery console
SELECT COUNT(*) FROM dev.fct_orders_monthly;
-- Result: 10

SELECT COUNT(*) FROM dev.fct_orders_monthly WHERE order_date BETWEEN '2024-03-01' AND '2024-03-31';
-- Result: 7 (all March rows present)
```

### Step 2 — Incremental Run (Simulating Daily Run for March 10)

```bash
dbt run -s fct_orders_monthly --target bigquery --project-dir my_online_store
```

Now `is_incremental()` returns `true`. The query returns only **1 row** (order_id=4, March 10).

### Step 3 — Observe the Data Loss

```sql
SELECT COUNT(*) FROM dev.fct_orders_monthly;
-- Result: 4  (was 10!)

SELECT COUNT(*) FROM dev.fct_orders_monthly WHERE order_date BETWEEN '2024-03-01' AND '2024-03-31';
-- Result: 1  (was 7! — only March 10 survived)

SELECT COUNT(*) FROM dev.fct_orders_monthly WHERE order_date BETWEEN '2024-04-01' AND '2024-04-30';
-- Result: 3  (April is untouched)
```

**6 rows from March are gone.**

## What Happened

`insert_overwrite` on BigQuery works at the **partition level**:

1. The incremental query ran and produced 1 row (March 10) in a temp table.
2. BigQuery identified that this row belongs to partition `202403` (March).
3. BigQuery **deleted the entire `202403` partition** (all 7 March rows).
4. BigQuery inserted the temp table (1 row) into `202403`.

The contract of `insert_overwrite` is: **"I will give you the complete data for every partition I touch."** When your daily run only returns a slice of the month, it violates that contract.

## Fixes

### Option A — Match partition granularity to run frequency

Partition daily since you run daily:

```sql
partition_by={
    "field": "order_date",
    "data_type": "date",
    "granularity": "day"
}
```

### Option B — Widen the incremental window to cover the full partition

Re-process the entire current month on each run:

```sql
{% if is_incremental() %}
    where order_date >= DATE_TRUNC(CURRENT_DATE(), MONTH)
{% endif %}
```

### Option C — Use `merge` strategy instead

Row-level upserts rather than partition replacement:

```sql
config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_id',
    partition_by={
        "field": "order_date",
        "data_type": "date",
        "granularity": "month"
    }
)
```

## Cleanup

```bash
dbt run-operation drop_relation --args '{relation: ref("fct_orders_monthly")}' --target bigquery --project-dir my_online_store
```
