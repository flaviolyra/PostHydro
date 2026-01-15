CREATE PROCEDURE accumulate_map(maxfeat integer)
-- Upstream accumulate in accum_feature_area the feature_area table, expressing the upstream accumulated features values
-- Args:
--  maxfeat (integer): maximum number of features

LANGUAGE 'plpgsql'
    
AS $BODY$

DECLARE
  feat_val record;
  rch integer;

BEGIN
  -- create table accum_feature_area
  CREATE TABLE accum_feature_area
  (
    gid serial PRIMARY KEY,
    areaid integer,
    id integer,
    value double precision
  );
  -- for each main basin reach whose mouth node is in ordered_mouth_nodes table, accumulate map in feature_value table
  FOR rch IN SELECT reachid FROM
  (SELECT o.reachid FROM ordered_mouth_nodes AS o INNER JOIN hydrography AS h ON o.reachid = h.gid WHERE h.is_main_rch) AS mb
    LOOP
    FOR feat_val IN SELECT accumulate_map_upstream(rch, maxfeat)
      LOOP
        NULL;
      END LOOP;
    END LOOP;
END;

$BODY$;

