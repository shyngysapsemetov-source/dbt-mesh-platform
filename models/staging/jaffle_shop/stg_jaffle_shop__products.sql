with

source as (

    select * from {{ source('jaffle_shop', 'products') }}

),

renamed as (

    select

        ----------  ids
        sku as product_id,

        ---------- text
        name as product_name,
        type as product_type,
        description as product_description,


        ---------- numerics
        -- `/ 100.0` was exact on Snowflake, where `100.0` is NUMBER(4,1), but `100.0` is a
        -- **FLOAT64 literal** on BigQuery, so this silently turned money into floating
        -- point: check_parity.py caught float drift against the Snowflake baseline, e.g.
        -- 18.759999999999994 where Snowflake had 18.760000. Casting to NUMERIC first
        -- keeps the division exact decimal.
        (cast(price as numeric) / 100) as product_price,

        ---------- booleans
        coalesce(type = 'jaffle', false) as is_food_item,

        coalesce(type = 'beverage', false) as is_drink_item

    from source

)

select * from renamed
