CREATE PROCEDURE set_area_length_up_mouth_nodes()
-- Update area upstream and maximum length upstream on ordered_mouth_nodes table, from mouth reach data on hydrography table

LANGUAGE 'plpgsql'
AS
$BODY$
BEGIN
UPDATE ordered_mouth_nodes SET areaupkm2 = h.areaupkm2
FROM hydrography AS h WHERE ordered_mouth_nodes.reachid = h.gid;
UPDATE ordered_mouth_nodes SET mxlengthup = h.mxlengthup
FROM hydrography AS h WHERE ordered_mouth_nodes.reachid = h.gid;
END;
$BODY$;
