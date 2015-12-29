-- Function: public.pgs_update()

-- DROP FUNCTION public.pgs_update();

CREATE OR REPLACE FUNCTION public.pgs_update()
  RETURNS boolean[] AS
$BODY$
  DECLARE
    v_return_value boolean[];
    v_empty_records text[];
  BEGIN
    SELECT array_agg(not o2p_render_changeset(api_changesets.id) && ARRAY[false])
    FROM api_changesets
    WHERE api_changesets.closed_at > (
      SELECT max(all_types_rendered.rendered) FROM (
        SELECT rendered from nps_render_point
        UNION ALL
        SELECT rendered from nps_render_line
        UNION ALL
        SELECT rendered from nps_render_polygon
      ) all_types_rendered)
    INTO v_return_value;

    -- Clean out elements that no longer exist
    SELECT
      array_agg("places_id")
    FROM
      "summary_view"
    WHERE
      "changeset_id" IS NULL
    INTO
      v_empty_records;

    DELETE FROM "nps_render_polygon" WHERE CASE WHEN "osm_id" < 0 THEN 'r' ELSE 'w' END || ABS("osm_id") = ANY(v_empty_records);
    DELETE FROM "nps_render_line" WHERE CASE WHEN "osm_id" < 0 THEN 'r' ELSE 'w' END || ABS("osm_id") = ANY(v_empty_records);
    DELETE FROM "nps_render_point" WHERE 'n' || "osm_id" = ANY(v_empty_records);
    DELETE FROM "summary_sync" WHERE "places_id" = ANY(v_empty_records);
    
    RETURN v_return_value;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.pgs_update()
  OWNER TO postgres;

