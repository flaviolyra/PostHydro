CREATE PROCEDURE index_pfcode()
-- Create an index on pfcode and pfcodestr, on hydrography table

LANGUAGE 'plpgsql'
AS
$BODY$
BEGIN
CREATE INDEX ON hydrography USING btree(pfcode);
CREATE INDEX ON hydrography USING btree(pfcodestr);
END;
$BODY$;

