SELECT
    customer_id,
    customer_name,
    city,
    country,
    signup_date
FROM {{ ref('stg_customers') }}
