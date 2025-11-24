Testing
=======


A consistent hydrography table is one where:

* Except for the mouth nodes, every to node must correspond to another reach from node - in a basin, all reaches are logically connected, there are no loose reaches;
* All reaches should be drawn from upstream to downstream, and a reach most downstream point must correspond to the most upstream point on the downstream connected reach - reaches must be geometrically connected - this is a necessary condition for the correct hydroreference of point features;
* There should not be more than two confluent reaches at every node - the hydrography at triple confluences should be edited and a new very small reach added in order to correct this situation - correct pfafstetter coding demands no more than two upstream confluences.

Testing routines are available to check the hydrography table consistence. The test for loose connections must be run after setting length related fields on the hydrography, it generates a discontinuous_reaches table, with reach ids where mxlengthup is null. The tests for reach misorientation (or physical disconnection) and for triple confluences work the same way: they create a table with the number of errors upstream on a basin. Routines are available to show where (at what reach) the problem occurs, that create a table with the problem reach ids.



Procedures and Functions
------------------------



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


---

