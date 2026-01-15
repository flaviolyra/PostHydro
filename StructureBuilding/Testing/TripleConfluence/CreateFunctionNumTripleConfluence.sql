CREATE FUNCTION num_triple_confluence(reachid integer) RETURNS integer
-- Find the number of triple confluences upstream of reachid
-- Args:
--  reachid (integer): id of the reach whose upstream triple confluences are counted
-- Returns:
--  n_triple_conf (integer): the number of upstream triple confluences

LANGUAGE 'plpgsql'
COST 100
VOLATILE 
    
AS $BODY$
DECLARE
  from_node integer;
  id_connect integer;
  n_triple_conf integer;
  i integer;

BEGIN
  n_triple_conf = 0;
  i = 0;
  -- For all reaches contributing to reachid, add the number of triple confluences upstream
  SELECT h.fnode INTO STRICT from_node
    FROM hydrography AS h WHERE h.gid = reachid;
  FOR id_connect IN 
    SELECT h.gid FROM hydrography AS h WHERE h.tnode = from_node
  LOOP
    i = i + 1;
    n_triple_conf = n_triple_conf + num_triple_confluence(id_connect);
  END LOOP;
  -- if more than two confluences, add one to the number of triple_confluences
  IF i > 2 THEN n_triple_conf = n_triple_conf + 1; END IF;
  RETURN n_triple_conf;
END;
$BODY$;

