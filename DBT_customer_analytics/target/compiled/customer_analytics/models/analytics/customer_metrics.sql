with orders as (

    select
        customer_id,
        order_id,
        order_date,
        amount
    from analytics_db.analytics_analytics.orders_fact

),

customer_aggregates as (

    select
        customer_id,
        count(order_id)          as total_orders,
        sum(amount)              as total_revenue,
        min(order_date)          as first_order_date,
        max(order_date)          as last_order_date,
        avg(amount)              as avg_order_value
    from orders
    group by customer_id

)

select
    c.customer_id,
    c.customer_name,
    ca.total_orders,
    ca.total_revenue,
    ca.first_order_date,
    ca.last_order_date,
    ca.avg_order_value
from analytics_db.analytics_analytics.customers_dim c
left join customer_aggregates ca
    on c.customer_id = ca.customer_id