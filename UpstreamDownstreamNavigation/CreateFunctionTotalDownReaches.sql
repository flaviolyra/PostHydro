CREATE FUNCTION total_down_reaches(code text, dist double precision, prev_id_reaches integer[], first_reach boolean)
    RETURNS integer[]
-- Given a reach pfafstetter code (code) and distance to the mouth (dist) and an array of reach codes already found
-- on a downstream path, adds to the array those reaches, not already on the array, corresponding to reaches downstream
-- of the divergences nodes (on the divergences table) found on the downstream path (including the one corresponding to pfcode and
-- dist, if first_reach is true)
-- Args:
--  code (text): reach pfafstetter code
--  dist (double precision): reach upstream point distance to the basin mouth
--  prev_id_reaches (array of integer): array of previously found reaches ids on the downstream path 
--  first_reach (boolean): signals this is the first reach on a downstream path, to be added to the array of ids, if true
-- Returns:
--  out_idd_reaches (array of integer): output array of reaches ids on the downstream path

LANGUAGE 'plpgsql'
COST 100
VOLATILE

AS $BODY$
DECLARE
  reachid integer;
  fromnodeid integer;
  gid_rch integer;
  code_rch text;
  dist_rch double precision;
  cotrecho_tr integer;
  idd_reaches integer[];
  in_idd_reaches integer[];
  out_idd_reaches integer[];
  idd_nodes integer[];
  lim_dist double precision;
BEGIN
  -- if not first_reach, make lim_dist one meter smaller than dist (reach will not be included in the path)
  -- else, make lim_dist one meter greater than dist (reach will be included in the path)
  IF first_reach THEN
    lim_dist := dist - 0.001;
  ELSE
    lim_dist := dist + 0.001;
  END IF;
  -- get ids and to_nodes of the reaches downstream of the reference reach and
  -- not yet in the prev_id_reaches array, add them to the idd_reaches e idd_nodes arrays
  idd_reaches := '{}';
  idd_nodes := '{}';
  FOR reachid, fromnodeid IN SELECT h.gid, h.fnode FROM hydrography AS h INNER JOIN downpath(code) AS d
    ON (h.pfcodestr = d.stream AND h.pfcode < d.upstrbasin)
    WHERE h.lngthtomouth < lim_dist AND h.gid NOT IN (SELECT unnest(prev_id_reaches))
  LOOP
    idd_reaches := array_append(idd_reaches, reachid);
    idd_nodes := array_append(idd_nodes, fromnodeid);
  END LOOP;
  -- generate the output identified reaches out_idd_reaches as the concatenation of those previously identified
  -- with those identified in this call
  out_idd_reaches := array_cat(prev_id_reaches, idd_reaches);
  -- look in the identified nodes array for all those in the divergences table and calls recursively this routine for every
  -- corresponding reach, not already present in out_idd_reaches
  FOR gid_rch, code_rch, dist_rch IN SELECT h.gid, h.pfcode, h.lngthtomouth FROM hydrography AS h
    INNER JOIN (SELECT comid FROM divergences WHERE nodenumber IN (SELECT unnest(idd_nodes))) AS divrch ON h.gid = divrch.comid
    WHERE h.gid NOT IN (SELECT unnest(out_idd_reaches))
  LOOP
    -- new in_idd_reaches gets previous out_idd_reaches
    in_idd_reaches := out_idd_reaches;
    -- recursively call the routine to calculate new out_idd_reaches array
    out_idd_reaches := total_down_reaches(code_rch, dist_rch, in_idd_reaches, FALSE);
  END LOOP;
  RETURN out_idd_reaches;
END;
$BODY$;

