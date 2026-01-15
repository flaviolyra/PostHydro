CREATE PROCEDURE reach_continuity()
-- Create a discontinuous_reaches table with the id and geometry of all the reaches where mxlengthup is null
-- To be run after the gen_length procedure fills all the length related fields in the hydrography table

LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
CREATE TABLE discontinuous_reaches
	(gid serial PRIMARY KEY, reachid integer, geom geometry(Linestring));
INSERT INTO discontinuous_reaches(reachid, geom)
SELECT gid, geom FROM hydrography AS h WHERE mxlengthup IS NULL;
END;
$BODY$;

