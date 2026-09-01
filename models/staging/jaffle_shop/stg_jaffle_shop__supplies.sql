with

source as (

    select * from {{ source('jaffle_shop', 'supplies') }}

),

renamed as (

    select

        ----------  ids
        {{ dbt_utils.generate_surrogate_key(['id', 'sku']) }} as supply_uuid,
        id as supply_id,
        sku as product_id,

        ---------- text
        name as supply_name,

        ---------- numerics
        -- `/ 100.0` was exact on Snowflake, where `100.0` is NUMBER(4,1), but `100.0` is a
        -- **FLOAT64 literal** on BigQuery, so this silently turned money into floating
        -- point: check_parity.py caught float drift against the Snowflake baseline, e.g.
        -- 18.759999999999994 where Snowflake had 18.760000. Casting to NUMERIC first
        -- keeps the division exact decimal.
        (cast(cost as numeric) / 100) as supply_cost,

        ---------- booleans
        perishable as is_perishable_supply

    from source

)

select * from renamed
