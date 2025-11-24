CREATE TABLE contrib_area
(
  gid integer PRIMARY KEY,
  geom geometry(Polygon)
);
CREATE INDEX ON contrib_area USING gist(geom);

