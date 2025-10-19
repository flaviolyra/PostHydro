CREATE FUNCTION gen_tree_area(currrch integer)
-- Update areaupkm2 in currrch and all upstream reaches with their upstream area 
-- Args:
--  currrch (integer): id of the reach whose upstream reaches' areaupkm2 we want to update
-- Returns:
--  areaup (double precision): the area of currrch upstream watershed

RETURNS double precision
LANGUAGE 'plpgsql' 

AS $BODY$
DECLARE
  fromnode integer;
  area double precision;
  areaup double precision;
  idrch integer;

BEGIN
    -- Get from hydrography the from node, length and area of the reach in the function call
    SELECT h.fnode, h.areakm2 INTO fromnode, area FROM hydrography AS h
    WHERE h.gid = currrch;
    -- Set areaup as the area of the current reach
    areaup = area;
    -- Search for the reaches upstream of the reach in the function call
    FOR idrch IN 
      SELECT h.gid FROM hydrography AS h WHERE h.tnode = fromnode
    LOOP
      -- Recursively look for total upstream area of the reach
      areaup = areaup + gen_tree_area(idrch);
    END LOOP;
    -- Update in hydrography the area upstream as areaup
    UPDATE hydrography SET areaupkm2 = areaup WHERE gid = currrch;
    RETURN areaup;
END;
$BODY$;
