CREATE PROCEDURE identify_reach_area()
-- Update areaid in the hydrography table to the id of the contributing area with the largest intersection to the reach

LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
-- create an intermediate table called hydrography_contrib_areas, with all the intersecting reaches, areas and length
CREATE TABLE hydrography_contrib_areas AS
SELECT h.gid AS reachid, a.gid AS areaid, ST_Length((ST_Dump(ST_Intersection(a.geom, h.geom))).geom) AS length
FROM hydrography AS h INNER JOIN contrib_area AS a
ON ST_Intersects(a.geom, h.geom);
-- attribute the reach areaid to its corresponding area with the longest length
UPDATE hydrography SET areaid = b.areaid
FROM
(SELECT reachid, areaid FROM
(SELECT reachid, areaid, rank() OVER (PARTITION BY reachid ORDER BY length DESC) AS pos
FROM hydrography_contrib_areas) AS a WHERE pos = 1) AS b
WHERE hydrography.gid = b.reachid;
DROP TABLE hydrography_contrib_areas;
END;
$BODY$;

