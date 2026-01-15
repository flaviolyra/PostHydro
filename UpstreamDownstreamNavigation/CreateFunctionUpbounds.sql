CREATE FUNCTION upbounds(pfcode character varying) RETURNS uplimits
-- Given a Pfafstetter code pfcode, generate an uplimits record with the downstream inclusive (codedown) and upstream (codeup) pfcodes
-- boundaries of the basin upstream
-- Args:
--  pfcode (text): downstream pfafstetter code
-- Returns:
--  limits (uplimits): record with the downstream (codedown) and upstream (codeup) code boundaries of the basin upstream of pfcode

LANGUAGE 'plpgsql'
COST 100
IMMUTABLE 
    
AS $BODY$
DECLARE
limits uplimits;
char_array text[] := string_to_array(pfcode,NULL);
ind integer := array_length(char_array, 1);

BEGIN
  -- search pfcode, from right to left, looking for the first even digit, signaling a proper basin
  LOOP
    IF char_array[ind]::int % 2 = 0 THEN
      -- when an even digit is found, pfcode basin upstream limit (codeup) is the basin code
      -- the downstream limit (codedown) is pfcode itself - return with the limits
      limits.codedown := pfcode;
      limits.codeup := array_to_string(char_array,'');
      RETURN limits;
    END IF;
    ind := ind - 1;
    -- ind should not get to 0 - a proper basin must be found
    IF ind = 0 THEN RETURN NULL; END IF; 
    char_array := char_array[1:ind];
  END LOOP;
END;
$BODY$;

