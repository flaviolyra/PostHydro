CREATE PROCEDURE hydroref_points (max_dist double precision)
-- Create table hydroref_points, from locating points, on pts_direct_indirect table, on the nearest reach of the hydrography table
-- Points on the  pts_direct_indirect table have an id, name, a geometry, a hydroreference form ('direct' or 'indirect')
-- and, if the point's reach is not represented in the hydrography ('indirect' form), the geometry of the point's influence
-- point on the hydrography, that is, the nearest downstream point on the represented hydrography.
-- The hydroref_points table has the id, name, real geometry and hydroreference form of the point, plus its location in the hydrography
-- table (id and pfafstetter code of the reach, distance along the hydrography to the basin mouth, river code, name and distance
-- to the river mouth, if available, distance between the direct or indirect point and the exact point on the geometry of the reach,
-- plus the geometry of the exact point on the hydrography.
-- To account for the rare cases in which there are representation errors in the hydrography that would lead to error in the
-- hydroreference of the point, a hydref_disregard table, with the id of the reaches that should not be considered in the process, is
-- provided. The search for the hydrography reaches is done within a max_dist distance of the point.
-- Args:
--  max_dist (double precision): search radius when looking for a point coastline

LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
-- create the hydroref_points table
CREATE TABLE hydroref_points (
    id integer PRIMARY KEY,
    ptname text,
    hydroref_form text,
    reachid integer,
    pfcode text,
    rivcode text,
    rivname text,
    lngthrivmouth double precision,
    lngthtomouth double precision,
    hydroref_dist double precision,
    geom_hr geometry(Point),
    geom geometry(Point)
);
-- create a temporary pt_to_hydroref table with the right point geometry (geom_ref) to hydroreference
CREATE TABLE pt_to_hydroref AS
SELECT gid, name, hydroref_form, CASE WHEN hydroref_form = 'direct' THEN geom ELSE geom_ind END AS geom_ref, geom
FROM pts_direct_indirect;
CREATE INDEX ON pt_to_hydroref USING gist(geom_ref);
-- add the hydroreferenced point to the hydroref_points table, looking for the closest hydrography reach to geom_ref point,
-- disregarding reaches in hydref_disregard table
INSERT INTO hydroref_points
SELECT id, ptname, hydroref_form, reachid, pfcode, rivcode, rivname, lngriv AS lngthrivmouth, lngbas AS lngthtomouth,
	hydroref_dist, geom_hr, geom
FROM
(SELECT DISTINCT ON (p.gid, pos) p.gid AS id, p.name AS ptname, p.hydroref_form, h.gid AS reachid, h.pfcode, h.rivcode, h.rivname,
	h.lngthrivmouth - ST_LineLocatePoint(h.geom, p.geom_ref) * h.lengthkm AS lngriv,
	h.lngthtomouth - ST_LineLocatePoint(h.geom, p.geom_ref) * h.lengthkm AS lngbas,
	ST_Distance(h.geom, p.geom_ref) AS hydroref_dist, ST_ClosestPoint(h.geom, p.geom_ref) AS geom_hr, p.geom,
	rank() OVER (PARTITION BY p.gid ORDER BY ST_Distance(h.geom, p.geom_ref)) AS pos
FROM pt_to_hydroref AS p INNER JOIN (SELECT * from hydrography WHERE gid NOT IN (SELECT reachid FROM hydref_disregard)) AS h
ON ST_Dwithin(h.geom, p.geom_ref, max_dist)) AS a
WHERE pos = 1;
DROP TABLE pt_to_hydroref;
END;
$BODY$;

