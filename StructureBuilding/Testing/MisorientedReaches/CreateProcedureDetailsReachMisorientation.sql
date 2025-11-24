CREATE PROCEDURE details_reach_misorientation (rootreach_id integer, reachid integer, geom_node geometry(Point))
-- Insert into reach_misorientation table, with the basin root reach id and the id of the misoriented reach
-- a reach id, with its root reach, whenever the downstream point of an upstream connecting reach does not correspond to its upstream point
-- This situation corresponds to a misoriented reach or a misconnection (a geometry gap)
-- Args:
--  rootreach_id (integer): id of the root reach of reachid
--  reachid (integer): id of the reach whose upstream misoriented reaches are counted
--  geom_node (geometry(Point)): geometry of the reachid's upstream point

LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE
fromnode integer;
rch integer;
line_geom geometry(Linestring);
point_geom geometry(Point);
BEGIN
SELECT h.fnode INTO fromnode FROM hydrography AS h  WHERE h.gid = reachid;
FOR rch, line_geom IN SELECT gid , geom FROM hydrography WHERE tnode = fromnode
LOOP
    point_geom = ST_EndPoint(line_geom);
    IF NOT ST_Equals(point_geom, geom_node) THEN
        INSERT INTO reach_misorientation(rootreach_id, reachid) VALUES(rootreach_id, rch);
        CALL details_reach_misorientation(rootreach_id, rch, ST_EndPoint(line_geom));
    ELSE
        CALL details_reach_misorientation(rootreach_id, rch, ST_StartPoint(line_geom));
    END IF;  
END LOOP;
RETURN;
END;
$BODY$;
        
