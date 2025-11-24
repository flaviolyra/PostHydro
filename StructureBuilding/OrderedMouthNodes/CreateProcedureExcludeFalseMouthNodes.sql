CREATE PROCEDURE exclude_false_mouth_nodes ()
-- Exclude false mouth nodes from mouth_nodes table according to false_mouth_nodes table

LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
DELETE FROM mouth_nodes WHERE node IN (SELECT DISTINCT node FROM false_mouth_nodes);
END;
$BODY$;
