CREATE PROCEDURE pfafstetter_code(basecode character varying, reachid integer, main_basin boolean)
-- Pfafstetter code (pfcode and pfcodestr) an entire basin consisting of reachid and its upstream reaches, on hydrography table,
-- taking as seed basecode. The basin can be a proper basin (main_basin true) or a code 9 interbasin (main_basin false)
-- Args:
--  basecode (character varying): seed code upon which the basin will be further coded by the Pfafstetter method
--  reachid (integer): id of the downstream reach of the basin to be coded
--  main_basin (boolean): signals if the basin to be coded is a proper basin (true) or a 9 interbasin (false)

LANGUAGE 'plpgsql'
    
AS $BODY$

DECLARE

  mainstr confluence;
  numsb integer;
  reachidsb integer;

BEGIN

  -- Assign basecode to the whole basin
  CALL code_assign_basin(basecode, reachid);
  numsb := 1;
  reachidsb := reachid;
  -- Find the 4 most important confluences and code downstream interbasins (odd) and subbasins (even)
  FOR mainstr IN
    SELECT * FROM
    (SELECT r.nodid, r.main_id, r.main_areaup, r.main_lengthup, r.trib_id, r.trib_areaup, r.trib_lengthup
    FROM main_stream(basecode, reachid, main_basin, NULL) AS r
    ORDER BY r.trib_areaup DESC LIMIT 4) AS mb
    ORDER BY mb.main_lengthup DESC
  LOOP
    -- Code interbasin
    CALL pfafstetter_code_interbasin(basecode || numsb, reachidsb, mainstr.nodid);
    reachidsb := mainstr.main_id;
    -- Code subbasin
    numsb := numsb + 1;
    CALL pfafstetter_code(basecode || numsb, mainstr.trib_id, TRUE);
    numsb := numsb + 1;
  END LOOP;
  -- interbasin 9 - code remaining upstream interbasin like a proper basin (use pfafstetter_code) signalling main_basin = False
  IF numsb > 1 THEN
    CALL pfafstetter_code(basecode || numsb, reachidsb, FALSE);
  END IF;

END;
$BODY$;

