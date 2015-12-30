DELETE FROM "parking_lots_temp"
WHERE "parking_lots_temp"."cartodb_id" NOT IN (
  SELECT "places_polygons"."cartodb_id"
  FROM "places_polygons" JOIN "parking_lots_temp" ON
    "parking_lots_temp"."cartodb_id" = "places_polygons"."cartodb_id" AND
    "parking_lots_temp"."created_at" = "places_polygons"."created_at"
  );
INSERT INTO
  "parking_lots_temp" (
    "access_road_type",
    "address_city",
    "address_housenumber",
    "address_state",
    "address_street",
    "address_zipcode",
    "allowed_access",
    "allowed_access_motor_vehicle",
    "approved_uses_4wd",
    "approved_uses_atv",
    "approved_uses_bicycle",
    "approved_uses_foot",
    "approved_uses_horse",
    "approved_uses_snowmobile",
    "approved_water_uses_canoe",
    "approved_water_uses_motorboat",
    "building_levels",
    "capacity",
    "cartodb_id",
    "class",
    "description",
    "fee",
    "gender",
    "hiking_difficulty",
    "hours",
    "imba_trail_difficulty",
    "incline",
    "lanes",
    "lit",
    "mountain_biking_difficulty",
    "mountain_biking_uphill_difficulty",
    "name",
    "one_way",
    "operator",
    "places_created_at",
    "places_updated_at",
    "population",
    "smoking",
    "speed_limit",
    "structure",
    "superclass",
    "surface",
    "the_geom",
    "track_type",
    "trail_visibility",
    "type",
    "unit_code",
    "version",
    "width_meters"
  )
SELECT
  ("base"."tags"::json)->>'service'          AS "access_road_type",
  ("base"."tags"::json)->>'addr:city'        AS "address_city",
  ("base"."tags"::json)->>'addr:housenumber' AS "address_housenumber",
  ("base"."tags"::json)->>'addr:state'       AS "address_state",
  ("base"."tags"::json)->>'addr:street'      AS "address_street",
  ("base"."tags"::json)->>'addr:postcode'    AS "address_zipcode",
  ("base"."tags"::json)->>'access'           AS "allowed_access",
  ("base"."tags"::json)->>'motor_vehicle'    AS "allowed_access_motor_vehicle",
  ("base"."tags"::json)->>'4wd_only'         AS "approved_uses_4wd",
  ("base"."tags"::json)->>'atv'              AS "approved_uses_atv",
  ("base"."tags"::json)->>'bicycle'          AS "approved_uses_bicycle",
  ("base"."tags"::json)->>'foot'             AS "approved_uses_foot",
  ("base"."tags"::json)->>'horse'            AS "approved_uses_horse",
  ("base"."tags"::json)->>'snowmobile'       AS "approved_uses_snowmobile",
  ("base"."tags"::json)->>'canoe'            AS "approved_water_uses_canoe",
  ("base"."tags"::json)->>'motorboat'        AS "approved_water_uses_motorboat",
  ("base"."tags"::json)->>'building:levels'  AS "building_levels",
  ("base"."tags"::json)->>'capacity'         AS "capacity",
  "base"."cartodb_id"                        AS "cartodb_id",
  "base"."class"                             AS "class",
  ("base"."tags"::json)->>'description'      AS "description",
  ("base"."tags"::json)->>'fee'              AS "fee",
  CASE
    WHEN
      lower(COALESCE(("base"."tags"::json)->>'female', 'no')) = 'yes' AND
      lower(COALESCE(("base"."tags"::json)->>'unisex', 'no')) = 'no' AND
      lower(COALESCE(("base"."tags"::json)->>'male', 'no')) = 'no' THEN
      'female'
    WHEN
      lower(COALESCE(("base"."tags"::json)->>'female', 'no')) = 'no' AND
      lower(COALESCE(("base"."tags"::json)->>'unisex', 'no')) = 'no' AND
      lower(COALESCE(("base"."tags"::json)->>'male', 'no')) = 'yes' THEN
      'male'
    WHEN
      (
        lower(COALESCE(("base"."tags"::json)->>'female', 'no')) = 'yes' AND
        lower(COALESCE(("base"."tags"::json)->>'male', 'no')) = 'yes'
      ) OR
      lower(COALESCE(("base"."tags"::json)->>'unisex', 'no')) = 'yes' THEN
      'unisex'
    ELSE
      null
    END
                                             AS "gender",
  ("base"."tags"::json)->>'sac_scale'        AS "hiking_difficulty",
  ("base"."tags"::json)->>'opening_hours'    AS "hours",
  ("base"."tags"::json)->>'mtb:scale:imba'   AS "imba_trail_difficulty",
  ("base"."tags"::json)->>'incline'          AS "incline",
  ("base"."tags"::json)->>'lanes'            AS "lanes",
  ("base"."tags"::json)->>'lit'              AS "lit",
  ("base"."tags"::json)->>'mtb:scale'        AS "mountain_biking_difficulty",
  ("base"."tags"::json)->>'mtb:scale:uphill' AS "mountain_biking_uphill_difficulty",
  ("base"."tags"::json)->>'name'             AS "name",
  ("base"."tags"::json)->>'lanes'            AS "one_way",
  ("base"."tags"::json)->>'operator'         AS "operator",
  "base"."places_created_at"                 AS "places_created_at",
  "base"."places_updated_at"                 AS "places_updated_at",
  ("base"."tags"::json)->>'population'       AS "population",
  ("base"."tags"::json)->>'smoking'          AS "smoking",
  ("base"."tags"::json)->>'maxspeed'         AS "speed_limit",
  CASE 
    WHEN (("base"."tags"::json) ->> 'bridge') IS NOT NULL THEN 'bridge' 
    WHEN (("base"."tags"::json) ->> 'tunnel') IS NOT NULL THEN 'tunnel' 
    WHEN (("base"."tags"::json) ->> 'embankment') IS NOT NULL THEN 'embankment'
    WHEN (("base"."tags"::json) ->> 'cutting') IS NOT NULL THEN 'cutting'
    WHEN (("base"."tags"::json) ->> 'ford') IS NOT NULL THEN 'ford'
    ELSE null
  END
                                             AS "structure",
  "base"."superclass"                        AS "superclass",
  ("base"."tags"::json)->>'surface'          AS "surface",
  "base"."the_geom"                          AS "the_geom",
  ("base"."tags"::json)->>'tracktype'        AS "track_type",
  ("base"."tags"::json)->>'trail_visibility' AS "trail_visibility",
  "base"."type"                              AS "type",
  "base"."unit_code"                         AS "unit_code",
  "base"."version"                           AS "version",
  ("base"."tags"::json)->>'width'            AS "width_meters"
FROM
  places_polygons "base"
WHERE
  "base"."cartodb_id" NOT IN (
    SELECT places_polygons.cartodb_id
    FROM places_polygons JOIN parking_lots_temp ON
      parking_lots_temp.cartodb_id = places_polygons.cartodb_id
  ) AND "base"."type" = 'Parking Lot';
