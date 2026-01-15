CREATE FUNCTION up_reaches(pfcode text, dist double precision) RETURNS SETOF integer 
-- Generate a set of reaches ids corresponding to the reaches upstream, and including, the one whose pfafstetter code is
-- pfcode and distance of the upstream point to the mouth is dist
-- Args:
--  pfcode (text): reach pfafstetter code
--  dist (double precision): reach upstream point distance to the basin mouth
-- Returns:
--  gid (set of integer): set of contributing reaches upstream, and including, the reach

LANGUAGE 'plpgsql'
COST 100
VOLATILE 
ROWS 1000
    
AS $BODY$
DECLARE

limits uplimits = upbounds(pfcode);
down_limit text = limits.codedown;
up_limit text = limits.codeup || '%';

BEGIN
  RETURN QUERY
    SELECT h.gid FROM hydrography AS h
    WHERE h.pfcode LIKE up_limit AND h.pfcode >= down_limit AND h.lngthtomouth > dist - 0.001;
END;
$BODY$;

