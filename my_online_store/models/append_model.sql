{{ 
    config(  
        materialized="incremental",
        incremental_strategy="append",  
    )
}}
SELECT *
FROM {{ source('online_store', 'orders') }}

{% if is_incremental() %}
    WHERE order_date > '2025-09-12'
{% endif %}