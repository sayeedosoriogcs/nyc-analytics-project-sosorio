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
        cast(format_date('%Y%m%d', date_day) as int64)      as date_key,

        -- Date
        date_day                                             as full_date,

        -- Day-level
        cast(extract(day   from date_day) as int64)         as day,
        cast(extract(month from date_day) as int64)         as month,
        format_date('%B', date_day)                         as month_name,
        cast(extract(quarter from date_day) as int64)       as quarter,
        cast(extract(year  from date_day) as int64)         as year,

        -- Week
        format_date('%A', date_day)                         as day_of_week,
        cast(extract(dayofweek from date_day) as int64)     as day_of_week_num,  -- 1=Sun, 7=Sat

        -- Flags
        case
            when extract(dayofweek from date_day) in (1, 7) then true
            else false
        end                                                  as is_weekend

    from date_spine

)

select * from final