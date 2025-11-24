CREATE FUNCTION check_reach_orientation (reachid integer, geom_node geometry(Point)) RETURNS integer
-- Return the number of misoriented or physically disconnected reaches upstream of reachid, whose upstream node geometry is geom_node
-- Args:
--  reachid (integer): id of the reach whose upstream misoriented reaches are counted
--  geom_node (geometry(Point)): geometry of the reachid's upstream point
-- Returns:
--  nfo (integer): the number of upstream misoriented reaches

LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
fromnode integer;
rch integer;
nfo integer;
line_geom geometry(Linestring);
point_geom geometry(Point);
BEGIN
SELECT h.fnode INTO fromnode FROM hydrography AS h  WHERE h.gid = reachid;
-- initialize nfo to 0
nfo = 0;
FOR rch, line_geom IN SELECT gid , geom FROM hydrography WHERE tnode = fromnode
-- for each contributing reach, check if it is downstream oriented, that is, it's end point is the same as the reaches' upstream point;
LOOP
    point_geom = ST_EndPoint(line_geom);
    IF ST_Equals(point_geom, geom_node) THEN
        -- case it is, add to nfo the number of misoriented reaches upstream of the contributing reach 
        nfo = nfo + check_reach_orientation(rch, ST_StartPoint(line_geom));
    ELSE
        -- case not, add to nfo one plus the number of misoriented reaches upstream of the contributing reach 
        nfo = nfo + 1 + check_reach_orientation(rch, ST_EndPoint(line_geom));
    END IF;
END LOOP;
RETURN nfo;
END;
$BODY$;

