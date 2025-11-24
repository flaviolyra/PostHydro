CREATE PROCEDURE pfafstetter_code_interbasin(basecode character varying, reachid integer, upstr_node integer)
-- Pfafstetter code (pfcode and pfcodestr) an interbasin consisting of reachid and its upstream reaches on main stream up to upstr_node,
-- and all tributary basins found on the path, on hydrography table, taking as seed basecode.
-- Args:
--  basecode (character varying): seed code upon which the interbasin will be further coded by the Pfafstetter method
--  reachid (integer): id of the downstream reach of the interbasin to be coded
--  upstr_node (integer): node code of the upstream limit (on main stream) of the interbasin to be coded

LANGUAGE 'plpgsql' 

AS $BODY$

DECLARE

  numsb integer;
  reachidsb integer;
  mainstr record;

BEGIN

  -- RAISE NOTICE 'pfafstetter_code_interbasin (%)', basecode || ',' || reachid || ',' || upstr_node;
  -- Assign basecode to the whole interbasin
  CALL code_assign_interbasin(basecode, reachid, upstr_node);
  numsb := 1;
  reachidsb := reachid;
  FOR mainstr IN
    SELECT * FROM
    (SELECT r.nodid, r.main_id, r.main_areaup, r.main_lengthup, r.trib_id, r.trib_areaup, r.trib_lengthup
    FROM main_stream(basecode, reachid, FALSE, upstr_node) AS r
    ORDER BY r.trib_areaup DESC LIMIT 4) AS mb
    ORDER BY mb.main_lengthup DESC
  LOOP
    -- Code downstream interbasin
    CALL pfafstetter_code_interbasin(basecode || numsb, reachidsb, mainstr.nodid);
    -- Code subbasin
    numsb := numsb + 1;
    CALL pfafstetter_code(basecode || numsb, mainstr.trib_id, TRUE);
    numsb := numsb + 1;
    reachidsb := mainstr.main_id;
  END LOOP;
  -- If there were confluences, code upstream interbasin
  IF numsb > 1 THEN
    CALL pfafstetter_code_interbasin(basecode || numsb, reachidsb, upstr_node);
  END IF;

END;
$BODY$

