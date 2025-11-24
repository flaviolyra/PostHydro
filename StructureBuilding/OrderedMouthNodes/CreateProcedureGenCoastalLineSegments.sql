CREATE PROCEDURE gen_coastal_line_segments (main_line_id integer, main_line_name character varying)
-- Generate a coastal_segments table from a main coastal line, consisting of an ordered chain of coastal segments on the line itself
-- and on contiguous islands and inner seas, based on a coastal_connect_points table
-- Args:
--  main_line_id (integer): id of the main coastal line (coast system)
--  main_line_name (character varying): name of the main coastal line

LANGUAGE 'plpgsql'
AS
$BODY$
BEGIN

-- Create coastal_segments the table
CREATE TABLE coastal_segments (
    gid serial PRIMARY KEY,
    line_id integer,
    coast_system character varying,
    init_loc double precision,
    end_loc double precision
);
-- Generate the coastal_segments table with chained segments from the main line and their associated islands and inner seas
CALL add_coastal_line_segments(0., main_line_id, main_line_name);
END;
$BODY$;
