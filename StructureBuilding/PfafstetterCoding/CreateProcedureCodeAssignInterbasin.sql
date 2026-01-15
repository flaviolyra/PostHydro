CREATE PROCEDURE code_assign_interbasin(code character varying, reachid integer, upstr_node integer)
-- Assign code to pfcode on reachid, all its upstream reaches on the main stream up to upstr_node
-- and all tributary basins found on the path, on hydrography table
-- Args:
--  code (character varying): code to be assigned to pfcode on reachid and its upstream reaches until upstr_node
--  reachid (integer): id of the downstream reach of the interbasin where code is to be assigned to pfcode
--  upstr_node (integer): id of the upstream node on the main stream of the interbasin where code is to be assigned to pfcode

LANGUAGE 'plpgsql' AS

$BODY$

DECLARE

  frm_node integer;
  downreach integer;
  reach integer;
  i integer;

BEGIN
  downreach := reachid;
  <<INTERBASIN>>
  LOOP
    -- Follow the set of reaches that make up the main stream with no tributaries and make their pfcode = code
    <<FOLLOW_RIVER>>
    LOOP
      SELECT fnode INTO STRICT frm_node FROM hydrography WHERE gid = downreach;
      -- In hydrography, assign code to pfcode in reachid
      UPDATE hydrography SET pfcode = code WHERE gid = downreach;
      -- If frm_node is upstr_node, return
      IF frm_node = upstr_node THEN RETURN; END IF;
      BEGIN
        SELECT gid INTO STRICT downreach FROM hydrography WHERE tnode = frm_node;
        EXCEPTION
          -- If more than one reach connects, one of them is a tributary - exit the FOLLOW_RIVER loop
          WHEN TOO_MANY_ROWS THEN EXIT FOLLOW_RIVER;
      END;
    END LOOP FOLLOW_RIVER;
    -- code the tributary basin
    i := 0;
    FOR reach IN SELECT gid FROM hydrography WHERE tnode = frm_node ORDER BY areaupkm2 DESC
    LOOP
      -- Reach with the largest area upstream is the main stream reach
      IF i = 0 THEN
        downreach := reach;
      -- The other is a tributary - assign code to its basin
      ELSE
        CALL code_assign_basin(code, reach);
      END IF;
      i := i + 1;
    END LOOP;
  END LOOP INTERBASIN;

END;

$BODY$;

