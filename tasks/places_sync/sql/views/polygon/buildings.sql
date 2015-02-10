DELETE FROM "buildings"
WHERE "buildings"."cartodb_id" NOT IN (
  SELECT "places_polygons"."cartodb_id"
  FROM "places_polygons" JOIN "buildings" ON
    "buildings"."cartodb_id" = "places_polygons"."cartodb_id" AND
    "buildings"."created_at" = "places_polygons"."created_at"
  );
INSERT INTO
  "buildings" (
    "cartodb_id",
    "the_geom",
    "name",
    "places_id",
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
  "name",
  "places_id",
  "type",
  "unit_code",
  "version",
  "created_at",
  "updated_at",
  "the_geom_webmercator"
FROM
  "places_polygons"
WHERE
  "places_polygons"."cartodb_id" NOT IN (
    SELECT "places_polygons"."cartodb_id"
    FROM "places_polygons" JOIN "buildings" ON
      "buildings"."cartodb_id" = "places_polygons"."cartodb_id" AND
      "buildings"."created_at" = "places_polygons"."created_at"
  ) AND
  ("places_polygons"."tags"::json ->> 'building') IS NOT NULL;
