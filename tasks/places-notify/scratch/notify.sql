CREATE OR REPLACE VIEW "summary_view" AS
SELECT
  "elements"."osm_id",
  "elements"."places_id",
  "elements"."version",
  "elements"."name",
  "elements"."superclass",
  "elements"."class",
  lower("elements"."type") AS "type",
  "elements"."tags"::json AS "tags",
  "elements"."element_type" AS "element_type",
  ST_Transform("elements"."the_geom", 4326) AS "the_geom",
  "elements"."tstamp",
  "elements"."changeset_id",
  "elements"."changeset_tags"::json AS "changeset_tags",
  ("elements"."changeset_tags"::json -> 'created_by')::text AS "changeset_editor",
  ("elements"."changeset_tags"::json -> 'comment')::text AS "changeset_comment",
  ("elements"."changeset_tags"::json -> 'imagery_used')::text AS "changeset_imagery",
  "elements"."tags"->'nps:unit_code' AS "unit_code",
  (SELECT "long_name" FROM "render_park_polys" WHERE lower("elements"."tags" -> 'nps:unit_code') = lower("render_park_polys"."unit_code") LIMIT 1) AS "unit_name",
  "elements"."user_id" as "user_id",
  "users"."name" AS "user_name"
FROM (
  SELECT
    "nps_render_point"."osm_id",
    'n' || "nps_render_point"."osm_id" AS "places_id",
    "nps_render_point"."version",
    "nps_render_point"."name",
    "nps_render_point"."superclass",
    "nps_render_point"."class",
    "nps_render_point"."type",
    "nps_render_point"."tags",
    "nps_render_point"."the_geom",
    'point' AS "element_type",
    "nodes"."tstamp" As "tstamp",
    "nodes"."changeset_id" as "changeset_id",
    (select hstore(array_agg(k), array_agg(v)) from json_populate_recordset(null::new_hstore,(SELECT json_agg("result") FROM (SELECT "k", "v" FROM "api_changeset_tags" WHERE "api_changeset_tags"."changeset_id" = "nodes"."changeset_id") "result")))::json AS "changeset_tags",
    "nodes"."user_id" as "user_id"
  FROM
    nps_render_point LEFT JOIN nodes ON nodes.id = osm_id
  UNION ALL
  SELECT
    "nps_render_line"."osm_id",
    CASE WHEN "nps_render_line"."osm_id" < 0 THEN 'r' || "nps_render_line"."osm_id" * -1 ELSE 'w' || "nps_render_line"."osm_id" END AS "places_id",
    "nps_render_line"."version",
    "nps_render_line"."name",
    "nps_render_line"."superclass",
    "nps_render_line"."class",
    "nps_render_line"."type",
    "nps_render_line"."tags",
    "nps_render_line"."the_geom",
    'line' AS "element_type",
    CASE WHEN
      "nps_render_line"."osm_id" < 0 THEN "relations"."tstamp"
    ELSE "ways"."tstamp"
    END as "tstamp",
    CASE WHEN
      "nps_render_line"."osm_id" < 0 THEN "relations"."changeset_id"
    ELSE "ways"."changeset_id"
    END as "changeset_id",
    CASE WHEN
      "nps_render_line"."osm_id" < 0 THEN
      (select hstore(array_agg(k), array_agg(v)) from json_populate_recordset(null::new_hstore,(SELECT json_agg("result") FROM (SELECT "k", "v" FROM "api_changeset_tags" WHERE "api_changeset_tags"."changeset_id" = "relations"."changeset_id") "result")))::json
    ELSE
      (select hstore(array_agg(k), array_agg(v)) from json_populate_recordset(null::new_hstore,(SELECT json_agg("result") FROM (SELECT "k", "v" FROM "api_changeset_tags" WHERE "api_changeset_tags"."changeset_id" = "ways"."changeset_id") "result")))::json
    END AS "changeset_tags",
    CASE WHEN
      "nps_render_line"."osm_id" < 0 THEN "relations"."user_id"
    ELSE "ways"."user_id"
    END as "user_id"
  FROM
    "nps_render_line"
      LEFT JOIN "ways" ON "nps_render_line"."osm_id" = "ways"."id"
      LEFT JOIN "relations" ON "nps_render_line"."osm_id" * -1 = "relations"."id"
  UNION ALL
  SELECT
    "nps_render_polygon"."osm_id",
    CASE WHEN "nps_render_polygon"."osm_id" < 0 THEN 'r' || "nps_render_polygon"."osm_id" * -1 ELSE 'w' || "nps_render_polygon"."osm_id" END AS "places_id",
    "nps_render_polygon"."version",
    "nps_render_polygon"."name",
    "nps_render_polygon"."superclass",
    "nps_render_polygon"."class",
    "nps_render_polygon"."type",
    "nps_render_polygon"."tags",
    "nps_render_polygon"."the_geom",
    'polygon' AS "element_type",
    CASE WHEN
      "nps_render_polygon"."osm_id" < 0 THEN "relations"."tstamp"
    ELSE "ways"."tstamp"
    END as "tstamp",
    CASE WHEN
      "nps_render_polygon"."osm_id" < 0 THEN "relations"."changeset_id"
    ELSE "ways"."changeset_id"
    END as "changeset_id",
    CASE WHEN
      "nps_render_polygon"."osm_id" < 0 THEN
      (select hstore(array_agg(k), array_agg(v)) from json_populate_recordset(null::new_hstore,(SELECT json_agg("result") FROM (SELECT "k", "v" FROM "api_changeset_tags" WHERE "api_changeset_tags"."changeset_id" = "relations"."changeset_id") "result")))::json
    ELSE
      (select hstore(array_agg(k), array_agg(v)) from json_populate_recordset(null::new_hstore,(SELECT json_agg("result") FROM (SELECT "k", "v" FROM "api_changeset_tags" WHERE "api_changeset_tags"."changeset_id" = "ways"."changeset_id") "result")))::json
    END AS "changeset_tags",
   CASE WHEN
      "nps_render_polygon"."osm_id" < 0 THEN "relations"."user_id"
    ELSE "ways"."user_id"
    END as "user_id"
  FROM
    "nps_render_polygon"
      LEFT JOIN "ways" ON "nps_render_polygon"."osm_id" = "ways"."id"
      LEFT JOIN "relations" ON "nps_render_polygon"."osm_id" * -1 = "relations"."id"
) AS "elements"
  LEFT JOIN "users" ON "elements"."user_id" = "users"."id";
