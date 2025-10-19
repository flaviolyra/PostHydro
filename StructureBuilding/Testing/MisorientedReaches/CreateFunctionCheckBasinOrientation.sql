CREATE FUNCTION check_basin_orientation (reachid integer) RETURNS integer
-- Find the number of misoriented or physically disconnected reaches upstream of reachid
-- Args:
--  reachid (integer): id of the reach whose upstream misoriented reaches are counted
-- Returns:
--  check_reach_orientation (integer): the number of upstream misoriented reaches

LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
line_geom geometry(Linestring);
BEGIN
SELECT h.geom INTO line_geom FROM hydrography AS h  WHERE h.gid = reachid;
RETURN check_reach_orientation(reachid, ST_StartPoint(line_geom));
END;
$BODY$;

