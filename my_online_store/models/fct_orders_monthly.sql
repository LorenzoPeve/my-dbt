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
