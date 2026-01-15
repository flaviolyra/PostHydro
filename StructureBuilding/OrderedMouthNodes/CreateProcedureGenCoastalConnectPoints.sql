CREATE PROCEDURE gen_coastal_connect_points ()
-- Generate coastal_connect_points, from oriented_coastal_lines, with the coastal lines geometry, and coastal_lines_connection,
-- with the designed connectivity order for developing the composite coastal line.
-- Unless specified otherwise in a special_connect_points table, those points will be the closest points on the two connecting lines

LANGUAGE 'plpgsql'
AS
$BODY$
BEGIN
-- create table coastal_connect_point_1, adding the line geometries to the coastal_connect_point table
CREATE TABLE coastal_connect_points_1 (
    gid integer PRIMARY KEY,
    connect_level integer,
    from_line_id integer,
    from_line character varying,
    from_line_geom geometry(Linestring),
    to_line_id integer,
    to_line character varying,
    to_line_geom geometry(Linestring)
);
INSERT INTO coastal_connect_points_1 (gid, connect_level, from_line_id, from_line, from_line_geom, to_line_id, to_line)
SELECT c.gid, c.connect_level, c.from_line_id, c.from_line, o.geom, c.to_line_id, c.to_line
FROM coastal_lines_connection AS c INNER JOIN oriented_coastal_lines AS o ON c.from_line_id = o.gid;
UPDATE coastal_connect_points_1 SET to_line_geom = o.geom
FROM oriented_coastal_lines AS o WHERE coastal_connect_points_1.to_line_id = o.gid;
-- create indexes on from line and to line geometries
CREATE INDEX ON coastal_connect_points_1 USING gist(from_line_geom);
CREATE INDEX ON coastal_connect_points_1 USING gist(to_line_geom);
-- create table coastal_connect_point, wih the closest points of the from and to lines
CREATE TABLE coastal_connect_points (
    gid integer PRIMARY KEY,
    connect_level integer,
    from_line_id integer,
    from_line character varying,
    from_line_point geometry(Point),
    from_line_location double precision,
    to_line_id integer,
    to_line character varying,
    to_line_point geometry(Point),
    to_line_location double precision
);
INSERT INTO coastal_connect_points(gid, connect_level, from_line_id, from_line, from_line_point, to_line_id, to_line, to_line_point)
SELECT gid, connect_level, from_line_id, from_line, ST_ClosestPoint(from_line_geom, to_line_geom) AS from_line_point, to_line_id,
    to_line, ST_ClosestPoint(to_line_geom, from_line_geom) FROM coastal_connect_points_1;
-- override the connect points of the table with those on special_connect_points
UPDATE coastal_connect_points SET from_line_point = s.from_point
FROM special_connect_points AS s WHERE s.gid = coastal_connect_points.gid;
UPDATE coastal_connect_points SET to_line_point = s.to_point
FROM special_connect_points AS s WHERE s.gid = coastal_connect_points.gid;
-- calculate the from and to point locations on their respective lines
UPDATE coastal_connect_points SET from_line_location = ST_LineLocatePoint(c.from_line_geom, from_line_point)
FROM coastal_connect_points_1 AS c WHERE coastal_connect_points.gid = c.gid;
UPDATE coastal_connect_points SET to_line_location = ST_LineLocatePoint(c.to_line_geom, to_line_point)
FROM coastal_connect_points_1 AS c WHERE coastal_connect_points.gid = c.gid;
-- delete the coastal_connect_points_1 table
DROP TABLE coastal_connect_points_1;
END;
$BODY$;

