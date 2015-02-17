DELETE FROM
  "places_polygons"
WHERE
  "cartodb_id" = ANY({{cartoDbChanges}});
