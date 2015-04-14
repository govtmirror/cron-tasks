-- Delete the last entry to the render log when there is an error
-- This makes means that our data will still render the next time it tries to run
DELETE FROM
  nps_render_log
WHERE
  render_id IN (
    SELECT
      MAX(render_id)
    FROM
      nps_render_log
    WHERE
      task_name= {{taskName}}
    );
