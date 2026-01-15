Information Structure
=====================

The structure of the information in a PostHydro database of a given region consists of  a core surface water representation of the region and tables with surface water referenced (hydroreferenced) point and areal information.

The main part of the core representation consists of two PostGIS tables, with their geometric expression (so their map can be shown in an application): the hydrography table, with the water stream reaches as LineStrings, and the contrib_area table, with the elementary contributing areas as Polygons. The other part of the core set consists of information about coastlines (oriented_costal_lines table), with their geometric expression as Linestrings. From these coastlines a table is generated, with an ordered set of coastline segments, that implement the composite coastline, made of parts on the continental coastline and parts on nearby islands and inner seas, on which the basins and their mouth reaches and nodes are located as an ordered sequence, thereby enabling them to get a unique pfafstetter code (ordered_mouth_nodes table).

Over this core dataset many other datasets with spatial information on the region and waterstream related point information can be referenced (hydroreferenced), generating additional tables that make possible instantaneous queries about these features in an application. Spatial information is presented, for any specific feature, by three tables: a multilingual table with the feature id keys and two tables with values for each feature on each contributing area and on the their upstream contributing area. Point information take only the original point table, with added fields that locate them on the hydrography reaches. 

The available hydroreferenced features are presented in a multilingual table to be used by the client application, called information_application, stating what hydroreferenced information layers are available on the database, their corresponding tables and generic (for each type of information) presentation routines. Even when no other feature has been hydroreferenced in the base, this table always contains as a minimum registers corresponding to the display of the upstream areas or reaches and of the downstream path. Besides guiding the information application, this table serves as a directory of the information on the database. 

Both the hydrography and the contrib_area tables should in principle have a reference field so that we can trace them back to the original tables on the reaches - contributing areas database. Apart from the backward reference, the contrib_area table has just the key and the geometry of the elementary areas.

The hydrography table is where the core of the PostHydro intelligence lays. The hydrography reaches are provided with the corresponding elementary contributing area id, its river code and name (if available), the area in square kilometers upstream of its downstream point and its location in kilometers inside the basin - distance along the centerlines of its upstream point to the mouth of the basin and of the river (if available) and distance of its downstream point to the farthest upstream point on the basin - besides the Pfafstetter codes of the reach and of its corresponding stream. The relationship between hydrography reaches and elementary contributing areas most often is one to one, but PostHydro supports cases where an elementary contributing area corresponds to a number of connected reaches. To accomodate such cases the hydrography table has two boolean fields that signal if the reach belongs to the main path across the contributing area and if the reach is the downmost of those in the area.


Tables
------


.. csv-table:: Information Application (information_application table)
   :file: tables/information_application.csv
   :widths: 20, 30, 50
   :header-rows: 1

