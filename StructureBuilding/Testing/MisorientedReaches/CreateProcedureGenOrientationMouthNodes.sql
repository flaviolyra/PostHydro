CREATE PROCEDURE gen_orientation_mouth_nodes()
-- Generate orientation_mouth_nodes table, with, for every basin mouth reach, the number of misoriented or misconnected reaches upstream

LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
CREATE TABLE orientation_mouth_nodes AS
-- creates a table with, for every basin mouth node and reach, the number of misoriented upstream reaches
SELECT gid, reachid, check_basin_orientation (reachid) AS orientation
FROM ordered_mouth_nodes;
END;
$BODY$;

