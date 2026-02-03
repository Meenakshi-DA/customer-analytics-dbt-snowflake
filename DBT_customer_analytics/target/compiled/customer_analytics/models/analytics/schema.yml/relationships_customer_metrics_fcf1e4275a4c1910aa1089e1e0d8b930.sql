
    
    

with child as (
    select customer_id as from_field
    from analytics_db.analytics_analytics.customer_metrics
    where customer_id is not null
),

parent as (
    select customer_id as to_field
    from analytics_db.analytics_analytics.customers_dim
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


