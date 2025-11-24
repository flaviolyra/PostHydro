CREATE PROCEDURE correct_main_down()
-- Update is_main_rch and is_down_rch to False on all secondary (smaller upstream area) basins on a same contributing area 

LANGUAGE 'plpgsql'
AS
$BODY$
  DECLARE
  rch integer;
  BEGIN
    -- create table secondary_mouth_reaches, with secondary mouth reaches, that is,
    -- among those in a same area id, those that are not the one with the largest upstream area
    CREATE TABLE secondary_mouth_reaches AS
    SELECT reachid FROM
    (SELECT reachid, rank() OVER (partition BY areaid ORDER BY areaupkm2 DESC, reachid DESC) AS pos FROM
    (SELECT h.areaid, o.reachid, o.areaupkm2
    FROM hydrography AS h INNER JOIN ordered_mouth_nodes AS o ON h.gid = o.reachid) AS ar) AS ap
    WHERE pos <> 1;
    -- for those basin whose mouth reaches are in secondary_mouth_reaches, turn all reaches' is_main_rch and is_down_rch to False
    FOR rch IN (SELECT reachid FROM secondary_mouth_reaches)
    LOOP
      CALL set_main_down_false(rch);
    END LOOP;
    -- delete table secondary_mouth_reaches
    DROP TABLE secondary_mouth_reaches;
  END;
$BODY$;


