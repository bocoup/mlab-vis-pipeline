#standardSQL
SELECT
  IFNULL(download.test_date, upload.test_date) as test_date,

  EXTRACT(YEAR from IFNULL(download.test_date, upload.test_date)) as test_date_year,
  EXTRACT(MONTH from IFNULL(download.test_date, upload.test_date)) as test_date_month,
  EXTRACT(DAY from IFNULL(download.test_date, upload.test_date)) as test_date_day,

  IFNULL(download.client_ip, upload.client_ip) as client_ip,
  IFNULL(download.client_ip_base64, upload.client_ip_base64) as client_ip_base64,
  IFNULL(download.client_ip_family, upload.client_ip_family) as client_ip_family,
  IFNULL(download.client_city, upload.client_city) as client_city,
  IFNULL(download.client_region_code, upload.client_region_code) as client_region_code,
  IFNULL(download.client_continent_code, upload.client_continent_code) as client_continent_code,
  IFNULL(download.client_country_code, upload.client_country_code) as client_country_code,
  IFNULL(download.client_latitude, upload.client_latitude) as client_latitude,
  IFNULL(download.client_longitude, upload.client_longitude) as client_longitude,
  IFNULL(download.server_ip, upload.server_ip) as server_ip,
  IFNULL(download.server_ip_base64, upload.server_ip_base64) as server_ip_base64,
  IFNULL(download.server_ip_family, upload.server_ip_family) as server_ip_family,
  IFNULL(download.server_city, upload.server_city) as server_city,
  IFNULL(download.server_region_code, upload.server_region_code) as server_region_code,
  IFNULL(download.server_continent_code, upload.server_continent_code) as server_continent_code,
  IFNULL(download.server_country_code, upload.server_country_code) as server_country_code,
  IFNULL(download.server_latitude, upload.server_latitude) as server_latitude,
  IFNULL(download.server_longitude, upload.server_longitude) as server_longitude,

  download.download_test_count as download_test_count,
  download.download_speed_mbps as download_speed_mbps,
  download.rtt_sum as rtt_sum,
  download.rtt_count as rtt_count,
  download.rtt_min as rtt_min,
  download.rtt_avg as rtt_avg,
  download.rtt_median as rtt_median,
  download.segs_retrans as segs_retrans,
  download.segs_out as segs_out,
  download.packet_retransmit_rate as packet_retransmit_rate,
  download.packet_retransmit_rate_median as packet_retransmit_rate_median,
  download.network_limited_time_ratio as network_limited_time_ratio,
  download.client_limited_time_ratio as client_limited_time_ratio,
  download.sum_lim_time_rwin as sum_lim_time_rwin,
  download.sum_lim_time_cwnd as sum_lim_time_cwnd,
  download.sum_lim_time_snd as sum_lim_time_snd,

  upload.upload_speed_mbps as upload_speed_mbps,
  upload.upload_test_count as upload_test_count

FROM
  {0} as download,
  {1} as upload

WHERE
  download.test_date = upload.test_date AND
  download.client_ip = upload.client_ip AND
  download.server_ip = upload.server_ip AND
  (
    (download.client_city = upload.client_city)
    OR (download.client_city IS NULL AND upload.client_city IS NULL)
  ) AND (
    (download.client_region_code = upload.client_region_code) OR
    (download.client_region_code IS NULL AND upload.client_region_code IS NULL)
  ) AND (
    (download.client_continent_code = upload.client_continent_code) OR
    (download.client_continent_code IS NULL AND upload.client_continent_code IS NULL)
  ) AND (
    (download.client_country_code = upload.client_country_code) OR
    (download.client_country_code IS NULL AND upload.client_country_code IS NULL)
  ) AND (
    (download.client_ip_family = upload.client_ip_family) OR
    (download.client_ip_family IS NULL AND upload.client_ip_family IS NULL)
  ) AND (
    (download.client_latitude = upload.client_latitude) OR
    (download.client_latitude IS NULL AND upload.client_latitude IS NULL)
  ) AND (
    (download.client_longitude = upload.client_longitude) OR
    (download.client_longitude IS NULL AND upload.client_longitude IS NULL)
  ) AND (
    (download.server_ip_family = upload.server_ip_family) OR
    (download.server_ip_family IS NULL AND upload.server_ip_family IS NULL)
  ) AND (
    (download.server_city = upload.server_city) OR
    (download.server_city IS NULL AND upload.server_city IS NULL)
  ) AND (
    (download.server_continent_code = upload.server_continent_code) OR
    (download.server_continent_code IS NULL AND upload.server_continent_code IS NULL)
  ) AND (
    (download.server_region_code = upload.server_region_code) OR
    (download.server_region_code IS NULL AND upload.server_region_code IS NULL)
  ) AND (
    (download.server_country_code = upload.server_country_code) OR
    (download.server_country_code IS NULL AND upload.server_country_code IS NULL)
  ) AND (
    (download.server_latitude = upload.server_latitude) OR
    (download.server_latitude IS NULL AND upload.server_latitude IS NULL)
  ) AND (
    (download.server_longitude = upload.server_longitude) OR
    (download.server_longitude IS NULL AND upload.server_longitude IS NULL)
  )