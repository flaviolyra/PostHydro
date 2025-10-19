Testing
=======


A consistent hydrography table is one where:

* Except for the mouth nodes, every to node must correspond to another reach from node - in a basin, all reaches are logically connected, there are no loose reaches;
* All reaches should be drawn from upstream to downstream, and a reach most downstream point must correspond to the most upstream point on the downstream connected reach - reaches must be geometrically connected - this is a necessary condition for the correct hydroreference of point features;
* There should not be more than two confluent reaches at every node - the hydrography at triple confluences should be edited and a new very small reach added in order to correct this situation - correct pfafstetter coding demands no more than two upstream confluences.

Testing routines are available to check the hydrography table consistence. The test for loose connections must be run after setting length related fields on the hydrography, it generates a discontinuous_reaches table, with reach ids where mxlengthup is null. The tests for reach misorientation (or physical disconnection) and for triple confluences work the same way: they create a table with the number of errors upstream on a basin. Routines are available to show where (at what reach) the problem occurs, that create a table with the problem reach ids.



Procedures and Functions
------------------------


.. py:function:: gen_orientation_mouth_nodes ()

   Generate orientation_mouth_nodes table, with, for every basin mouth reach, the number of misoriented or misconnected reaches upstream

---

.. py:function:: generate_details_reach_misorientation ()

   Based on the orientation_mouth_nodes, with the number of misoriented reaches upstream of each basin root reach
   create a reach_misorientation table, with the root reach id and the id of the reach with connection or orientation issues

---

.. py:function:: details_reach_misorientation (rootreach_id, reachid, geom_node)

   Insert into reach_misorientation table, with the basin root reach id and the id of the misoriented reach
   a reach id, with its root reach, whenever the downstream point of an upstream connecting reach does not correspond to its upstream point
   This situation corresponds to a misoriented reach or a misconnection (a geometry gap)

   :param rootreach_id: id of the root reach of reachid
   :type rootreach_id: integer
   :param reachid: id of the reach whose upstream misoriented reaches are counted
   :type reachid: integer
   :param geom_node: geometry of the reachid's upstream point
   :type geom_node: geometry(Point)

---

.. py:function:: check_basin_orientation (reachid)

   Find the number of misoriented or physically disconnected reaches upstream of reachid

   :param reachid: id of the reach whose upstream misoriented reaches are counted
   :type reachid: integer
   :return: check_reach_orientation
   :rtype: integer

---

.. py:function:: check_reach_orientation (reachid, geom_node)

   Return the number of misoriented or physically disconnected reaches upstream of reachid, whose upstream node geometry is geom_node

   :param reachid: id of the reach whose upstream misoriented reaches are counted
   :type reachid: integer
   :param geom_node: geometry of the reachid's upstream point
   :type geom_node: geometry(Point)
   :return: nfo
   :rtype: integer

---

.. py:function:: reach_continuity ()

   Create a discontinuous_reaches table with the id and geometry of all the reaches where mxlengthup is null
   To be run after the gen_length procedure fills all the length related fields in the hydrography table

---

.. py:function:: num_triple_confluence (reachid)

   Find the number of triple confluences upstream of reachid

   :param reachid: id of the reach whose upstream triple confluences are counted
   :type reachid: integer
   :return: n_triple_conf
   :rtype: integer

---

.. py:function:: details_reach_triple_conf (rootreach, reachid)

   For every reach upstream of rootreach with a triple confluence,
   insert the root reach and the reach id into the reach_triple_conf table

   :param rootreach: id of the mouth reach of the basin whose upstream triple confluences are counted
   :type rootreach: integer
   :param reachid: id of the reach whose upstream triple confluences are counted
   :type reachid: integer

---

.. py:function:: generate_details_reach_triple_conf ()

   Based on the triple_conf_mouth_nodes table, with triple_conf, the number of triple confluences upstream of their root reaches,
   create a reach_triple_conf table with the root reach id and the ids of the upstream triple confluence reaches

---

.. py:function:: gen_triple_conf_mouth_nodes ()

   Create a triple_conf_mouth_nodes table with, for every basin root reach, the number of triple confluences upstream

