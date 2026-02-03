
  
    

create or replace transient table analytics_db.analytics_staging.stg_orders
    
    
    
    as (SELECT
    order_id,
    customer_id,
    order_date,
    amount
FROM analytics_db.raw.orders
    )
;


  