CREATE PROCEDURE set_main_down_reach (reachid integer)
-- Set is_main_rch and is_down_rch markers on hydrography table
-- sets is_main_rch and is_down_reach true, follows main path, setting is_main_reach true while in the same areaid,
-- calls itself recursively when a reachid on the main path with a different areaid is found
-- Args:
--  reachid (integer): id of the reach whose upstream reaches' is_main_rch and is_down_rch we want to update

LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
curr_area_id integer;
primary_area_id integer;
curr_reach_id integer;
from_node integer;
id_area integer;
BEGIN
-- get from node and area id from the calling reach
SELECT fnode, areaid INTO from_node, id_area FROM hydrography WHERE gid = reachid;
-- set current areaid and reach
curr_area_id = id_area;
curr_reach_id = reachid;
-- set both is_down_rch and is_main_rch true for the calling reachid
UPDATE hydrography SET is_down_rch = true WHERE gid = reachid;
UPDATE hydrography SET is_main_rch = true WHERE gid = reachid;
-- in mainstreem the main path is followed and is_main_reach is set to true inside a contributing area
<<MAINSTREAM>>
LOOP
    -- for the first tributary, with the largest upstream area, primary_are_id is 0
    primary_area_id = 0;
    FOR curr_reach_id, from_node, curr_area_id IN
        SELECT gid, fnode, areaid FROM hydrography WHERE tnode = from_node ORDER BY areaupkm2 DESC
    LOOP
        -- if a new areaid is reached, different from the main confluence (primary) area id, recursively call set_main_down_reach
        IF curr_area_id <> id_area AND curr_area_id <> primary_area_id THEN
            CALL set_main_down_reach (curr_reach_id);
        -- else sets is_main_reach true on the main (greatest area up) confluence and proceeds on the search of the main path
        ELSE
            IF primary_area_id = 0 THEN
                UPDATE hydrography SET is_main_rch = true WHERE gid = curr_reach_id;
                CONTINUE MAINSTREAM;
            END IF;
        END IF;
        -- after the first tributary, primary_area_id gets its area id
        primary_area_id = curr_area_id;
    END LOOP;
    -- if no more confluences, exit routine
    EXIT MAINSTREAM;
END LOOP MAINSTREAM;
RETURN;
END;
$BODY$;

