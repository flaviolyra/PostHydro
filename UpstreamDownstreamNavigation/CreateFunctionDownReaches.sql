CREATE FUNCTION down_reaches(code character varying, dist double precision) RETURNS SETOF integer
-- Given a reach Pfafstetter code (code) and distance to the mouth (dist),
-- return the set of ids of the reaches in the downstream main stream segments corresponding to its main downstream path
-- Args:
--  code (character varying): reach pfafstetter code
--  dist (double precision): reach upstream point distance to the basin mouth
-- Returns:
--  gid (set of integer): reach ids on the downstream path from the reach (included) to the mouth of the basin

LANGUAGE 'plpgsql'
COST 100
VOLATILE 
ROWS 1000
    
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT h.gid FROM hydrography AS h
    INNER JOIN downpath(code) AS d
    ON (h.pfcodestr = d.stream AND h.pfcode < d.upstrbasin)
    WHERE lngthtomouth < dist - 0.001;
END;
$BODY$;
