CREATE FUNCTION main_stream(pfcodemain character varying,
    reachid integer,
    mainbasin boolean,
    endnode integer)
    RETURNS SETOF confluence 
-- Find the main stream in a Pfafstetter basin, following in the confluences the reaches with the largest area upstream,
-- set its Pfafstetter stream code (pfcodestr in hydrography table), if mainbasin is true, and return the set of its confluences
-- Args:
--  pfcodemain (character varying): stream pfafstetter code
--  reachid (integer): id of the downstream reach of the main stream
--  mainbasin (boolean): if true, signals that it is the main stream of a proper basin, not of an interbasin 
--  endnode (integer): id of the upstream node of an interbasin
-- Returns:
--  conf (set of confluence records): node id, reach id, area up, length up on the main stream and on the tributary

    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
    ROWS 1000
    
AS $BODY$
DECLARE
  frm_node integer;
  downreach integer;
  idmain integer;
  areaup double precision;
  lengthup double precision;
  i integer;
  reach record;
  conf confluence;
BEGIN
--  IF endnode IS NULL THEN RAISE NOTICE 'main_stream (%)', pfcodemain || ',' || reachid || ',' || mainbasin;
--  ELSE RAISE NOTICE 'main_stream (%)', pfcodemain || ',' || reachid || ',' || mainbasin || ',' || endnode; END IF;
  downreach := reachid;
  -- Follow main stream and its confluences
  <<MAIN_STREAM>>
  LOOP
    -- Follow the set of reaches that make up the main stream with no tributaries and, if mainbasin, make their pfcodestr = pfcode
    <<FOLLOW_RIVER>>
    LOOP
      IF mainbasin THEN
        UPDATE hydrography SET pfcodestr = pfcodemain WHERE gid = downreach;
      END IF;
      SELECT fnode INTO STRICT frm_node FROM hydrography WHERE gid = downreach;
      -- Return if, when not in mainbasin context (interbasin context), endnode is reached
      IF NOT mainbasin AND frm_node = endnode THEN RETURN; END IF;
      -- Queries reaches upstream (whose tnode = frm_node), setting downreach to the gid of the connecting reach
      BEGIN
        SELECT gid INTO STRICT downreach FROM hydrography WHERE tnode = frm_node;
        EXCEPTION
          -- Return if no connecting reach is found
          WHEN NO_DATA_FOUND THEN RETURN;
          -- If more than one reach connects, one of them is a tributary - exit the FOLLOW_RIVER loop
          WHEN TOO_MANY_ROWS THEN EXIT FOLLOW_RIVER;
      END;
    END LOOP FOLLOW_RIVER;
    -- Query the confluence reaches, downward ordered by area up, 
    -- Pick the main stream and the tributary and their upstream length and area
    i := 0;
    FOR reach IN SELECT * FROM hydrography WHERE tnode = frm_node ORDER BY areaupkm2 DESC, mxlengthup DESC, gid DESC
      LOOP
        IF i = 0 THEN
          -- Largest area - mainstream reach
          idmain := reach.gid;
          areaup := reach.areaupkm2;
          lengthup := reach.mxlengthup;
        ELSE
          -- The other - tributary reach
          conf.nodid := frm_node;
          conf.main_id := idmain;
          conf.main_areaup := areaup;
          conf.main_lengthup := lengthup;
          conf.trib_id := reach.gid;
          conf.trib_areaup := reach.areaupkm2;
          conf.trib_lengthup := reach.mxlengthup;
          -- RAISE NOTICE 'main_stream result (%)', conf;
          RETURN NEXT conf;
        END IF;
        i := i + 1;
      END LOOP;
    -- Set downreach to the mainstream reach id
    downreach := idmain;
  END LOOP MAIN_STREAM;
END;
$BODY$;
