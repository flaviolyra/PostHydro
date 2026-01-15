CREATE PROCEDURE gen_mouth_nodes ()
-- Create the core (node id, reach id and geom) of the mouth_nodes table, relating node and reach id, coast line id, name
-- and location on the coastline, from nodes in the hydrography table that are to node, but not from node

LANGUAGE 'plpgsql'
AS
$BODY$ 
BEGIN
-- create table mouth_nodes
CREATE TABLE mouth_nodes (
gid serial PRIMARY KEY,
node integer,
reachid integer,
coastline_id integer,
coastline character varying,
point_locate double precision,
geom geometry(Point)
);
-- create tables fromnode and tonode with all fnodes and tnodes from c_tr
CREATE TABLE fromnode AS SELECT DISTINCT fnode FROM hydrography;
CREATE TABLE tonode AS SELECT DISTINCT tnode FROM hydrography;
-- create table mnode with all tnodes that do not correspond to an fnode (mouth nodes)
CREATE TABLE mnode AS
SELECT tnode FROM
(SELECT t.tnode, f.fnode
FROM tonode AS t LEFT JOIN fromnode AS f ON t.tnode = f.fnode) AS a
WHERE fnode IS NULL;
-- generate table mouth_nodes associating mnode reaches to the to nodes of hydrography
INSERT INTO mouth_nodes (node, reachid, geom)
SELECT m.tnode AS node, h.gid AS reachid, ST_EndPoint(h.geom) AS geom
FROM mnode AS m INNER JOIN hydrography AS h ON m.tnode = h.tnode;
-- drop tables fromnode, tonode and mnode
DROP TABLE fromnode;
DROP TABLE tonode;
DROP TABLE mnode;
END;
$BODY$;
