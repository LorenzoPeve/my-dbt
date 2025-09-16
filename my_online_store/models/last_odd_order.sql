SELECT *
FROM {{ ref('odd_orders_ephemeral') }}
ORDER BY order_date DESC
LIMIT 1