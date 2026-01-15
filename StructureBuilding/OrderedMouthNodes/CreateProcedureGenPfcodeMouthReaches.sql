CREATE PROCEDURE gen_pfcode_mouth_reaches (minid integer, maxid integer)
-- Pfafstetter code ordered_mouth_nodes table (basic code of the basins whose mouth nodes are in the table)
-- generate in pfcode one additional Pfafstetter code digit (one further step of Pfadstetter coding), for the end reaches in
-- ordered_mouth_nodes table whose gid lies between minid and maxid
-- call itself recursively whenever an odd digit is added to a range of mouth nodes
-- Args:
--  minid (integer): initial gid on ordered_mouth_nodes table of the mouth nodes to be one step further Pfafstetter classified
--  maxid (integer): final gid on ordered_mouth_nodes table of the mouth nodes to be one step further Pfafstetter classified

LANGUAGE 'plpgsql'

AS $BODY$

DECLARE

nodearray integer[];
id integer;
i integer;
mini integer;

BEGIN

i = 1;
mini = minid;
-- put into nodearray an ordered (downstream to upstream) set of the id of the four largest area basins mouths 
nodearray = ARRAY(SELECT gid FROM
(SELECT gid FROM ordered_mouth_nodes WHERE gid BETWEEN minid AND maxid
 ORDER BY areaupkm2 DESC LIMIT 4) AS a
ORDER BY gid);
-- code basins 1 to 8
FOREACH id IN ARRAY nodearray
LOOP
    -- code the interbasin (odd) - sets the code seed (odd number) and recursively codes ahead
    UPDATE ordered_mouth_nodes SET pfcode = pfcode || i::character varying
    WHERE gid >= mini AND gid < id;
    IF mini < id THEN CALL gen_pfcode_mouth_reaches (mini, id - 1); END IF;
    -- code the basin (even) - set the code (even number)
    UPDATE ordered_mouth_nodes SET pfcode = pfcode || (i + 1)::character varying
    WHERE gid = id;
    i = i +2;
    mini = id + 1;
END LOOP;
-- code interbasin 9
UPDATE ordered_mouth_nodes SET pfcode = pfcode || i::character varying
WHERE gid BETWEEN mini AND maxid;
IF mini <= maxid THEN CALL gen_pfcode_mouth_reaches (mini, maxid); END IF;

END;

$BODY$;

