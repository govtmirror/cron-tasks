DELETE FROM
  "places_lines"
WHERE
  "cartodb_id" = ANY({{cartoDbChanges}});
