CREATE PROCEDURE create_ordered_mouth_nodes ()
-- Create ordered_mouth_nodes table

LANGUAGE 'plpgsql'
AS
$BODY$
BEGIN
CREATE TABLE ordered_mouth_nodes (
    gid serial PRIMARY KEY,
    node integer,
    reachid integer,
    coastline_id integer,
    coastline character varying,
    coast_system character varying,
    point_locate double precision,
    coast_segment integer,
    areaupkm2 double precision,
    mxlengthup double precision,
    pfcode character varying,
    geom geometry(Point)
);
END;
$BODY$;
