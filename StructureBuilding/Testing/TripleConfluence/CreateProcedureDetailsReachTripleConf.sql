CREATE PROCEDURE details_reach_triple_conf(rootreach integer, reachid integer)
-- For every reach upstream of rootreach with a triple confluence,
-- insert the root reach and the reach id into the reach_triple_conf table
-- Args:
--  rootreach (integer): id of the mouth reach of the basin whose upstream triple confluences are counted
--  reachid (integer): id of the reach whose upstream triple confluences are counted

LANGUAGE 'plpgsql'
    
AS $BODY$
DECLARE
  from_node integer;
  id_connect integer;
  i integer;

BEGIN
  i = 0;
  SELECT h.fnode INTO STRICT from_node
    FROM hydrography AS h WHERE h.gid = reachid;
  -- For all reaches contributing to reachid, call recursively details_reach_triple_conf and increment i
  FOR id_connect IN 
    SELECT h.gid FROM hydrography AS h WHERE h.tnode = from_node
  LOOP
    CALL details_reach_triple_conf(rootreach, id_connect);
    i = i + 1;
  END LOOP;
  -- if more than two confluences, add rootreach and reachid to the reach_triple_conf table
  IF i > 2 THEN
    INSERT INTO reach_triple_conf (rootreach_id, reachid) VALUES (rootreach, reachid);
  END IF;
END;
$BODY$;

