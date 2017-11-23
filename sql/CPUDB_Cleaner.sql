-- CPU Lift DB Cleaner
-- Make sure all columns are Nullable to start
-- The purpose of this cleaner is to cast numeric values and dates into appropriate types.
-- We should also look into unique identifies for each lifter/meet
-- A additional column for possible dirty data will be added to flag entries we are not sure of

-- Data with issues we need to clean.
SELECT * FROM liftdb WHERE year = ''; -- all empty entries
SELECT * FROM liftdb WHERE wilks = ''; -- empty not null
SELECT * FROM liftdb WHERE total = ''; -- some entries dont have total for bench only
SELECT * FROM liftdb WHERE bench = ''; -- interesting, there used to be deadlift only competitions?
SELECT * FROM liftdb WHERE wilks = ''; -- need to calculate wilks for these totals (no weight entered, so possibly emit or use weight class and flag dirty)

-- Add column for dirty data
ALTER TABLE liftdb ADD COLUMN dirty smallint;

-- Remove any entries that dont have a year associated
DELETE FROM liftdb WHERE year = '';


-- Totals cleanup , Some entrys dont have a total on bench only, populate them then remove any empy ones
UPDATE liftdb SET total = bench WHERE total = '';
DELETE FROM liftdb WHERE total = '';


-- Null empty entries,
UPDATE liftdb SET class = null WHERE class = '';
UPDATE liftdb SET unequipped = null WHERE unequipped = '';
UPDATE liftdb SET squat = null WHERE squat = '';
UPDATE liftdb SET bench = null WHERE bench = '';
UPDATE liftdb SET dead = null WHERE dead = '';
UPDATE liftdb SET wilks = null WHERE wilks = '';

-- check for single quoted entries (a few on squats)
SELECT * FROM liftdb WHERE squat ~ '''' OR bench ~ '''' OR dead ~ '''' OR total ~ '''' OR wilks ~ '''' ;
-- update those squat entries
UPDATE liftdb SET squat = REPLACE(squat, '''', '.');

-- check for commas (none)
SELECT * FROM liftdb WHERE squat ~ ',' OR bench ~ ',' OR dead ~ ',' OR total ~ ',' OR wilks ~ ','  ;

-- check for yes? These appear to be shifted so that the wilks is actually the total and year is wilks...guhhh
SELECT * FROM liftdb WHERE squat ~ 'yes' OR bench ~ 'yes' OR dead ~ 'yes' OR total ~ 'yes' OR wilks ~ 'yes'  ;
-- add code to shift these over

-- start of code to check for multiple  periods in numeric values
SELECT * FROM liftdb WHERE squat IN ('.','.') OR bench IN ('.','.') OR dead IN ('.','.') OR total IN ('.','.') OR wilks IN ('.','.')  ;


-- Update table types once cleaning is complete
ALTER TABLE liftdb ALTER COLUMN squat TYPE double precision USING squat::double precision;
ALTER TABLE liftdb ALTER COLUMN bench TYPE double precision USING bench::double precision;
ALTER TABLE liftdb ALTER COLUMN dead TYPE double precision USING dead::double precision;
ALTER TABLE liftdb ALTER COLUMN wilks TYPE double precision; USING wilks::double precision
ALTER TABLE liftdb ALTER COLUMN total TYPE double precision USING total::double precision;
