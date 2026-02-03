SELECT
    customer_id,
    customer_name,
    city,
    country,
    signup_date
FROM {{ source('raw', 'customers') }}
