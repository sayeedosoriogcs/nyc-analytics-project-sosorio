-- Clean and lightly standardize Open Restaurant Applications data
-- One row per application (objectid)

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'source_nyc_open_restaurant_apps') }}
),

cleaned AS (
    SELECT
        -- Keep most columns, only transform key ones
        * EXCEPT (
            objectid,
            zip_code,
            zip,
            borough,
            submission_timestamp,
            latitude,
            longitude
        ),

        -- Identifier
        CAST(objectid AS STRING) AS application_id,

        -- Clean ZIP (minimal logic)
        CAST(COALESCE(zip_code, zip) AS STRING) AS zip_code,

        -- Standardize borough (light touch)
        INITCAP(TRIM(borough)) AS borough,

        -- Ensure proper types
        CAST(submission_timestamp AS TIMESTAMP) AS submission_timestamp,
        CAST(latitude AS FLOAT64) AS latitude,
        CAST(longitude AS FLOAT64) AS longitude,

        -- Metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    -- Light filtering only (don’t overdo it)
    WHERE objectid IS NOT NULL

    -- Deduplicate (still important)
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY objectid
        ORDER BY submission_timestamp DESC
    ) = 1
)

SELECT * FROM cleaned