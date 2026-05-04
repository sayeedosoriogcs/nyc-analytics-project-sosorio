-- models/milestone_work/marts/motor_vehicle_collisions/dim_vehicle.sql

with source as (

    select *
    from {{ ref('stg_motorvehicle_collisions_crashes') }}

),

vehicle_unpivot as (

    select trim(vehicle_type_code1)   as vehicle_type from source
    union all
    select trim(vehicle_type_code2)   from source
    union all
    select trim(vehicle_type_code_3)  from source
    union all
    select trim(vehicle_type_code_4)  from source
    union all
    select trim(vehicle_type_code_5)  from source

),

cleaned as (

    select distinct
        vehicle_type
    from vehicle_unpivot
    where vehicle_type is not null
      and vehicle_type != ''

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['vehicle_type']) }} as vehicle_key,
        vehicle_type,

        case
            when lower(vehicle_type) like '%taxi%'          then 'Taxi'
            when lower(vehicle_type) like '%bus%'           then 'Bus'
            when lower(vehicle_type) like '%truck%'         then 'Truck'
            when lower(vehicle_type) like '%tractor%'       then 'Truck'
            when lower(vehicle_type) like '%trailer%'       then 'Truck'
            when lower(vehicle_type) like '%bike%'          then 'Bicycle'
            when lower(vehicle_type) like '%bicycle%'       then 'Bicycle'
            when lower(vehicle_type) like '%e-bik%'         then 'Bicycle'
            when lower(vehicle_type) like '%motorcycle%'    then 'Motorcycle'
            when lower(vehicle_type) like '%motorbike%'     then 'Motorcycle'
            when lower(vehicle_type) like '%scooter%'       then 'Motorcycle'
            when lower(vehicle_type) like '%sedan%'         then 'Passenger Vehicle'
            when lower(vehicle_type) like '%station wagon%' then 'Passenger Vehicle'
            when lower(vehicle_type) like '%suv%'           then 'Passenger Vehicle'
            when lower(vehicle_type) like '%van%'           then 'Van'
            when lower(vehicle_type) like '%ambulance%'     then 'Emergency'
            when lower(vehicle_type) like '%fire%'          then 'Emergency'
            when lower(vehicle_type) like '%police%'        then 'Emergency'
            else 'Other'
        end as vehicle_body_type

    from cleaned

)

select * from final