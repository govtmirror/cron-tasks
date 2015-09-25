INSERT INTO
  "points_of_interest" (
    "cartodb_id",
    "the_geom",
    "class",
    "name",
    "places_created_at",
    "places_id",
    "places_updated_at",
    "superclass",
    "tags",
    "type",
    "unit_code",
    "version"
  ) VALUES (
    '{{cartodb_id}}',
    ST_SetSRID(ST_GeomFromGeoJSON('{{the_geom}}'),4326),
    '{{class}}',
    '{{name}}',
    '{{places_created_at}}',
    '{{places_id}}',
    '{{places_updated_at}}',
    '{{superclass}}',
    '{{tags}}',
    '{{type}}',
    '{{unit_code}}',
    '{{version}}'
  );
