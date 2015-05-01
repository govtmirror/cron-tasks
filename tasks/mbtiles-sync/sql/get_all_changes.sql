-- Gets a list of all changed elements
SELECT 
  ST_YMax(ST_Transform("the_geom",4326)) AS "maxLat",
  ST_YMin(ST_Transform("the_geom",4326)) AS "minLat",
  ST_XMax(ST_Transform("the_geom",4326)) AS "maxLon",
  ST_XMin(ST_Transform("the_geom",4326)) AS "minLon",
  CASE WHEN osm_id < 0 THEN 'R'::char(1) ELSE "member_type" END as "member_type",
  "osm_id",
  "source"
FROM
  (
    SELECT "the_geom", "osm_id", "rendered", 'W'::char(1) as "member_type", 'nps_render_polygon' as "source" FROM nps_render_polygon
    UNION ALL
    SELECT "the_geom", "osm_id", "rendered", 'W'::char(1) as "member_type", 'nps_render_line' as "source" FROM nps_render_line
    UNION ALL
    SELECT "the_geom", "osm_id", "rendered", 'N'::char(1) as "member_type", 'nps_render_point' as "source" FROM nps_render_point
    UNION ALL
    SELECT "way" as "the_geom", "osm_id", "change_time" as "rendered", "member_type", 'nps_change_log' as "source" FROM nps_change_log
    ) q
WHERE
  rendered <= (
    SELECT COALESCE(MAX("run_time"), NOW())
    FROM "nps_render_log"
    WHERE "task_name" = {{taskName}}
    ) AND
  rendered > (
    SELECT COALESCE(MAX(a."run_time"), '2010-01-01'::timestamp without time zone)
    FROM "nps_render_log" a
    WHERE a."task_name" = {{taskName}} AND
          a.render_id < (SELECT max(b.render_id) FROM "nps_render_log" b where b."task_name" = a.task_name)
    ) AND
  the_geom IS NOT null;
