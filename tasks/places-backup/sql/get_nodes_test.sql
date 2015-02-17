SELECT
  id AS "osm_id",
  version AS "osm_version",
  tstamp AS "created",
  geom AS the_geom,
  tags::text,
  o2p_get_name(tags, 'n', true)
FROM
  nodes
LIMIT 10
