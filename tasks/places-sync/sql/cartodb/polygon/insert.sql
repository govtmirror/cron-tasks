INSERT INTO
  "places_polygons" (
    "cartodb_id",
    "version",
    "name",
    "places_id",
    "tags",
    "superclass",
    "class",
    "type",
    "unit_code",
    "rendered",
    "the_geom"
  ) VALUES (
    '{{cartodb_id}}',
    '{{version}}',
    '{{name}}',
    '{{places_id}}',
    '{{tags}}',
    '{{superclass}}',
    '{{class}}',
    '{{type}}',
    '{{unit_code}}',
    '{{rendered}}',
    ST_SetSRID(ST_GeomFromGeoJSON('{{the_geom}}'),4326)
  );
