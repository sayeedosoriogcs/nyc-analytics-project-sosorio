WITH source AS (
    SELECT * 
    FROM {{ ref('stg_nyc_311_sr') }}
),

filtered AS (
    SELECT *
    FROM source
    WHERE LOWER(TRIM(complaint_type)) = 'illegal parking'
)

SELECT * FROM filtered