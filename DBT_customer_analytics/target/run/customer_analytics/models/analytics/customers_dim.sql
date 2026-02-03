
  
    

create or replace transient table analytics_db.analytics_analytics.customers_dim
    
    
    
    as (SELECT
    customer_id,
    customer_name,
    city,
    country,
    signup_date
FROM analytics_db.analytics_staging.stg_customers
    )
;


  