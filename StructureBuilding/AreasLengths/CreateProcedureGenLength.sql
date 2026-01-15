CREATE PROCEDURE gen_length()
-- Generate lengthkm, lngthtomouth, mxlengthup and lngthrivmouth in table hydrography

LANGUAGE 'plpgsql' AS
$BODY$
DECLARE
rch integer;
mxlngthup double precision;
BEGIN
-- update length of the reaches as the reaches geometry length / 1000
UPDATE hydrography SET lengthkm = ST_Length(geom) / 1000.;
-- update length to mouth and maximum length upstream for all basins
FOR rch IN SELECT reachid FROM ordered_mouth_nodes
LOOP
    mxlngthup = gen_tree_length(rch, 0.);
END LOOP;
-- update length to river mouth
WITH rivdist AS (
SELECT rivcode, dist_offset FROM
(SELECT rivcode, lngthtomouth - lengthkm AS dist_offset, rank() OVER (PARTITION BY rivcode ORDER BY lngthtomouth) AS pos
FROM hydrography) AS a
WHERE pos = 1)
UPDATE hydrography SET lngthrivmouth = lngthtomouth - rivdist.dist_offset 
FROM rivdist WHERE hydrography.rivcode = rivdist.rivcode;
END;
$BODY$;

