CREATE PROCEDURE generate_details_reach_triple_conf()
-- Based on the triple_conf_mouth_nodes table, with triple_conf, the number of triple confluences upstream of their root reaches,
-- create a reach_triple_conf table with the root reach id and the ids of the upstream triple confluence reaches

LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE
reach integer;
line_geom geometry(Linestring, 3035);
BEGIN
    CREATE TABLE reach_triple_conf (gid serial PRIMARY KEY, rootreach_id integer, reachid integer);
    FOR reach IN SELECT reachid FROM triple_conf_mouth_nodes WHERE triple_conf <> 0
    LOOP
        CALL details_reach_triple_conf(reach, reach);
    END LOOP;
END;
$BODY$;
