CREATE PROCEDURE code_assign_basin(code character varying, reachid integer)
-- Assign code to pfcode on reachid and all its upstream reaches on hydrography table
-- Args:
--  code (character varying): code to be assigned to pfcode on reachid and its upstream reaches
--  reachid (integer): id of the downstream reach of the basin where code is to be assigned to pfcode

LANGUAGE 'plpgsql' AS

$BODY$

DECLARE

  from_node integer;
  to_node integer;
  id_connect integer;

BEGIN
  -- For all reaches contributing to reachid, calls code_assign_basin recursively
  SELECT h.fnode, h.tnode INTO STRICT from_node, to_node FROM hydrography AS h WHERE h.gid = reachid;
  FOR id_connect IN 
    SELECT h.gid FROM hydrography AS h WHERE h.tnode = from_node
  LOOP
    CALL code_assign_basin(code, id_connect);
  END LOOP;
  -- Assign code to pfcode in reachid, in hydrography table
  UPDATE hydrography SET pfcode = code WHERE gid = reachid;
END;

$BODY$;

