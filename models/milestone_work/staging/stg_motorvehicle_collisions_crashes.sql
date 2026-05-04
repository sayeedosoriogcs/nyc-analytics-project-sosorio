-- Clean and lightly standardize Motor Vehicle Collisions data
-- One row per collision

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'motorvehicle_collisions_crashes') }}
),

cleaned AS (
    SELECT
        * EXCEPT (
            collision_id,
            zip_code,
            borough,
            crash_date,
            latitude,
            longitude
        ),

        CAST(collision_id AS STRING) AS collision_id,
        TRIM(CAST(zip_code AS STRING)) AS zip_code,
        INITCAP(TRIM(borough)) AS borough,

        CAST(crash_date AS DATE) AS crash_date,

        CAST(latitude AS FLOAT64) AS latitude,
        CAST(longitude AS FLOAT64) AS longitude,

        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source
    WHERE collision_id IS NOT NULL
      AND CAST(crash_date AS DATE) BETWEEN '2022-01-01' AND '2024-12-31'

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY collision_id
        ORDER BY crash_date DESC
    ) = 1
)

SELECT * FROM cleaned