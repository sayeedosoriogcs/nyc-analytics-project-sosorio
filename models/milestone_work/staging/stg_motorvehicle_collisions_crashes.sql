-- Clean and lightly standardize Motor Vehicle Collisions data
-- One row per collision (collision_id)

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'motorvehicle_collisions_crashes') }}
),

cleaned AS (
    SELECT
        -- Keep most columns, only transform key ones
        * EXCEPT (
            collision_id,
            zip_code,
            borough,
            crash_date,
            crash_time,
            latitude,
            longitude
        ),

        -- Identifier
        CAST(collision_id AS STRING) AS collision_id,

        -- Clean ZIP (minimal logic)
        TRIM(CAST(zip_code AS STRING)) AS zip_code,

        -- Standardize borough
        INITCAP(TRIM(borough)) AS borough,

        -- Combine date + time into timestamp
        TIMESTAMP(
            PARSE_DATETIME('%Y-%m-%d %H:%M:%S',
                CONCAT(CAST(crash_date AS STRING), ' ', CAST(crash_time AS STRING))
            )
        ) AS crash_timestamp,

        -- Ensure numeric types
        CAST(latitude AS FLOAT64) AS latitude,
        CAST(longitude AS FLOAT64) AS longitude,

        -- Optional: keep original date for filtering/partitioning
        CAST(crash_date AS DATE) AS crash_date,

        -- Metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    -- Align timeframe with project scope (2022–2024)
    WHERE collision_id IS NOT NULL
      AND CAST(crash_date AS DATE) BETWEEN '2022-01-01' AND '2024-12-31'

    -- Deduplicate (important for collisions data)
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY collision_id
        ORDER BY crash_date DESC
    ) = 1
)

SELECT * FROM cleaned;