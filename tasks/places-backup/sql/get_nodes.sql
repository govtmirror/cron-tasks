SELECT
  id AS "osm_id",
  version AS "osm_version",
  tstamp AS "created",
  geom AS the_geom,
  tags::text,
  o2p_get_name(tags, 'n', true) as type,
  tags -> 'name' as name
FROM
  nodes
WHERE
 array_length(array_remove(array_remove(akeys(tags),'nps:places_id'), 'nps:unit_code'),1) > 0
ORDER BY
  id
