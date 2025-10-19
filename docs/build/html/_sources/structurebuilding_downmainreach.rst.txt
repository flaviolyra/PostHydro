Down and Main Reaches
=====================

Spatial features are related to contributing areas as their elementary reference. Queries, on the other hand, are always related to reaches. Therefore, when the contributing areas are associated to more than one reach, we have to know if the reach we are querying about is part of the accumulating process or not. Only those that are part of the link from one contributing area to the other get into this category and so are called main reaches. When we query about an upstream accumulated spatial feature on a main reach we have to use the upstream accumulated values table. When querying on a secondary reach, however, we should use the non accumulated values table.

The accumulating process, done when we hydroreference a spatial feature, is done by traversing the links between reaches, although their elementary unit is the individual contributing area. In order to accumulate an elementary spatial feature we should add the non accumulated feature just once per contributing area. To make this possible we accumulate only when we get to the downmost reach among those that share the same area. These downmost reaches, therefore, should be signalled.

Main and down reaches setting is done on a basin level, using the ordered_mouth_nodes table. In PostHydro, however, different mouth reaches can share the same contributing area. Down and main reaches should be set only on the most important (larger area upstream) basin. A special routine is provided to make a final correction in these cases.

Procedures and Functions
------------------------


.. py:function:: set_main_down_reach (reachid)

   Set is_main_rch and is_down_rch markers on hydrography table
   sets is_main_rch and is_down_reach true, follows main path, setting is_main_reach true while in the same areaid,
   calls itself recursively when a reachid on the main path with a different areaid is found

   :param reachid: id of the reach whose upstream reaches' is_main_rch and is_down_rch we want to update
   :type reachid: integer

---

.. py:function:: set_main_down_false (reachid)

   Set is_down_rch and is_main_rch to false in hydrography for reachid and upstream reaches

   :param reachid: id of the reach whose upstream reaches' is_down_rch and is_main_rch are set to false
   :type reachid: integer

---

.. py:function:: update_main_down_reach ()

   Update is_main_rch and is_down_rch for all basins whose root nodes are in ordered_mouth_nodes_table

---

.. py:function:: correct_main_down ()

   Update is_main_rch and is_down_rch to False on all secondary (smaller upstream area) basins on a same contributing area 

