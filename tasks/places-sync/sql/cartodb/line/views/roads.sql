DELETE FROM "roads"
WHERE "roads"."cartodb_id" NOT IN (
  SELECT "places_lines"."cartodb_id"
  FROM "places_lines" JOIN "roads" ON
    "roads"."cartodb_id" = "places_lines"."cartodb_id" AND
    "roads"."created_at" = "places_lines"."created_at"
  WHERE "places_lines"."superclass" = 'road'
  );
INSERT INTO
  "roads" (
    "cartodb_id",
    "the_geom",
    "name",
    "places_id",
    "superclass",
    "class",
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
  "superclass",
  "class",
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
    FROM places_lines JOIN roads ON
      roads.cartodb_id = places_lines.cartodb_id AND
      roads.created_at = places_lines.created_at
  ) AND "places_lines"."superclass" = 'road'
  );
