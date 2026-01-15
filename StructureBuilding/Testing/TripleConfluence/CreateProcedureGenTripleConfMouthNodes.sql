CREATE PROCEDURE gen_triple_conf_mouth_nodes()
-- Create a triple_conf_mouth_nodes table with, for every basin root reach, the number of triple confluences upstream

LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
CREATE TABLE triple_conf_mouth_nodes AS
SELECT gid, reachid, num_triple_confluence (reachid) AS triple_conf
FROM ordered_mouth_nodes;
END;
$BODY$;

