CREATE PROCEDURE add_coastal_line_segments(ini_loc double precision, id_line integer, main_coastal_line character varying)
-- Generate coastal line segments corresponding to id_line coastal_line on coastal_line_segments table, starting at ini_loc
-- location on the line and taking as limits the from_line_point corresponding to this line at the coastal_connect_points table.
-- At every from_line_point, the routine is called recursively to generate the segments for the connecting coastal line (to_line_id).
-- Args:
--  ini_loc (double precision): location of the initial point of the first id_line segment to be added
--  id_line (integer): id of the line whose segments will be added to coastal_line_segments table
--  main_coastal_line (character varying): name of the main coastal line (coast_system) to which these segments belong

LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
  fromloc double precision;
  toline integer;
  toloc double precision;
  location double precision;
  closed boolean;
BEGIN
-- set location to ini_loc
location = ini_loc;
SELECT ST_IsClosed(geom) INTO closed FROM oriented_coastal_lines WHERE gid = id_line;
FOR fromloc, toline, toloc IN
SELECT from_line_location, to_line_id, to_line_location FROM coastal_connect_points
WHERE from_line_id = id_line AND from_line_location > ini_loc
ORDER BY from_line_location
LOOP
    -- insert the segment between location and the from_point
    INSERT INTO coastal_segments (line_id, coast_system, init_loc, end_loc) VALUES (id_line, main_coastal_line, location, fromloc);
    -- recursively call add_coastal_line_segments to add segments on the connecting line
    CALL add_coastal_line_segments(toloc, toline, main_coastal_line);
    -- set location to the from_point
    location = fromloc;
END LOOP;
-- insert the last segment (after the last from_point, until the end of the line)
INSERT INTO coastal_segments (line_id, coast_system, init_loc, end_loc) VALUES (id_line, main_coastal_line, location, 1.);
-- if it is a closed line, insert segments from the start (0.) to ini_loc
IF closed THEN
    location = 0.;
    FOR fromloc, toline, toloc IN
    SELECT from_line_location, to_line_id, to_line_location FROM coastal_connect_points
    WHERE from_line_id = id_line AND from_line_location <= ini_loc
    ORDER BY from_line_location
    LOOP
        -- insert the segment between location and the from_point
        INSERT INTO coastal_segments (line_id, coast_system, init_loc, end_loc) VALUES (id_line, main_coastal_line, location, fromloc);
        -- recursively call add_coastal_line_segments to add segments on the connecting line
        CALL add_coastal_line_segments(toloc, toline, main_coastal_line);
        -- set location to the from_point
        location = fromloc;
    END LOOP;
    -- insert the last segment (after the last from_point, until ini_loc)
    INSERT INTO coastal_segments (line_id, coast_system, init_loc, end_loc) VALUES (id_line, main_coastal_line, location, ini_loc);
END IF;
END;
$BODY$;
