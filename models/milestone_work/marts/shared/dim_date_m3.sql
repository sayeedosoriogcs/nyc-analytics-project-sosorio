-- models/milestone_work/marts/shared/dim_date_m3.sql

with date_spine as (

    {{
        dbt_utils.date_spine(
            datepart="day",
            start_date="cast('2022-01-01' as date)",
            end_date="cast('2026-12-31' as date)"
        )
    }}

),

final as (

    select
        -- Surrogate key
        cast(to_char(date_day, 'YYYYMMDD') as integer)  as date_key,

        -- Date
        date_day                                         as full_date,

        -- Day-level
        extract(day   from date_day)::int                as day,
        extract(month from date_day)::int                as month,
        to_char(date_day, 'Month')                       as month_name,
        extract(quarter from date_day)::int              as quarter,
        extract(year  from date_day)::int                as year,

        -- Week
        to_char(date_day, 'Day')                         as day_of_week,
        extract(dow from date_day)::int                  as day_of_week_num,  -- 0=Sun, 6=Sat

        -- Flags
        case
            when extract(dow from date_day) in (0, 6) then true
            else false
        end                                              as is_weekend

    from date_spine

)

select * from final