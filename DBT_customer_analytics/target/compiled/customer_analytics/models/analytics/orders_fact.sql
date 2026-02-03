SELECT
    o.order_id,
    o.customer_id,
    c.customer_name,
    o.order_date,
    o.amount
FROM analytics_db.analytics_staging.stg_orders o
JOIN analytics_db.analytics_analytics.customers_dim c
  ON o.customer_id = c.customer_id