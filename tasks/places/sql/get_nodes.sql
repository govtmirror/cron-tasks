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
 array_length(akeys(tags),1) > 1 OR  
 NOT exist(tags, 'nps:places_uuid')
ORDER BY
 id
