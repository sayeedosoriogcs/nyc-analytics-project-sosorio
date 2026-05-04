-- models/milestone_work/marts/motor_vehicle_collisions/dim_contributing_factor.sql

with source as (

    select *
    from {{ ref('stg_motorvehicle_collisions_crashes') }}

),

factor_unpivot as (

    select trim(contributing_factor_vehicle_1) as contributing_factor from source
    union all
    select trim(contributing_factor_vehicle_2) from source
    union all
    select trim(contributing_factor_vehicle_3) from source
    union all
    select trim(contributing_factor_vehicle_4) from source
    union all
    select trim(contributing_factor_vehicle_5) from source

),

cleaned as (

    select distinct
        contributing_factor
    from factor_unpivot
    where contributing_factor is not null
      and contributing_factor != ''
      and lower(contributing_factor) != 'unspecified'

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['contributing_factor']) }} as contributing_factor_key,
        contributing_factor                                              as contributing_factor_description,

        case
            when lower(contributing_factor) like '%alcohol%'            then 'Impairment'
            when lower(contributing_factor) like '%drug%'               then 'Impairment'
            when lower(contributing_factor) like '%illicit%'            then 'Impairment'
            when lower(contributing_factor) like '%asleep%'             then 'Impairment'
            when lower(contributing_factor) like '%fatigued%'           then 'Impairment'
            when lower(contributing_factor) like '%lost consciousness%' then 'Impairment'
            when lower(contributing_factor) like '%distract%'           then 'Driver Inattention'
            when lower(contributing_factor) like '%inattention%'        then 'Driver Inattention'
            when lower(contributing_factor) like '%cell%'               then 'Driver Inattention'
            when lower(contributing_factor) like '%texting%'            then 'Driver Inattention'
            when lower(contributing_factor) like '%outside%'            then 'Driver Inattention'
            when lower(contributing_factor) like '%speed%'              then 'Unsafe Speed'
            when lower(contributing_factor) like '%too fast%'           then 'Unsafe Speed'
            when lower(contributing_factor) like '%yield%'              then 'Failure to Yield'
            when lower(contributing_factor) like '%traffic control%'    then 'Failure to Yield'
            when lower(contributing_factor) like '%signal%'             then 'Failure to Yield'
            when lower(contributing_factor) like '%brakes%'             then 'Vehicle Defect'
            when lower(contributing_factor) like '%steering%'           then 'Vehicle Defect'
            when lower(contributing_factor) like '%tire%'               then 'Vehicle Defect'
            when lower(contributing_factor) like '%headlight%'          then 'Vehicle Defect'
            when lower(contributing_factor) like '%windshield%'         then 'Vehicle Defect'
            when lower(contributing_factor) like '%lane%'               then 'Improper Driving'
            when lower(contributing_factor) like '%backing%'            then 'Improper Driving'
            when lower(contributing_factor) like '%turning%'            then 'Improper Driving'
            when lower(contributing_factor) like '%passing%'            then 'Improper Driving'
            when lower(contributing_factor) like '%following%'          then 'Improper Driving'
            when lower(contributing_factor) like '%pavement%'           then 'Road Conditions'
            when lower(contributing_factor) like '%glare%'              then 'Road Conditions'
            when lower(contributing_factor) like '%view%'               then 'Road Conditions'
            when lower(contributing_factor) like '%obstruct%'           then 'Road Conditions'
            else 'Other'
        end as factor_category

    from cleaned

)

select * from final