WITH collisions AS (
    SELECT * FROM {{ ref('stg_motorvehicle_collisions_crashes') }}
),

dim_date AS (
    SELECT * FROM {{ ref('dim_date_m3') }}
),

dim_location AS (
    SELECT * FROM {{ ref('dim_location_m3') }}
),

dim_contributing_factor AS (
    SELECT * FROM {{ ref('dim_contributing_factor') }}
),

dim_vehicle AS (
    SELECT * FROM {{ ref('dim_vehicle') }}
)

SELECT * from dim_date

-- final AS (
--     SELECT
--         -- Surrogate key
--         {{ dbt_utils.generate_surrogate_key(['c.collision_id']) }} AS collision_fact_key,

--         -- Natural key
--         c.collision_id,

--         -- Dimension keys
--         d.date_key          AS date_key,
--         l.location_key      AS location_key,
--         cf.contributing_factor_key AS contributing_factor_key,
--         v.vehicle_key       AS vehicle_key,

--         -- Measures
--         1                                                       AS collision_count,
--         COALESCE(c.number_of_persons_injured, 0)                AS number_of_injuries,
--         COALESCE(c.number_of_persons_killed, 0)                 AS number_of_fatalities,

--         -- Geo
--         ROUND(c.latitude, 3)   AS latitude_rounded,
--         ROUND(c.longitude, 3)  AS longitude_rounded

--     FROM collisions c

--     LEFT JOIN dim_date d
--         ON c.crash_date = d.full_date

--     LEFT JOIN dim_location l
--         ON c.borough   = l.borough
--         AND c.zip_code = l.zip_code

--     LEFT JOIN dim_contributing_factor cf
--         ON LOWER(TRIM(c.contributing_factor_vehicle_1)) = LOWER(TRIM(cf.contributing_factor_description))

--     LEFT JOIN dim_vehicle v
--         ON LOWER(TRIM(c.vehicle_type_code1)) = LOWER(TRIM(v.vehicle_type))
-- )

-- SELECT * FROM final