-- CPU Lift DB Cleaner
-- Make sure all columns are Nullable to start
-- The purpose of this cleaner is to cast numeric values and dates into appropriate types.
-- We should also look into unique identifies for each lifter/meet
-- A additional column for possible dirty data will be added to flag entries we are not sure of


-- Pull the latest csv from the PL script, not the exporter on powerlifting.ca
-- Login @ http://www.powerlifting.ca/webdata/cpudb_admin.html
-- Select Search / modify then export as comma delimited without IncludeID, etc. checked.
-- Copy the content of a page and paste in an editor.
-- Add the following to the first row and save as CSV:
-- meet,date,location,event_type,gender,name,province,weight,class_old,class,category,unequipped,squat,bench,dead,total,wilks,year
-- Import to db wiht everything as "text" type and nullable
-- procced to run the scripts below to clean the data.


-- Data with issues we need to clean.
SELECT * FROM liftdb WHERE meet = ''; -- all dirty entries
SELECT * FROM liftdb WHERE year = ''; -- all empty entries
SELECT * FROM liftdb WHERE wilks = ''; -- empty not null
SELECT * FROM liftdb WHERE total = ''; -- some entries dont have total for bench only
SELECT * FROM liftdb WHERE bench = ''; -- interesting, there used to be deadlift only competitions?
SELECT * FROM liftdb WHERE wilks = ''; -- need to calculate wilks for these totals (no weight entered, so possibly emit or use weight class and flag dirty)
SELECT * FROM liftdb WHERE unequipped != 'yes' OR unequipped != null;
SELECT * FROM liftdb WHERE gender != 'M' AND gender != 'F' ; -- a couple of lower case 'm's
SELECT * FROM liftdb WHERE date = ''; -- one empty entry
SELECT * FROM liftdb WHERE date ILIKE '%00-00%';  -- some entries have 

-- Add a primary key column
ALTER TABLE liftdb ADD COLUMN ID SERIAL PRIMARY KEY;


-- Add column for dirty data
ALTER TABLE liftdb ADD COLUMN dirty smallint;

-- fix lthe one dirty empty date entry
DELETE FROM liftdb WHERE date = '';

-- fix lower case m entries
UPDATE liftdb SET gender = 'M' WHERE gender = 'm';

-- Remove any entries that dont have a meet associated (garbage entries)
DELETE FROM liftdb WHERE meet = '';


-- Totals cleanup , Some entrys dont have a total on bench only, populate them 
UPDATE liftdb SET total = bench WHERE total = '';
--DELETE FROM liftdb WHERE total = '';


-- Null empty entries,
UPDATE liftdb SET class = null WHERE class = '';
UPDATE liftdb SET weight = null WHERE weight = '';
UPDATE liftdb SET unequipped = null WHERE unequipped = '';
UPDATE liftdb SET squat = null WHERE squat = '';
UPDATE liftdb SET bench = null WHERE bench = '';
UPDATE liftdb SET dead = null WHERE dead = '';
UPDATE liftdb SET wilks = null WHERE wilks = '';
UPDATE liftdb SET year = null WHERE year = '';



-- check for single quoted entries (a few on squats)
SELECT * FROM liftdb WHERE squat ~ '''' OR bench ~ '''' OR dead ~ '''' OR total ~ '''' OR wilks ~ '''' ;
-- update those squat entries
UPDATE liftdb SET squat = REPLACE(squat, '''', '.');

-- check for commas (none)
SELECT * FROM liftdb WHERE squat ~ ',' OR bench ~ ',' OR dead ~ ',' OR total ~ ',' OR wilks ~ ','  ;

-- check for yes? These appear to be shifted so that the wilks is actually the total and year is wilks...guhhh
SELECT * FROM liftdb WHERE squat ~ 'yes' OR bench ~ 'yes' OR dead ~ 'yes' OR total ~ 'yes' OR wilks ~ 'yes';


-- cleanup on the lift the rock issue (not for reuse)
-- UPDATE liftdb SET unequipped = 'yes'  WHERE unequipped != 'yes' OR unequipped != null;


--- The big shift for records that were offset (47 records from 2017)

SELECT * FROM liftdb WHERE year ILIKE '%.%';

UPDATE liftdb SET class = category WHERE year ILIKE '%.%';
UPDATE liftdb SET category = unequipped WHERE year ILIKE '%.%';
UPDATE liftdb SET unequipped = squat WHERE year ILIKE '%.%';
UPDATE liftdb SET squat = bench WHERE year ILIKE '%.%';
UPDATE liftdb SET bench = dead WHERE year ILIKE '%.%';
UPDATE liftdb SET dead = total WHERE year ILIKE '%.%';
UPDATE liftdb SET total = wilks WHERE year ILIKE '%.%';
UPDATE liftdb SET wilks = year WHERE year ILIKE '%.%';
UPDATE liftdb SET year ='2017' WHERE year ILIKE '%.%'; 

DELETE FROM liftdb WHERE squat ILIKE '%yes%';
SELECT * FROM  liftdb WHERE squat ILIKE '%yes%';
UPDATE liftdb SET squat = '0' WHERE squat ILIKE '%yes%';

-- code to check for multiple  periods in numeric values
SELECT * FROM liftdb WHERE dead ILIKE '%.%.%';

-- check if non numeric value
SELECT * FROM liftdb WHERE weight !~ '^[0-9,.]+$';
-- temporary mutting, will have to figue out how to address (may use weight class, but what aobut 120+?
UPDATE liftdb SET weight = null WHERE weight !~ '^[0-9,.]+$';

-- Select non uniform weight classes:
SELECT * FROM liftdb WHERE class !~ '^[47,52,57,59,63,66,72,74,83,84,84+,93,105,120,120+]+$';

-- update remove last period in entries (2rows)
UPDATE liftdb SET dead = SUBSTRING(dead FROM '(.*\..*)\..*') WHERE dead ~ '(.*\..*)\..*';


-- Select entries that dont have 2 character province (will have evaluate here, CAN entered for international)
SELECT * FROM liftdb WHERE length(province) > 2;
-- NULL empty province entries
UPDATE liftdb SET province = NULL WHERE province = '';

SELECT * FROM liftdb WHERE province !~ '^[AB,BC,MB,NB,NL,NS,NT,NU,ON,PE,QC,SK,YT,CAN]+$'; -- Check for standard names

-- Standardize province names
UPDATE liftdb SET province ='NL' WHERE province = 'NF';
UPDATE liftdb SET province ='SK' WHERE province = 'Sk.';
UPDATE liftdb SET province ='SK' WHERE province = ' SK';
UPDATE liftdb SET province ='CAN' WHERE province = ' CAN';

UPDATE liftdb SET province ='AB' WHERE province = ' AB';
UPDATE liftdb SET province ='ON' WHERE province = ' ON';
UPDATE liftdb SET province ='BC' WHERE province = ' BC';
UPDATE liftdb SET province ='MB' WHERE province = ' MB';
UPDATE liftdb SET province ='PE' WHERE province = ' PE';
UPDATE liftdb SET province ='NL' WHERE province = ' NL';
UPDATE liftdb SET province ='NS' WHERE province = ' NS';
UPDATE liftdb SET province ='NB' WHERE province = ' NB';

UPDATE liftdb SET province ='ON' WHERE province = '0N';

UPDATE liftdb SET province ='PE' WHERE province = 'PE ';
UPDATE liftdb SET province ='NL' WHERE province = ' NL ';
UPDATE liftdb SET province ='NL' WHERE province = 'NL ';

UPDATE liftdb SET province ='PE' WHERE province = ' PEI';

UPDATE liftdb SET province ='PE' WHERE province = 'PEI';
UPDATE liftdb SET province ='QC' WHERE province = 'QU';
UPDATE liftdb SET province ='QC' WHERE province = 'QU ';


-- Select entries that dont have a standard category type
SELECT * FROM liftdb WHERE category !~ 'Open' AND category !~ 'Junior' AND category !~ 'Sub-Junior' AND category !~ 'M1' AND category !~ 'M2' AND category !~ 'M3' 
AND category !~ 'M4' AND category !~ 'M5' AND category !~ 'M6' AND category !~ 'M7' AND category !~ 'M8' AND category !~ 'SO';
-- Update odd categories and spelling

UPDATE liftdb SET category = 'Open' WHERE category = 'open';
UPDATE liftdb SET category = 'Open', dirty = 1 WHERE category = '';

UPDATE liftdb SET category = 'M1' WHERE category = 'Master1';
UPDATE liftdb SET category = 'M1' WHERE category = 'Master 1';
UPDATE liftdb SET category = 'M1' WHERE category = 'Master 1`';
UPDATE liftdb SET category = 'M1' WHERE category = 'Master I';
UPDATE liftdb SET category = 'M1' WHERE category = 'Maste 1';


UPDATE liftdb SET category = 'M2' WHERE category = 'Master 2';
UPDATE liftdb SET category = 'M2' WHERE category = 'Mster 2';
UPDATE liftdb SET category = 'M2' WHERE category = 'Master2';
UPDATE liftdb SET category = 'M2' WHERE category = 'Maaster 2';
UPDATE liftdb SET category = 'M2' WHERE category = 'Master2 ';



UPDATE liftdb SET category = 'M3' WHERE category = 'Master 3';
UPDATE liftdb SET category = 'M4' WHERE category = 'Master 4';

UPDATE liftdb SET category = 'M5' WHERE category = 'Master 5';
UPDATE liftdb SET category = 'M6' WHERE category = 'Master 6';
UPDATE liftdb SET category = 'M7' WHERE category = 'Master 7';

UPDATE liftdb SET category = 'Sub-Junior' WHERE category = 'Sub-junior';
UPDATE liftdb SET category = 'Junior' WHERE category = 'Junor';





-- Select entries that dont have a standard type
SELECT * FROM liftdb WHERE event_type !~ 'All' AND event_type !~ 'Single';
-- Update 3-lift to All
UPDATE liftdb SET event_type = 'All' WHERE event_type = '3-lift';
-- Once bench only entry had no type, set to single
UPDATE liftdb SET event_type ='Single' WHERE event_type = '';
-- There is a "Two" event_type, maybe this should be labeled a "PushPull"?
UPDATE liftdb SET event_type ='PushPull' WHERE event_type = 'Two';


-- try to get the meet date into a standard timestamp format
SELECT * FROM liftdb WHERE date = '' OR date = NULL; -- good no empty entries

SELECT * FROM liftdb WHERE is_date(date) = false; -- from PGSQL Function, about 68 entries, will set to jan 1 of the year and flag dirty

UPDATE liftdb SET date = '01-01-1999', dirty = 1 WHERE date = '00-00-1999'; 
UPDATE liftdb SET date = '01-01-1999', dirty = 1 WHERE date = '00-00-2001';
UPDATE liftdb SET date = '01-01-1986', dirty = 1 WHERE date = '1986 ?';  
UPDATE liftdb SET date = '01-08-1996', dirty = 1 WHERE date = '00-Aug-96';
UPDATE liftdb SET date = '01-01-1999', dirty = 1 WHERE date = '00-00-99';

-- Update table types once cleaning is complete

ALTER TABLE liftdb ALTER COLUMN weight TYPE double precision USING weight::double precision;
ALTER TABLE liftdb ALTER COLUMN squat TYPE double precision USING squat::double precision;
ALTER TABLE liftdb ALTER COLUMN bench TYPE double precision USING bench::double precision;
ALTER TABLE liftdb ALTER COLUMN dead TYPE double precision USING dead::double precision;
ALTER TABLE liftdb ALTER COLUMN wilks TYPE double precision USING wilks::double precision;
ALTER TABLE liftdb ALTER COLUMN total TYPE double precision USING total::double precision;
ALTER TABLE liftdb ALTER COLUMN year TYPE integer USING year::integer;
ALTER TABLE liftdb ALTER COLUMN unequipped TYPE boolean USING unequipped::boolean;
ALTER TABLE liftdb ALTER COLUMN date TYPE timestamp USING date::timestamp;


-- Add columns for lifterid and meet id
ALTER TABLE liftdb ADD COLUMN lifter_id integer;
ALTER TABLE liftdb ADD COLUMN meet_id integer;	


-- Query checks

SELECT * FROM liftdb WHERE unequipped = true AND category = 'Open' AND class = '120' AND wilks > 400;

-- Biggest Male lifts in NB
SELECT * FROM liftdb WHERE unequipped = true  AND bench IS NOT NULL AND province = 'ON' AND gender = 'M' ORDER BY bench DESC LIMIT 100;
SELECT * FROM liftdb WHERE unequipped = true  AND squat IS NOT NULL AND province = 'NB' AND gender = 'M' ORDER BY squat DESC LIMIT 100;
SELECT * FROM liftdb WHERE unequipped = true  AND dead IS NOT NULL AND province = 'NB' AND gender = 'M' ORDER BY dead DESC LIMIT 100;


-- Top lifts by bodyweight
SELECT * FROM liftdb WHERE unequipped = true  AND bench IS NOT NULL AND weight IS NOT NULL AND province = 'NB' AND gender = 'M' ORDER BY (bench/weight) DESC LIMIT 100;
SELECT * FROM liftdb WHERE unequipped = true  AND squat IS NOT NULL AND weight IS NOT NULL AND province = 'NB' AND gender = 'M' ORDER BY (squat/weight) DESC LIMIT 100;
SELECT * FROM liftdb WHERE unequipped = true  AND dead IS NOT NULL AND weight IS NOT NULL AND province = 'NB' AND gender = 'M' ORDER BY (dead/weight) DESC LIMIT 100;



-- Biggest Female bench lifts in NB
SELECT * FROM liftdb WHERE unequipped = true  AND bench IS NOT NULL AND province = 'NB' AND gender = 'F' ORDER BY bench DESC LIMIT 100;


-- Get the distinct lifters
SELECT * FROM (SELECT DISTINCT ON (name) name, squat, date, year, meet FROM liftdb WHERE unequipped = true  AND squat IS NOT NULL AND province = 'NB' ORDER BY name, squat DESC) AS QR ORDER BY squat DESC LIMIT 100;

SELECT * FROM (SELECT DISTINCT ON (name) name, bench, date, year, meet FROM liftdb WHERE unequipped = true  AND bench IS NOT NULL AND province = 'NB' ORDER BY name, bench DESC) AS QR ORDER BY bench DESC LIMIT 100;

SELECT * FROM (SELECT DISTINCT ON (name) name, dead, date, year, meet FROM liftdb WHERE unequipped = true  AND dead IS NOT NULL AND province = 'NB' ORDER BY name, dead DESC) AS QR ORDER BY dead DESC LIMIT 100;

-- Top 100 individual squats for 2017 in the 120kg category
SELECT * FROM (SELECT DISTINCT ON (name) name, squat, date, year, meet FROM liftdb WHERE unequipped = true  AND class ='120' AND year = 2017  AND squat IS NOT NULL ORDER BY name, squat DESC) AS QR ORDER BY squat DESC LIMIT 100;

SELECT * FROM (SELECT DISTINCT ON (name) name, bench, date, year, meet FROM liftdb WHERE unequipped = true  AND class ='120' AND year = 2017  AND bench IS NOT NULL ORDER BY name, bench DESC) AS QR ORDER BY bench DESC LIMIT 100;

SELECT * FROM (SELECT DISTINCT ON (name) name, dead, date, year, meet FROM liftdb WHERE unequipped = true  AND class ='120' AND year = 2017  AND dead IS NOT NULL ORDER BY name, dead DESC) AS QR ORDER BY dead DESC LIMIT 100;


SELECT * FROM liftdbclean WHERE name ILIKE "é" LIMIT 100;


-- Select the amount of equipped vs unequipped per year
SELECT unequipped, 
       SUM((unequipped = true and year = 2017)::int) as unequipped,
       SUM((unequipped IS NULL and year = 2017)::int) as equipped
  FROM liftdb GROUP BY unequipped


SELECT MAX(bench),name
FROM liftdb
WHERE bench IS NOT NULL
GROUP BY name
ORDER BY MAX(bench) DESC;







-- Grouping

SELECT meet,  
  name,
  CAST(AVG(wilks) AS double precision) AS avg_wilks
 FROM liftdb
 WHERE wilks > 0 -- states only
 GROUP BY GROUPING SETS (meet, name, ());


SELECT AVG(wilks) 
FROM liftdb;

----------- PGSQL FUNCTIONS

-- Check if Date
create or replace function is_date(s varchar) returns boolean as $$
begin
  perform s::date;
  return true;
exception when others then
  return false;
end;
$$ language plpgsql;
