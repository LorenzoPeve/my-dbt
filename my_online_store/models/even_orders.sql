{{ config(materialized = 'table') }}
SELECT
    *
FROM
    {{ source('online_store', 'orders') }}
WHERE
    MOD(order_id, 2) = 0