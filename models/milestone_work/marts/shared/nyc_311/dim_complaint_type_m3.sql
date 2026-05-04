WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'source_nyc_311_service_requests') }}
),

filtered AS (
    SELECT *
    FROM source
    WHERE LOWER(TRIM(complaint_type)) = 'illegal parking'
)

SELECT * FROM filtered