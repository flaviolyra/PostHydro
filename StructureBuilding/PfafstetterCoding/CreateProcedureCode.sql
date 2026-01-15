CREATE PROCEDURE code(basecode character varying(1))
-- Code all basins starting with the single digit basecode
-- Args:
--  basecode (character varying(1)): pfafstetter code initial digit

LANGUAGE 'plpgsql' AS
$BODY$
DECLARE
rcode character varying;
rid integer;
BEGIN
FOR rcode, rid IN
SELECT pfcode, reachid FROM ordered_mouth_nodes WHERE left(pfcode, 1) = basecode
LOOP CALL pfafstetter_code(rcode, rid, True); END LOOP;
END;
$BODY$;
