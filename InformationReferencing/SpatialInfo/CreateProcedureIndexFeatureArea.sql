CREATE PROCEDURE index_feature_area ()
-- Index table feature_area on contributing area id
LANGUAGE 'plpgsql'
AS
$BODY$
BEGIN
CREATE INDEX ON feature_area USING btree(areaid);
END;
$BODY$;
