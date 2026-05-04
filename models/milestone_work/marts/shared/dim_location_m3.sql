-- Location dimension shared by both 311 complaints and motor vehicle collisions

with all_locations as (

    -- Get locations from 311 illegal parking complaints
    select distinct
        borough,
        incident_zip as zip_code
    from {{ ref('stg_nyc_311_sr') }}
    where borough is not null

    union distinct

    -- Get locations from motor vehicle collisions
    select distinct
        borough,
        zip_code
    from {{ ref('stg_motorvehicle_collisions_crashes') }}
    where borough is not null

),

location_dimension as (

    select
        {{ dbt_utils.generate_surrogate_key(['borough', 'zip_code']) }} as location_key,
        borough,
        zip_code
    from all_locations

)

select * from location_dimension