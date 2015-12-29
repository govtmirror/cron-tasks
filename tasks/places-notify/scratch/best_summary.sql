-- Aggregate the nodes
SELECT
  nodes.id AS osm_id,
  nodes.version AS version,
  nodes.tags AS tags,
  o2p_get_preset(nodes.tags, ARRAY['point'])::json AS preset,
  nodes.user_id,
  nodes.tstamp,
  'point' AS "element_type",
  nodes.geom AS geom
FROM
  nodes
WHERE
  nodes.tags IS NOT NULL
UNION ALL
-- Aggregate the line ways that are not in relations
SELECT
  ways.id AS osm_id,
  ways.version AS version,
  ways.tags AS tags,
  o2p_get_preset(ways.tags, ARRAY['line'])::json AS preset,
  ways.user_id,
  ways.tstamp,
  'line' AS "element_type",
  o2p_calculate_nodes_to_line(ways.nodes) AS geom
FROM
  ways
WHERE
  ways.tags IS NOT NULL AND
  o2p_get_preset(ways.tags, ARRAY['line'])::json IS NOT NULL AND
  NOT (
    EXISTS (
      SELECT 1
      FROM "relation_members"
      JOIN "relations" ON "relation_members"."relation_id" = "relations"."id"
      WHERE
        "relation_members"."member_id" = "ways"."id" AND
        UPPER("relation_members"."member_type"::text) = 'W'::text AND
        "relations"."tags" -> 'type' = 'route'
    )
  )
UNION ALL
-- Aggregate the area ways that are not in relations
SELECT
  ways.id AS osm_id,
  ways.version AS version,
  ways.tags AS tags,
  o2p_get_preset(ways.tags, ARRAY['area'])::json AS preset,
  ways.user_id,
  ways.tstamp,
  'area' AS "element_type",
  o2p_calculate_nodes_to_line(ways.nodes) AS geom
FROM
  ways
WHERE
  ways.tags IS NOT NULL AND
  o2p_get_preset(ways.tags, ARRAY['line'])::json IS NOT NULL AND
  NOT (
    EXISTS (
      SELECT 1
      FROM "relation_members"
      JOIN "relations" ON "relation_members"."relation_id" = "relations"."id"
      WHERE
        "relation_members"."member_id" = "ways"."id" AND
        UPPER("relation_members"."member_type"::text) = 'W'::text AND
        "relations"."tags" -> 'type' = 'route'
    )
  )
UNION ALL
-- Aggregate the line relations
SELECT
  relations.id AS relation_id,
  relations.version AS version,
  relations.tags AS tags,
  o2p_get_preset(relations.tags, ARRAY['line'])::json AS preset,
  relations.user_id AS user_id,
  relations.tstamp,
  'line' AS "element_type",
  st_union(o2p_aggregate_line_relation(relations.id)) AS geom
FROM
  relations 
WHERE
  relations.tags IS NOT NULL AND
  exist(relations.tags, 'type'::text) AND
  relations.tags -> 'type' = 'route' AND
  o2p_get_preset(relations.tags, ARRAY['line'])::json IS NOT NULL
UNION ALL
-- Aggregate the area relations
SELECT
  relations.id AS relation_id,
  relations.version AS version,
  relations.tags AS tags,
  o2p_get_preset(relations.tags, ARRAY['area'])::json AS preset,
  relations.user_id AS user_id,
  relations.tstamp,
  'area' AS "element_type",
  st_union(o2p_aggregate_polygon_relation(relations.id)) AS geom
FROM
  relations
WHERE
  relations.tags IS NOT NULL AND
  exist(relations.tags, 'type'::text) AND
  o2p_get_preset(relations.tags, ARRAY['area'])::json IS NOT NULL;
