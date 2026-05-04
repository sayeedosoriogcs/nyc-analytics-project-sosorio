WITH source AS (
    SELECT *
    FROM {{ ref('stg_motorvehicle_collisions_crashes') }}
),

vehicle_unpivot AS (
    -- Bring all vehicle columns into one column
    SELECT TRIM(vehicle_type_code1) AS vehicle_type FROM source
    UNION ALL
    SELECT TRIM(vehicle_type_code2) FROM source
    UNION ALL
    SELECT TRIM(vehicle_type_code_3) FROM source
    UNION ALL
    SELECT TRIM(vehicle_type_code_4) FROM source
    UNION ALL
    SELECT TRIM(vehicle_type_code_5) FROM source
),

cleaned AS (
    SELECT DISTINCT
        vehicle_type
    FROM vehicle_unpivot
    WHERE vehicle_type IS NOT NULL
      AND vehicle_type != ''
),

final AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY vehicle_type) AS vehicle_key,
        vehicle_type,

        -- Optional: basic categorization (can improve later)
        CASE
            WHEN LOWER(vehicle_type) LIKE '%taxi%' THEN 'Taxi'
            WHEN LOWER(vehicle_type) LIKE '%bus%' THEN 'Bus'
            WHEN LOWER(vehicle_type) LIKE '%truck%' THEN 'Truck'
            WHEN LOWER(vehicle_type) LIKE '%bike%' THEN 'Bicycle'
            WHEN LOWER(vehicle_type) LIKE '%motorcycle%' THEN 'Motorcycle'
            ELSE 'Other'
        END AS vehicle_body_type

    FROM cleaned
)

SELECT * FROM final;