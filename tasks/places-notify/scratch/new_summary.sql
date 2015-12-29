SELECT
  osm_id AS "osm_id",
  'n' || osm_id AS "places_id",
  lower("superclass") AS "superclass",
  lower("class") AS "class",
  lower("type") AS "type",
  ST_Transform(way, 4326) AS the_geom,
  --tstamp
  --tstamp_gmt
  --changeset_id
  lower("unit_code") AS "unit_code"
FROM
  nps_render_point_view
WHERE
  unit_code = 'hofu'
  
