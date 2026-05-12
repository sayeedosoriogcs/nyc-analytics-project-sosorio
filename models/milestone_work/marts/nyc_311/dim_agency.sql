with source as (

    select *
    from {{ ref('stg_nyc_311_sr') }}

) 

select *
from source


-- filtered as (

--     select *
--     from source
--     where lower(trim(complaint_type)) = 'illegal parking'

-- ),

-- agencies as (

--     select distinct
--         agency       as agency_abbreviation,
--         agency_name  as agency_name
--     from filtered
--     where agency is not null

-- ),

-- final as (

--     select
--         {{ dbt_utils.generate_surrogate_key(['agency_abbreviation']) }} as agency_key,
--         agency_name,
--         agency_abbreviation
--     from agencies

-- )

-- select * from final
