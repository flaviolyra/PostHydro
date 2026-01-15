PostHydro Capabilities
======================

PostHydro capabilities are implemented as generic procedures and functions in PostgreSQL programming language, plpgsql, as well as type definitions. They fall under one of three categories:

.. toctree::
   :maxdepth: 1

   structurebuilding
   informationreferencing
   upstreamdownstreamnavigation

By Structure Building we mean creating the basic tables hydrography, contrib_area and ordered_mouth_nodes and providing the hydrography table with all information necessary for locating reaches and their watersheds inside the basins and for upstream / downstream navigation. It is done by means of generic functions and procedures written in PostgreSQL's programming language, plpgsql. This is done just once, at the development of the database for a region, and does not take long.

Information Referencing (hydroreferencing) involves procedures that give hydrological meaning to maps of point features related to the water streams (dams, water withdrawal or discharge points, water gauges, for example) and any kind of spatial map (soils map, land use map, country, state, municipality maps, census tract maps), sometime in combination with tables. Point information tables, with their geometry plus any other kind of information, get extra columns that locate them in their corresponding reaches of the hydrography table. Spatial information have to be crossed, using PostGIS or other any kind of GIS software, with the elementary contributing areas, generating a table with a value for any combination of numeric feature key and contributing area key, plus a multilanguage table that translates the feature keys to text. PostHydro has procedures to upstream accumulate the nonaccumulated table of feature values, generating a correspondent table with upstream accumulated values for every combination of feature and contributing area keys. These information referencing procedures are run just once, at the integration of the point or spatial information to the database, and do not take long.

Upstream Downstream Navigation has functions that return, with fast ordinary database queries, the set of reaches upstream or downstream of a given reach, identified by its pfafstetter code and distance to the mouth. Besides this it can be used to query any point information that has been hydroreferenced - the upstream or downstream point features are those that correspond to the return set of reaches. It can also be used for the upstream area query - upstream area is the set of contributing areas corresponding to the set of upstream reaches. Spatial features upstream querying does not have to involve any of those functions, it is done by just querying the corresponding accumulated values table with the contributing area key corresponding to the reach.

