CREATE FUNCTION accumulate_map_upstream(reachid integer, maxfeat integer) RETURNS feature_value[]
-- Add to the accum_feature_area table records with feature upstream accumulated values corresponding to reachid's contributing
-- area, by upstream accumulation of feature values in a feature_area table, with values for every feature in an elementary
-- contributing area. Returns the accumulated values upstream as an array of feature_value with feature id and value
-- Args:
--  reachid (integer): id of the reach whose feature values will be accumulated
--  maxfeat (integer): maximum number of the features
-- Returns:
--  feat_val (array of feature_value): feature, value corresponding to the area upstream of reachid

LANGUAGE 'plpgsql'
    
AS $BODY$
DECLARE

    fromnode integer;
    area_id integer;
    downreach boolean;
    connreachid integer;
    i integer;
    f integer;
    v double precision;
    up_accumval feature_value[] := '{}';
    accumval double precision[] := array_fill(0., ARRAY[maxfeat]);
    feat_val feature_value;

BEGIN
    -- get from node, areaid and is_down_rch corresponding to the reach
    SELECT h.fnode, h.areaid, h.is_down_rch INTO STRICT fromnode, area_id, downreach FROM hydrography AS h WHERE h.gid = reachid;
    -- for each connecting reach, add its return feature-value array in accumval
    FOR connreachid IN SELECT gid FROM hydrography WHERE tnode = fromnode
        LOOP
          FOREACH feat_val IN ARRAY accumulate_map_upstream(connreachid, maxfeat)
            LOOP
            accumval[feat_val.feature] := accumval[feat_val.feature] + feat_val.value;
            END LOOP;
        END LOOP;
    -- if downreach is true, add to accumval the area_id's corresponding values in feature_area table
    -- and insert into accum_feature_area table the records corresponding to nonzero accumval elements
    IF downreach THEN
        -- add the areaid corresponding feature_area values to accumval
        FOR f, v IN SELECT id, value FROM feature_area WHERE areaid = area_id
            LOOP
            accumval[f] := accumval[f] + v;
            END LOOP;
        -- insert the accumulated values in the accum_feature_area table
        FOR i IN 1..maxfeat
            LOOP
            IF accumval[i] <> 0. THEN
                INSERT INTO accum_feature_area(areaid, id, value)
                VALUES(area_id, i, accumval[i]);
            END IF;
            END LOOP;
    END IF;
    -- for every non zero accumulated feature, add a feature_value to the up_accumval array
    FOR i IN 1..maxfeat
        LOOP
        IF accumval[i] <> 0. THEN
            feat_val.feature := i;
            feat_val.value := accumval[i];
            up_accumval := ARRAY_append(up_accumval, feat_val);
        END IF;
        END LOOP;
    -- return up_accumval
    RETURN up_accumval;
END;
$BODY$;

