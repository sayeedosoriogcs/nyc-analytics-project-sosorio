WITH requests AS (
    SELECT * FROM {{ ref('stg_nyc_311_sr') }}
),

dim_date AS (
    SELECT date_key, full_date FROM {{ ref('dim_date_m3') }}
),

dim_location AS (
    SELECT location_key, borough, zip_code FROM {{ ref('dim_location_m3') }}
),

dim_complaint AS (
    SELECT complaint_type_key, complaint_type_name
    FROM {{ ref('dim_complaint_type_m3') }}
),

dim_agency AS (
    SELECT agency_key, agency_abbreviation FROM {{ ref('dim_agency') }}
),

final AS (
    SELECT
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['r.unique_key']) }} AS complaint_fact_key,

        -- Degenerate dimension
        r.unique_key AS complaint_number,

        -- Foreign keys
        d_created.date_key  AS date_created_key,
        d_closed.date_key   AS date_closed_key,
        l.location_key,
        c.complaint_type_key,
        a.agency_key,

        -- Measures
        1 AS complaint_count,

        TIMESTAMP_DIFF(
            CAST(r.closed_date AS TIMESTAMP),
            CAST(r.created_date AS TIMESTAMP),
            MINUTE
        ) AS resolution_time_minutes,

        DATE_DIFF(
            CAST(r.closed_date AS DATE),
            CAST(r.created_date AS DATE),
            DAY
        ) AS days_open,

        -- Rounded geo
        ROUND(CAST(r.latitude AS FLOAT64), 3)  AS latitude_rounded,
        ROUND(CAST(r.longitude AS FLOAT64), 3) AS longitude_rounded

    FROM requests r

    LEFT JOIN dim_date d_created
        ON CAST(r.created_date AS DATE) = d_created.full_date

    LEFT JOIN dim_date d_closed
        ON CAST(r.closed_date AS DATE) = d_closed.full_date

    LEFT JOIN dim_location l
        ON r.borough = l.borough
        AND r.incident_zip = l.zip_code

    LEFT JOIN dim_complaint c
        ON LOWER(TRIM(r.complaint_type)) = LOWER(TRIM(c.complaint_type_name))

    LEFT JOIN dim_agency a
        ON r.agency = a.agency_abbreviation
)

SELECT * FROM final