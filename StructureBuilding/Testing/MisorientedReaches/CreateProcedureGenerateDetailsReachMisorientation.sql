CREATE PROCEDURE generate_details_reach_misorientation()
LANGUAGE 'plpgsql'
-- Based on the orientation_mouth_nodes, with the number of misoriented reaches upstream of each basin root reach
-- create a reach_misorientation table, with the root reach id and the id of the reach with connection or orientation issues

AS
$BODY$
DECLARE
reach integer;
line_geom geometry(Linestring);
BEGIN
    CREATE TABLE reach_misorientation (gid serial PRIMARY KEY, rootreach_id integer, reachid integer);
    FOR reach IN SELECT reachid FROM orientation_mouth_nodes WHERE orientation <> 0
    LOOP
        SELECT h.geom INTO line_geom FROM hydrography AS h  WHERE h.gid = reach;
        CALL details_reach_misorientation(reach, reach, ST_StartPoint(line_geom));
    END LOOP;
END;
$BODY$;
