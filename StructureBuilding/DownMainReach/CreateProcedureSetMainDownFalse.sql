CREATE PROCEDURE set_main_down_false(reachid integer)
-- Set is_down_rch and is_main_rch to false in hydrography for reachid and upstream reaches
-- Args:
--  reachid (integer): id of the reach whose upstream reaches' is_down_rch and is_main_rch are set to false

LANGUAGE 'plpgsql'
AS 
$BODY$
  DECLARE
  rch integer;
  from_node integer;
  BEGIN
    -- set is_down_rch and is_main_rch to false for reachid
    UPDATE hydrography SET is_down_rch = False WHERE gid = reachid;
    UPDATE hydrography SET is_main_rch = False WHERE gid = reachid;
    -- find reachid from node
    SELECT fnode INTO from_node FROM hydrography AS h WHERE h.gid = reachid;
    -- recursively call set_main_down_false to reachid contributing reaches
    FOR rch IN (SELECT gid FROM hydrography WHERE tnode = from_node)
    LOOP
      CALL set_main_down_false(rch);
    END LOOP;
  END;
$BODY$;

