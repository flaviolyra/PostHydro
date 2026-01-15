CREATE TABLE pts_direct_indirect (
	gid integer PRIMARY KEY,
	name text,
	hydroref_form text,
	geom_ind geometry(Point,3035),
	geom geometry(Point,3035)
);
CREATE INDEX ON pts_direct_indirect USING gist (geom_ind);
CREATE INDEX ON pts_direct_indirect USING gist (geom);

