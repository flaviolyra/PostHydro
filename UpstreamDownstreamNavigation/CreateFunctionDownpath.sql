CREATE FUNCTION downpath(pfcode character varying) RETURNS SETOF downstreach
-- Interpret pfcode and generate a set of downstreach records,
-- each corresponding to a mainstream segment found on the way from pfcode to the mouth
-- of the basin, with their mainstream code (stream) and its upper reach code limit (upstrbasin)
-- Args:
--  pfcode (character varying): Pfafstetter code to be interpreted
-- Returns:
--  down (set of downstreach records): stream - Pfafstetter code of the stream; upstrbasin - Pfafstetter code of its upstream limit
    
LANGUAGE 'plpgsql'
COST 100
IMMUTABLE 
ROWS 1000
    
AS $BODY$
DECLARE
down downstreach;
char_array text[] := string_to_array(pfcode,NULL);
ind integer := array_length(char_array, 1);
-- first upstream limit is pfcode with an added 'one'
upstr_lim text := pfcode || '1';

BEGIN
  IF ind > 1 THEN
    LOOP
      -- examine each of the characters of the Pfafstetter code from right to left
      -- if character is even generate a record with the stream code and its upstream limit
      IF char_array[ind]::int % 2 = 0 THEN
        -- the stream code is the even portion just found
        down.stream := array_to_string(char_array,'');
        down.upstrbasin := upstr_lim;
        RETURN NEXT down;
        -- next upstream limit corresponds to the current stream code itself
        upstr_lim := array_to_string(char_array,'');
      END IF;
      ind := ind - 1;
      char_array := char_array[1:ind];
      IF ind = 0 THEN EXIT; 
      END IF;
    END LOOP;
  END IF;
  RETURN;
END;
$BODY$;
