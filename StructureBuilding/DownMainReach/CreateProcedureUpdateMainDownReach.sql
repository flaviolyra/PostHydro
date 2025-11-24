CREATE PROCEDURE update_main_down_reach ()
-- Update is_main_rch and is_down_rch for all basins whose root nodes are in ordered_mouth_nodes_table

LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
reach_id integer;
BEGIN
-- for every basin whose mouth reach is in ordered_mouth_nodes_table, set is_main_rch and is_down_rch 
FOR reach_id IN SELECT reachid FROM ordered_mouth_nodes LOOP
    CALL set_main_down_reach (reach_id);
END LOOP;
END;
$BODY$;

