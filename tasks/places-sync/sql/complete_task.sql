-- Write to the table that we're done running the script
-- We do this to keep us from running the same script on top of itself
UPDATE
  "nps_render_log"
SET
  "status" = 'Complete',
  "end_time" = NOW()
WHERE
  "render_id" = {{renderId}};
