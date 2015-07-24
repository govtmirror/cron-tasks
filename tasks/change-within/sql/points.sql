SELECT nps_render_point.osm_id, 
       nps_render_point.name, 
       nps_render_point.nps_type, 
       nps_render_point.tags, 
       --nodes.tstamp, 
       --nodes.changeset_id, 
       --users.display_name, 
       nps_render_point.the_geom 
FROM   nps_render_point 
       JOIN nodes 
         ON nps_render_point.osm_id = nodes.id 
       JOIN api_users 
         ON nodes.user_id = api_users.id
       JOIN render_park_polys
         ON ST_Intersects(nps_render_point.the_geom, st_transform(render_park_polys.poly_geom,900913))
WHERE
  lower(render_park_polys.unit_code) = lower('{{unit_code}}') AND
  tstamp > '{{year}}-{{month}}-{{day}} 00:00';
