SELECT
    o.order_id,
    o.customer_id,
    c.customer_name,
    o.order_date,
    o.amount
FROM {{ ref('stg_orders') }} o
JOIN {{ ref('customers_dim') }} c
  ON o.customer_id = c.customer_id
