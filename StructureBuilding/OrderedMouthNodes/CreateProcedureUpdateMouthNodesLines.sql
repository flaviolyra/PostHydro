CREATE PROCEDURE update_mouth_nodes_lines(search_dist double precision)
-- Identify mouth node's corresponding coastline and location on line on mouth_nodes table,
-- searching for the nearest coastline on oriented_coastal_lines table, within search_dist radius
-- Args:
--  search_dist (double precision): maximum search radius to look for coastlines 

LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
UPDATE mouth_nodes SET coastline_id = b.line_id
FROM
(SELECT node_id, line_id FROM
(SELECT m.node AS node_id, o.gid AS line_id, rank() OVER (PARTITION BY m.node ORDER BY ST_Distance(m.geom, o.geom)) AS pos
FROM mouth_nodes AS m INNER JOIN oriented_coastal_lines AS o
ON ST_DWithin(m.geom, o.geom, search_dist)) AS a
WHERE pos = 1) AS b
WHERE mouth_nodes.node = b.node_id;
UPDATE mouth_nodes SET coastline = o.linename
FROM oriented_coastal_lines AS o WHERE mouth_nodes.coastline_id = o.gid;
UPDATE mouth_nodes SET point_locate = ST_LineLocatePoint(o.geom, mouth_nodes.geom)
FROM oriented_coastal_lines AS o WHERE mouth_nodes.coastline_id = o.gid;
END;
$BODY$;
