DELETE FROM
  "points_of_interest"
WHERE
  "cartodb_id" = ANY({{cartoDbChanges}});
