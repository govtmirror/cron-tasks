
-- Check that the last task has completed
-- We do this to keep us from running the same script on top of itself
SELECT
  COALESCE(MAX("render_id"),0) = 
  COALESCE(
    (
      SELECT MAX("render_id")
      FROM "nps_render_log" 
      WHERE "status" ='Complete'
    ),0
   )
   OR
     NOW() - max("run_time") > {{timeout}}
   AS "task_ready"
FROM
  nps_render_log;
