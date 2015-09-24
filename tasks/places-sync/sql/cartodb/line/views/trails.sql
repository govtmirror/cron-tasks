DELETE FROM "trails"
WHERE "trails"."cartodb_id" NOT IN (
  SELECT "places_lines"."cartodb_id"
  FROM "places_lines" JOIN "trails" ON
    "trails"."cartodb_id" = "places_lines"."cartodb_id" AND
    "trails"."created_at" = "places_lines"."created_at"
  );
INSERT INTO
  "trails" (
    "cartodb_id",
    "the_geom",
    "bicycle",
    "class",
    "foot",
    "horse",
    "motor_vehicle",
    "name",
    "places_created_at",
    "places_id",
    "places_updated_at",
    "snowmobile",
    "superclass",
    "surface",
    "tags",
    "type",
    "unit_code",
    "version",
    "created_at",
    "updated_at",
    "the_geom_webmercator"
  )
SELECT
  "cartodb_id",
  "the_geom",
  CASE COALESCE(lower("places_lines"."tags"::json ->> 'bicycle'),'unknown')
    WHEN 'yes' THEN true
    WHEN 'unknown' THEN null
    ELSE false
  END AS "bicycle",
  "class",
  CASE COALESCE(lower("places_lines"."tags"::json ->> 'foot'),'unknown')
    WHEN 'yes' THEN true
    WHEN 'unknown' THEN null
    ELSE false
  END AS "foot",
  CASE COALESCE(lower("places_lines"."tags"::json ->> 'horse'),'unknown')
    WHEN 'yes' THEN true
    WHEN 'unknown' THEN null
    ELSE false
  END AS "horse",
  CASE COALESCE(lower("places_lines"."tags"::json ->> 'motor_vehicle'),'unknown')
    WHEN 'yes' THEN true
    WHEN 'unknown' THEN null
    ELSE false
  END AS "motor_vehicle",
  "name",
  "places_created_at",
  "places_id",
  "places_updated_at",
  CASE COALESCE(lower("places_lines"."tags"::json ->> 'snowmobile'),'unknown')
   WHEN 'yes' THEN true
    WHEN 'unknown' THEN null
    ELSE false
  END AS "snowmobile",
  "superclass",
  lower("places_lines"."tags"::json ->> 'surface') AS "surface",
  "tags",
  "type",
  "unit_code",
  "version",
  "created_at",
  "updated_at",
  "the_geom_webmercator"
FROM
  "places_lines"
WHERE
  "places_lines"."cartodb_id" NOT IN (
    SELECT places_lines.cartodb_id
    FROM places_lines JOIN trails ON
      trails.cartodb_id = places_lines.cartodb_id AND
      trails.created_at = places_lines.created_at
  ) AND "places_lines"."superclass" = 'trail';
