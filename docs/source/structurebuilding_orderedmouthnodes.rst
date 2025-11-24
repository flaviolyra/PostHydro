Ordered Mouth Nodes
===================

The Pfafstetter coding of a hydrographic region starts with the coding of the basins that flow to the continental coastal line. In PostHydro the different coastlines that comprise a region (ocean coastlines, islands coastlines, interior seas coastlines) are incorporated as a single composite coastline, always with the earth to the right of the line, on which the mouth nodes of the basins are ordered, from the start point of the line to its end. This composite coastline is treated in the Pfafstetter coding method as if it was a main stream line, this time flowing from its endpoint to the start. The basin codes are assigned taking into account the order of their mouth nodes on the line and their upstream areas.

The process starts with the development of a mouth nodes table, on whose individual coastlines they are located. The composite coastline consists of an ordered set of coastline segments, following a table that states a hierarchy of coastal lines connections, that is, what coastal line is a child of another. The composite coastline means that a segment on the parent coastline ends when a connection point is found to its child coastline. The segment on the child line follows the same logic, starting at its connection point until a point on the line that is its contact to a child line of its own or until its contact with the parent line is reached, when it goes back to the parent. The connection points are the closest points on the two connecting lines, if not specified otherwise in a special connect points table.

More than one composite coastline can be processed in sequence in the generation of the ordered_mouth_nodes table, each getting the name coast_system on the table. The mouth nodes get their order from the order of the coast systems and, for each composite coastline, from the order of their coastal line segments and from their mouth node position on the segments.


Procedures and Functions
------------------------



.. py:function:: pfcode_mouth_nodes ()

   Generate the pfcode of the basins on the ordered_mouth_nodes table according to the order of the node on the table
   and its upstream area


---


.. py:function:: insert_ordered_mouth_nodes ()

   Generate ordered_mouth_nodes table by inserting nodes from mouth_nodes table, ordered by the id of the costal line segment
   where they belong and their location on the costal line


---


.. py:function:: create_ordered_mouth_nodes ()

   Create ordered_mouth_nodes table


---


.. py:function:: update_mouth_nodes_lines (search_dist)

   Identify mouth node's corresponding coastline and location on line on mouth_nodes table,
   searching for the nearest coastline on oriented_coastal_lines table, within search_dist radius

   :param search_dist: maximum search radius to look for coastlines 
   :type search_dist: double precision

---


.. py:function:: gen_coastal_connect_points ()

   Generate coastal_connect_points, from oriented_coastal_lines, with the coastal lines geometry, and coastal_lines_connection,
   with the designed connectivity order for developing the composite coastal line.
   Unless specified otherwise in a special_connect_points table, those points will be the closest points on the two connecting lines


---


.. py:function:: exclude_false_mouth_nodes ()

   Exclude false mouth nodes from mouth_nodes table according to false_mouth_nodes table


---


.. py:function:: gen_mouth_nodes ()

   Create the core (node id, reach id and geom) of the mouth_nodes table, relating node and reach id, coast line id, name
   and location on the coastline, from nodes in the hydrography table that are to node, but not from node


---


.. py:function:: set_area_length_up_mouth_nodes ()

   Update area upstream and maximum length upstream on ordered_mouth_nodes table, from mouth reach data on hydrography table


---


.. py:function:: add_coastal_line_segments (ini_loc, id_line, main_coastal_line)

   Generate coastal line segments corresponding to id_line coastal_line on coastal_line_segments table, starting at ini_loc
   location on the line and taking as limits the from_line_point corresponding to this line at the coastal_connect_points table.
   At every from_line_point, the routine is called recursively to generate the segments for the connecting coastal line (to_line_id).

   :param ini_loc: location of the initial point of the first id_line segment to be added
   :type ini_loc: double precision
   :param id_line: id of the line whose segments will be added to coastal_line_segments table
   :type id_line: integer
   :param main_coastal_line: name of the main coastal line (coast_system) to which these segments belong
   :type main_coastal_line: character varying

---


.. py:function:: gen_pfcode_mouth_reaches (minid, maxid)

   Pfafstetter code ordered_mouth_nodes table (basic code of the basins whose mouth nodes are in the table)
   generate in pfcode one additional Pfafstetter code digit (one further step of Pfadstetter coding), for the end reaches in
   ordered_mouth_nodes table whose gid lies between minid and maxid
   call itself recursively whenever an odd digit is added to a range of mouth nodes

   :param minid: initial gid on ordered_mouth_nodes table of the mouth nodes to be one step further Pfafstetter classified
   :type minid: integer
   :param maxid: final gid on ordered_mouth_nodes table of the mouth nodes to be one step further Pfafstetter classified
   :type maxid: integer

---


.. py:function:: gen_coastal_line_segments (main_line_id, main_line_name)

   Generate a coastal_segments table from a main coastal line, consisting of an ordered chain of coastal segments on the line itself
   and on contiguous islands and inner seas, based on a coastal_connect_points table

   :param main_line_id: id of the main coastal line (coast system)
   :type main_line_id: integer
   :param main_line_name: name of the main coastal line
   :type main_line_name: character varying

---

