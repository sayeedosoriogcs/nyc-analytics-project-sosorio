-- Clean and standardize Open Restaurant Applications data
-- One row per application (objectid)

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'source_nyc_open_restaurant_apps') }}
),

cleaned AS (
    SELECT
        -- Keep all columns except ones we are transforming
        * EXCEPT (
            objectid,
            restaurant_name,
            legal_business_name,
            business_address,
            borough,
            city,
            state,
            zip_code,
            zip,
            seating_interest_sidewalk,
            seating_interest_roadway,
            sla_serial_number,
            sla_license_type,
            latitude,
            longitude,
            submission_timestamp,
            approved_for_sidewalk_seating,
            approved_for_roadway_seating
        ),

        -- Identifiers
        CAST(objectid AS STRING) AS application_id,

        -- Business info
        TRIM(CAST(restaurant_name AS STRING)) AS restaurant_name,
        TRIM(CAST(legal_business_name AS STRING)) AS legal_business_name,

        -- Address
        TRIM(CAST(business_address AS STRING)) AS business_address,
        TRIM(CAST(city AS STRING)) AS city,
        TRIM(CAST(state AS STRING)) AS state,

        -- Clean ZIP (handle duplicates + bad values)
        CASE
            WHEN UPPER(TRIM(COALESCE(zip_code, zip))) IN ('N/A', 'NA', '') THEN NULL
            WHEN LENGTH(COALESCE(zip_code, zip)) = 5 THEN CAST(COALESCE(zip_code, zip) AS STRING)
            WHEN LENGTH(COALESCE(zip_code, zip)) = 10
                 AND REGEXP_CONTAINS(COALESCE(zip_code, zip), r'^\d{5}-\d{4}')
            THEN CAST(COALESCE(zip_code, zip) AS STRING)
            ELSE NULL
        END AS zip_code,

        -- Standardize borough
        CASE
            WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK') THEN 'Manhattan'
            WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
            WHEN UPPER(TRIM(borough)) IN ('BROOKLYN') THEN 'Brooklyn'
            WHEN UPPER(TRIM(borough)) IN ('QUEENS') THEN 'Queens'
            WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND') THEN 'Staten Island'
            ELSE 'UNKNOWN'
        END AS borough,

        -- Seating interest
        UPPER(TRIM(CAST(seating_interest_sidewalk AS STRING))) AS seating_interest_sidewalk,
        UPPER(TRIM(CAST(seating_interest_roadway AS STRING))) AS seating_interest_roadway,

        -- Approvals
        UPPER(TRIM(CAST(approved_for_sidewalk_seating AS STRING))) AS approved_for_sidewalk_seating,
        UPPER(TRIM(CAST(approved_for_roadway_seating AS STRING))) AS approved_for_roadway_seating,

        -- Licensing
        CAST(sla_serial_number AS STRING) AS sla_serial_number,
        CAST(sla_license_type AS STRING) AS sla_license_type,

        -- Location
        CAST(latitude AS DECIMAL) AS latitude,
        CAST(longitude AS DECIMAL) AS longitude,

        -- Timestamp
        CAST(submission_timestamp AS TIMESTAMP) AS submission_timestamp,

        -- Metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    -- Filters (similar philosophy as 311)
    WHERE objectid IS NOT NULL
      AND submission_timestamp IS NOT NULL
      AND borough IS NOT NULL

    -- Deduplicate: one row per application
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY objectid 
        ORDER BY submission_timestamp DESC
    ) = 1
)

SELECT * FROM cleaned