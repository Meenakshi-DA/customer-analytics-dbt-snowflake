
    
    

select
    order_id as unique_field,
    count(*) as n_records

from analytics_db.analytics_analytics.orders_fact
where order_id is not null
group by order_id
having count(*) > 1


