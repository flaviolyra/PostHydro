CREATE PROCEDURE insert_ordered_mouth_nodes ()
-- Generate ordered_mouth_nodes table by inserting nodes from mouth_nodes table, ordered by the id of the costal line segment
-- where they belong and their location on the costal line

LANGUAGE 'plpgsql'
AS
$BODY$
BEGIN
-- insert mouth nodes ordered by coastal segment and point location
INSERT INTO ordered_mouth_nodes (node, reachid, coastline_id, coastline, coast_system, point_locate, coast_segment, geom)
SELECT m.node, m.reachid, m.coastline_id, m.coastline, s.coast_system, m.point_locate, s.gid, m.geom
FROM mouth_nodes AS m INNER JOIN coastal_segments AS s
ON m.coastline_id = s.line_id AND m.point_locate BETWEEN s.init_loc AND s.end_loc
ORDER BY s.gid, m.point_locate;
END;
$BODY$;
