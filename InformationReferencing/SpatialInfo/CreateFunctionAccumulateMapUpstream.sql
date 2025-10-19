CREATE FUNCTION accumulate_map_upstream(reachid integer) RETURNS SETOF feature_value
-- Add to the accum_feature_area table records with feature upstream accumulated values corresponding to reachid's contributing
-- area, by upstream accumulation of feature values in a feature_area table, with values for every feature in an elementary
-- contributing area. Returns the accumulated values upstream as a set of feature_value records with feature id and value
-- Args:
--  reachid (integer): id of the reach whose feature values will be accumulated
-- Returns:
--  feat_val (set of feature_value records): feature, value

LANGUAGE 'plpgsql'
COST 100
VOLATILE 
ROWS 1000
    
AS $BODY$
DECLARE

    fromnode integer;
    area_id integer;
    downreach boolean;
    connreachid integer;
    i integer;
    f integer;
    v double precision;
    accumval double precision[];
	feat_val feature_value;

BEGIN
    -- get from node, areaid and is_down_rch corresponding to the reach
    SELECT h.fnode, h.areaid, h.is_down_rch INTO STRICT fromnode, area_id, downreach FROM hydrography AS h WHERE h.gid = reachid;
    -- zero the accumval vector
    FOR i IN 1..100
        LOOP
        accumval[i] = 0.;
        END LOOP;
    -- for each connecting reach, add its return feature-value set to accumval
    FOR connreachid IN SELECT gid FROM hydrography WHERE tnode = fromnode
        LOOP
        FOR f, v IN SELECT t.feature, t.value FROM accumulate_map_upstream(connreachid) AS t
            LOOP
            accumval[f] = accumval[f] + v;
            END LOOP;
        END LOOP;
    -- if downreach is true, add to accumval area_id's corresponding values in feature_area table
    -- and insert into accum_feature_area table the records corresponding to nonzero accumval elements
    IF downreach THEN
        -- add the areaid corresponding feature_area values to accumval
        FOR f, v IN SELECT id, value FROM feature_area WHERE areaid = area_id
            LOOP
            accumval[f] := accumval[f] + v;
            END LOOP;
        -- insert into accum_feature_area table the records corresponding to accumval
        FOR i IN 1..100
            LOOP
            IF accumval[i] <> 0. THEN
                INSERT INTO accum_feature_area (areaid, id, value)
                VALUES(area_id, i, accumval[i]);
            END IF;
            END LOOP;
    END IF;
    -- for every non zero accumulated feature, return one register
    FOR i IN 1..100
        LOOP
        IF accumval[i] <> 0. THEN
            feat_val.feature := i;
            feat_val.value := accumval[i];
            RETURN NEXT feat_val;
        END IF;
        END LOOP;
    RETURN;
END;
$BODY$;

