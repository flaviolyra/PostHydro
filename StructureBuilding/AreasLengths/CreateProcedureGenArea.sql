CREATE PROCEDURE gen_area()
-- Generate areaupkm2 in table hydrography

LANGUAGE 'plpgsql' AS
$BODY$
DECLARE
rch integer;
areaup double precision;
BEGIN
-- update areaupkm2 for all basins upstream of their mouth nodes
FOR rch IN SELECT reachid FROM ordered_mouth_nodes
LOOP
    areaup = gen_tree_area(rch);
END LOOP;
END;
$BODY$;

