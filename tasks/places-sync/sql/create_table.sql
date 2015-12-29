ALTER TABLE parking_lots_temp ADD COLUMN "access_road_type" text;
ALTER TABLE parking_lots_temp ADD COLUMN "address_city" text;
ALTER TABLE parking_lots_temp ADD COLUMN "address_housenumber" text;
ALTER TABLE parking_lots_temp ADD COLUMN "address_state" text;
ALTER TABLE parking_lots_temp ADD COLUMN "address_street" text;
ALTER TABLE parking_lots_temp ADD COLUMN "address_zipcode" text;
ALTER TABLE parking_lots_temp ADD COLUMN "allowed_access" text;
ALTER TABLE parking_lots_temp ADD COLUMN "allowed_access_motor_vehicle" text;
ALTER TABLE parking_lots_temp ADD COLUMN "approved_uses_4wd" text;
ALTER TABLE parking_lots_temp ADD COLUMN "approved_uses_atv" text;
ALTER TABLE parking_lots_temp ADD COLUMN "approved_uses_bicycle" text;
ALTER TABLE parking_lots_temp ADD COLUMN "approved_uses_foot" text;
ALTER TABLE parking_lots_temp ADD COLUMN "approved_uses_horse" text;
ALTER TABLE parking_lots_temp ADD COLUMN "approved_uses_snowmobile" text;
ALTER TABLE parking_lots_temp ADD COLUMN "approved_water_uses_canoe" text;
ALTER TABLE parking_lots_temp ADD COLUMN "approved_water_uses_motorboat" text;
ALTER TABLE parking_lots_temp ADD COLUMN "building_levels" text;
ALTER TABLE parking_lots_temp ADD COLUMN "capacity" text;
-- ALTER TABLE parking_lots_temp ADD COLUMN "cartodb_id"
ALTER TABLE parking_lots_temp ADD COLUMN "class" text;
-- ALTER TABLE parking_lots_temp ADD COLUMN "description"
ALTER TABLE parking_lots_temp ADD COLUMN "fee" text;
ALTER TABLE parking_lots_temp ADD COLUMN "gender" text;
ALTER TABLE parking_lots_temp ADD COLUMN "hiking_difficulty" text;
ALTER TABLE parking_lots_temp ADD COLUMN "hours" text;
ALTER TABLE parking_lots_temp ADD COLUMN "imba_trail_difficulty" text;
ALTER TABLE parking_lots_temp ADD COLUMN "incline" text;
ALTER TABLE parking_lots_temp ADD COLUMN "lanes" text;
ALTER TABLE parking_lots_temp ADD COLUMN "lit" text;
ALTER TABLE parking_lots_temp ADD COLUMN "mountain_biking_difficulty" text;
ALTER TABLE parking_lots_temp ADD COLUMN "mountain_biking_uphill_difficulty" text;
-- ALTER TABLE parking_lots_temp ADD COLUMN "name"
ALTER TABLE parking_lots_temp ADD COLUMN "one_way" text;
ALTER TABLE parking_lots_temp ADD COLUMN "operator" text;
ALTER TABLE parking_lots_temp ADD COLUMN "places_created_at" text;
ALTER TABLE parking_lots_temp ADD COLUMN "places_updated_at" text;
ALTER TABLE parking_lots_temp ADD COLUMN "population" text;
ALTER TABLE parking_lots_temp ADD COLUMN "smoking" text;
ALTER TABLE parking_lots_temp ADD COLUMN "speed_limit" text;
ALTER TABLE parking_lots_temp ADD COLUMN "structure" text;
ALTER TABLE parking_lots_temp ADD COLUMN "superclass" text;
ALTER TABLE parking_lots_temp ADD COLUMN "surface" text;
-- ALTER TABLE parking_lots_temp ADD COLUMN "the_geom"
ALTER TABLE parking_lots_temp ADD COLUMN "track_type" text;
ALTER TABLE parking_lots_temp ADD COLUMN "trail_visibility" text;
ALTER TABLE parking_lots_temp ADD COLUMN "type" text;
ALTER TABLE parking_lots_temp ADD COLUMN "unit_code" text;
ALTER TABLE parking_lots_temp ADD COLUMN "version" text;
ALTER TABLE parking_lots_temp ADD COLUMN "width_meters" text;

ALTER TABLE parking_lots_temp ADD COLUMN created_at timestamptz not null DEFAULT now();
ALTER TABLE parking_lots_temp ADD COLUMN updated_at timestamptz not null DEFAULT now();

CREATE trigger update_updated_at_trigger 
BEFORE UPDATE ON parking_lots_temp 
FOR EACH ROW 
EXECUTE PROCEDURE _update_updated_at();
