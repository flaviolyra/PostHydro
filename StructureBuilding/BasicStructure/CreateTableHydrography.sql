CREATE TABLE hydrography
(
  gid integer PRIMARY KEY,
  fnode integer,
  tnode integer,
  lengthkm double precision,
  areaid integer,
  is_down_rch boolean,
  is_main_rch boolean,
  areakm2 double precision,
  areaupkm2 double precision,
  mxlengthup double precision,
  lngthtomouth double precision,
  pfcode text,
  pfcodestr text,
  rivcode text,
  rivname text,
  lngthrivmouth double precision,
  geom geometry(LineString)
);
CREATE INDEX ON hydrography USING gist(geom);
CREATE INDEX ON hydrography USING btree(tnode);

