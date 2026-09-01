with

source as (

    select * from {{ source('jaffle_shop', 'orders') }}

),

renamed as (

    select

        ----------  ids
        id as order_id,
        store_id as location_id,
        customer as customer_id,

        ---------- numerics
        -- `/ 100.0` was exact on Snowflake, where `100.0` is NUMBER(4,1), but `100.0` is a
        -- **FLOAT64 literal** on BigQuery, so this silently turned money into floating
        -- point: check_parity.py caught sums of 12051.809999999992 against Snowflake's
        -- 12051.810000. Casting to NUMERIC first keeps the division exact decimal.
        (cast(order_total as numeric) / 100) as order_total,
        (cast(tax_paid as numeric) / 100) as tax_paid,

        ---------- timestamps
        {{ dbt.date_trunc('day','ordered_at') }} as ordered_at

    from source

)

select * from renamed
