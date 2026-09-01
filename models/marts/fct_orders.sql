with orders as (
    select * from {{ ref('int_orders') }}
),

final as (
    select 
        order_id,
        location_id,
        customer_id,
        order_total,
        tax_paid,
        ordered_at,
        customer_name,
        location_name,
        tax_rate,
        location_opened_at,
        -- Was `date_part(month, ordered_at)`, which is Snowflake-only: BigQuery answers
        -- "Function not found: date_part". `extract(part from x)` is ANSI and valid on BOTH
        -- warehouses, so this is a portability fix rather than a swap to a BigQuery-only
        -- spelling -- no cross-database macro needed, unlike the date_trunc in the staging
        -- layer. Type is unchanged in substance: INT64 here vs Snowflake's NUMBER(2,0),
        -- both exact integers, verified equal by check_parity.py.
        extract(month from ordered_at) as ordered_month,
        extract(day   from ordered_at) as ordered_day,
        extract(year  from ordered_at) as ordered_year
    from orders
)

select * 
from final