CREATE PROCEDURE update_areakm2()
-- Update area_km2 on hydrography table with a reach length weighed proportion of the area of its elementary contributing area

LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
ALTER TABLE hydrography RENAME TO hydrography_old;
CREATE TABLE hydrography
(
    gid integer PRIMARY KEY,
    fnode integer,
    tnode integer,
    lengthkm double precision,
    areaid integer,
    is_down_rch boolean,
    is_main_rch boolean,
    areakm2 double precision,
    areaupkm2 double precision,
    mxlengthup double precision,
    lngthtomouth double precision,
    pfcode text,
    pfcodestr text,
    rivcode text,
    rivname text,
    lngthrivmouth double precision,
    geom geometry(LineString,3035)
);
INSERT INTO hydrography (gid, fnode, tnode, lengthkm, areaid, areakm2, mxlengthup, lngthtomouth, rivcode, lngthrivmouth, geom)
SELECT b.gid, fnode, tnode, lengthkm, areaid, b.areakm2, mxlengthup, lngthtomouth, rivcode, lngthrivmouth, geom
FROM
(SELECT a.gid, ST_Area(ca.geom) * a.coef / 1000000. AS areakm2
FROM
(SELECT h.gid, h.areaid, h.lengthkm / sum(h.lengthkm) OVER (PARTITION BY areaid) AS coef
FROM hydrography_old AS h) AS a
INNER JOIN contrib_area AS ca ON ca.gid = a.areaid) AS b
INNER JOIN hydrography_old  AS h ON b.gid = h.gid;
CREATE INDEX ON hydrography USING gist (geom);
CREATE INDEX ON hydrography USING btree (tnode);
DROP TABLE hydrography_old;
END;
$BODY$;


