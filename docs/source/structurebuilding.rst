Structure Building
==================

The original database tables that provide the starting point for the development of a PostHydro database core of a region are the hydrography table, with reach id, to and from nodes, geometry, river code and name, the contributing area table, with ids and geometry, and the coastlines table, where the basins flow to, with their id, name and geometry. The structure building routines add to the hydrography table fields that provide topological information to locate the reaches within their basins and on the hydrologic region.

A PostHydro compliant database of a region consists of a set of basins that flow to a pseudo-river, in fact a composite coastline, made of segments on a continental coastline and on related islands and inner seas coastlines, each basin with its own pfafstetter code. These basins will be further pfafstetter coded, by adding more digits to their base code.

The basin mouth nodes are represented by the ordered_mouth_nodes table and the basins themselves by the hydrography table, with the waterways (rivers and lakes centerlines) reaches and all the topology related information in its fields. The structure building consists in building the mouth nodes table and adding the topological information (linear and areal) to the hydrography table.

The linear part of the structure building consists of adding or updating fields with the length of the reach, lengths along the streams from the its upstream point to the river and basin mouths and length along the streams from the reaches downstream point to the most upstream point on its basin.

The areal part of the structure building consists of adding or updating fields with identification of the reach contributing area, an estimate of the part of this contributing area corresponding to the reach and its upstream area.

PostHydro supports elementary contributing areas comprising more than one reach. Boolean fields are provided (is_main rch and is_down_rch) that identify the main path along the individual contributing area and the area's most downstream reach. This is important information used for display in the information application and for hydroreferencing spatial information.

The most important topological information added is the Pfafstetter code of the reach (pfcode) and of its main stream (pfcodestr), which act like a topological index of the reach and thus make possible upstream and downstream navigation with ordinary database queries.

Tests are provided, that check the integrity of the database.


.. toctree::
   :maxdepth: 1

   structurebuilding_basicstructure
   structurebuilding_orderedmouthnodes
   structurebuilding_areaslengths
   structurebuilding_downmainreach
   structurebuilding_pfafstettercoding
   structurebuilding_testing

