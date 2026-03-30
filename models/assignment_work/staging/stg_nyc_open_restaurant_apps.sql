SELECT
   LENGTH(CAST(zip AS STRING)) AS zip_length,
   zip,
   COUNT(*) AS count
 FROM `cis-9440-sayeedosorio.nyc_hw3_raw_data.source_nyc_open_restaurant_apps`
 WHERE zip IS NOT NULL
   AND LENGTH(CAST(zip AS STRING)) != 5
 GROUP BY zip_length, zip
 ORDER BY count DESC