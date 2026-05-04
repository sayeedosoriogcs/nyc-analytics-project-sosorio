SELECT
  LENGTH(TRIM(CAST(zip_code AS STRING))) AS zip_length,
  TRIM(CAST(zip_code AS STRING)) AS zip_code,
  COUNT(*) AS count
FROM `cis-9440-sayeedosorio.nyc_milestone3_group7_rawdata.motorvehicle_collisions_crashes`
WHERE zip_code IS NOT NULL
  AND LENGTH(TRIM(CAST(zip_code AS STRING))) != 5
  AND DATE(crash_date) BETWEEN '2022-01-01' AND '2024-12-31'
GROUP BY zip_length, zip_code
ORDER BY count DESC;