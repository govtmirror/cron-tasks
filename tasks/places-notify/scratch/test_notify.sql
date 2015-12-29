-- CREATE OR REPLACE VIEW "summary_view" AS
SELECT
  "elements"."osm_id",
  "elements"."element_type" || abs("elements"."osm_id") AS "places_id",
  "elements"."version",
  "elements"."name",
  "elements"."superclass",
  "elements"."class",
  lower("elements"."type") AS "type",
  "elements"."tags"::json AS "tags",
  ST_Transform("elements"."the_geom", 4326) AS "the_geom",
  "nwr"."tstamp",
  -- ("nwr"."tstamp" AT time zone 'UTC')::timestamp without time zone AS "tstamp_gmt",
  "nwr"."user_id" as "user_id",
  "nwr"."changeset_id",
  (
    SELECT
      hstore(array_agg(k), array_agg(v))
    FROM
      json_populate_recordset(null::new_hstore,(SELECT json_agg("result") FROM (SELECT "k", "v" FROM "api_changeset_tags" WHERE "api_changeset_tags"."changeset_id" = "nwr"."changeset_id") "result"))
  )::json AS "changeset_tags",
  (SELECT name FROM users WHERE users.id = "nwr"."user_id") AS "user_name",
  -- "elements"."changeset_tags"::json AS "changeset_tags",
  -- ("elements"."changeset_tags"::json -> 'created_by')::text AS "changeset_editor",
  -- ("elements"."changeset_tags"::json -> 'comment')::text AS "changeset_comment",
  -- ("elements"."changeset_tags"::json -> 'imagery_used')::text AS "changeset_imagery",
  "elements"."unit_code" AS "unit_code"
  -- (SELECT "long_name" FROM "render_park_polys" WHERE lower("elements"."tags" -> 'nps:unit_code') = lower("render_park_polys"."unit_code") LIMIT 1) AS "unit_name",
  -- "elements"."user_id" as "user_id",
  -- "users"."name" AS "user_name"
FROM (
  SELECT
    "nps_render_point_view"."osm_id",
    'n' as "element_type",
    "nps_render_point_view"."version",
    "nps_render_point_view"."name",
    "nps_render_point_view"."superclass",
    "nps_render_point_view"."class",
    "nps_render_point_view"."type",
    "nps_render_point_view"."tags",
    lower("nps_render_point_view"."tags"->'nps:unit_code') AS "unit_code",
    "nps_render_point_view"."way" AS "the_geom"
  FROM
    nps_render_point_view
  UNION ALL
  SELECT
    "nps_render_line_view"."osm_id",
    CASE WHEN "nps_render_line_view"."osm_id" < 0 THEN 'r' || "nps_render_line_view"."osm_id" * -1 ELSE 'w' END AS "element_type",
    "nps_render_line_view"."version",
    "nps_render_line_view"."name",
    "nps_render_line_view"."superclass",
    "nps_render_line_view"."class",
    "nps_render_line_view"."type",
    "nps_render_line_view"."tags",
    lower("nps_render_line_view"."tags"->'nps:unit_code') AS "unit_code",
    "nps_render_line_view"."way" AS "the_geom"
  FROM
    "nps_render_line_view"
  UNION ALL
  SELECT
    "nps_render_polygon_view"."osm_id",
    CASE WHEN "nps_render_polygon_view"."osm_id" < 0 THEN 'r' || "nps_render_polygon_view"."osm_id" * -1 ELSE 'w' end as "element_type",
    "nps_render_polygon_view"."version",
    "nps_render_polygon_view"."name",
    "nps_render_polygon_view"."superclass",
    "nps_render_polygon_view"."class",
    "nps_render_polygon_view"."type",
    "nps_render_polygon_view"."tags",
    lower("nps_render_polygon_view"."tags"->'nps:unit_code') AS "unit_code",
    "nps_render_polygon_view"."way" AS "the_geom"
  FROM
    "nps_render_polygon_view"
) AS "elements"
  JOIN (
    SELECT id as "id", 'n' AS element_type, user_id, tstamp, changeset_id FROM nodes UNION ALL
    SELECT id as "id", 'w' AS element_type, user_id, tstamp, changeset_id FROM ways UNION ALL
    SELECT id as "id", 'r' AS element_type, user_id, tstamp, changeset_id FROM relations
  ) AS "nwr" ON abs("elements"."osm_id") = "nwr"."id" AND "elements"."element_type" = "nwr"."element_type"
WHERE
 "elements"."unit_code" = 'hofu'; 
