CREATE PROCEDURE set_main_down_reach()
-- Sets is_main_rch and is_down_rch markers on hydrography table

LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
reach_id integer;
curr_reach_id integer;
from_node integer;
curr_from_node integer;
id_area integer;
curr_area_id integer;
to_node integer;
curr_to_node integer;
is_main_reach boolean;
BEGIN
  -- create table down_reaches with the ones within each areaid with the greatest upstream area
  CREATE TABLE down_reaches AS
  SELECT areaid, reachid FROM
  (SELECT areaid, gid AS reachid, rank() OVER 
  (PARTITION BY areaid ORDER BY areaupkm2 DESC) FROM hydrography) AS a
  WHERE rank = 1;
  -- set is_down_rch in each one of those reaches
  UPDATE hydrography SET is_down_rch = True WHERE gid IN
  (SELECT reachid FROM down_reaches);
  -- set is_main_rch in down reaches and their upstream main reaches inside the contributing area
  FOR reach_id IN (SELECT reachid FROM down_reaches)
  LOOP
    SELECT fnode, areaid INTO curr_from_node, curr_area_id FROM hydrography WHERE gid = reach_id;
    -- set is_main_rch on the down reach
    UPDATE hydrography SET is_main_rch = True WHERE gid = reach_id;
    -- set is_main_rch on down reach main upstream reaches inside their contributing area
    LOOP
      SELECT gid, fnode, areaid INTO curr_reach_id, from_node, id_area FROM hydrography
      WHERE tnode = curr_from_node ORDER BY areaupkm2 DESC LIMIT 1;
      IF NOT FOUND THEN EXIT; END IF;
      IF id_area <> curr_area_id THEN EXIT; END IF;
      UPDATE hydrography SET is_main_rch = True WHERE gid = curr_reach_id;
      curr_from_node := from_node;
    END LOOP;
  END LOOP;
  -- set is_main_rch in down reaches' downstream reaches until a main_rch is found
  FOR reach_id IN (SELECT reachid FROM down_reaches)
  LOOP
    SELECT tnode INTO curr_to_node FROM hydrography WHERE gid = reach_id;
    -- set is_main_rch on down reach main upstream reaches inside their contributing area
    LOOP
      SELECT gid, tnode, is_main_rch INTO curr_reach_id, to_node, is_main_reach FROM hydrography
      WHERE fnode = curr_to_node;
      IF NOT FOUND THEN EXIT; END IF;
      IF is_main_reach THEN EXIT; END IF;
      UPDATE hydrography SET is_main_rch = True WHERE gid = curr_reach_id;
      curr_to_node := to_node;
    END LOOP;
  END LOOP;
  -- drop intermediate table down_reaches
  DROP TABLE down_reaches;
END;
$BODY$;

