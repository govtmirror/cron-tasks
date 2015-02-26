DELETE FROM "streets"
WHERE "streets"."cartodb_id" NOT IN (
  SELECT "places_lines"."cartodb_id"
  FROM "places_lines" JOIN "streets" ON
    "streets"."cartodb_id" = "places_lines"."cartodb_id" AND
    "streets"."created_at" = "places_lines"."created_at"
  );
INSERT INTO
  "streets" (
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
  "places_lines"
WHERE
  "places_lines"."cartodb_id" NOT IN (
    SELECT places_lines.cartodb_id
    FROM places_lines JOIN streets ON
      streets.cartodb_id = places_lines.cartodb_id AND
      streets.created_at = places_lines.created_at
  ) AND (
    ("places_lines"."tags"::json ->> 'highway') IN ('motorway', 'trunk', 'primary',
    'secondary', 'tertiary', 'unclassified', 'residential', 'service', 'motorway_link',
    'trunk_link', 'primary_link', 'secondary_link', 'tertiary_link')
  );
