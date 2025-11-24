CREATE PROCEDURE pfcode_mouth_nodes()
-- Generate the pfcode of the basins on the ordered_mouth_nodes table according to the order of the node on the table
-- and its upstream area

LANGUAGE 'plpgsql' AS
$BODY$
DECLARE upbounds integer;
BEGIN
UPDATE ordered_mouth_nodes SET pfcode = '';
SELECT count(gid) INTO upbounds FROM ordered_mouth_nodes;
CALL gen_pfcode_mouth_reaches(1, upbounds);
END;
$BODY$;

