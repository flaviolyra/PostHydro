CREATE FUNCTION gen_tree_length(currrch integer, l2mouth double precision)
-- Given a reach id (currrch) and the distance of its downstream point to the mouth of the watershed (l2mouth)
-- Update lngthtomouth and mxlengthup of the reach and its upstream reaches on hydrography table
-- with distance to the mouth and longest distance upstream 
-- Args:
--  currrch (integer): id of the reach whose upstream reaches' lngthtomouth and mxlengthup we want to update
-- Returns:
--  mxlengthup (double precision): maximum length up the reach

RETURNS double precision
LANGUAGE 'plpgsql'
COST 100
VOLATILE 
   
AS $BODY$
DECLARE
  fromnode integer;
  lngthrch double precision;
  mxlengthup double precision;
  idrch integer;
  upcharact up_char;
  longest double precision;

BEGIN
    -- Get from hydrography the from node, length and surface of the reach in the function call
    SELECT h.fnode, h.lengthkm INTO fromnode, lngthrch FROM hydrography AS h
    WHERE h.gid = currrch;
    -- Update in hydrography the length to the mouth of the reach as its length + the length to the mouth in the call
    UPDATE hydrography SET lngthtomouth = l2mouth + lngthrch WHERE gid = currrch;
    -- Set the longest upstream length to zero 
    longest = 0.;
    -- Search for the reaches upstream of the reach in the function call
    FOR idrch IN 
      SELECT h.gid FROM hydrography AS h WHERE h.tnode = fromnode
    LOOP
      -- Recursively look for upstream length characteristics (longest path to the head) of the reach
      mxlengthup = gen_tree_length(idrch, l2mouth + lngthrch);
      -- Set longest to the longest path to the head of the contributing reaches
      IF mxlengthup > longest THEN longest = mxlengthup; END IF;
    END LOOP;
    -- Update in hydrography the longest upstream path plus the length of the reach
    UPDATE hydrography SET mxlengthup = longest + lngthrch WHERE gid = currrch;
    -- Return with the id of the reach length plus its longest upstream path
    RETURN longest + lngthrch;
END;
$BODY$;
