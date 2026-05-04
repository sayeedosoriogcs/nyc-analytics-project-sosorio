with source as (

    select *
    from {{ ref('stg_nyc_311_sr') }}

),

complaint_types as (

    select distinct
        complaint_type,
        descriptor as complaint_category
    from source
    where lower(trim(complaint_type)) = 'illegal parking'
      and complaint_type is not null

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['complaint_type']) }} as complaint_type_key,
        complaint_type                                              as complaint_type_name,
        complaint_category
    from complaint_types

)

select * from final