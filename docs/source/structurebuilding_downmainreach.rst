Down and Main Reaches
=====================

Spatial features are related to contributing areas as their elementary reference. Queries, on the other hand, are always related to reaches. Therefore, when the contributing areas are associated to more than one reach, we have to know if the reach we are querying about is part of the accumulating process or not. Only those that are part of the link from one contributing area to the other get into this category and so are called main reaches. When we query about an upstream accumulated spatial feature on a main reach we have to use the upstream accumulated values table. When querying on a secondary reach, however, we should use the non accumulated values table.

The accumulating process, when we hydroreference a spatial feature, is done by traversing the reaches links, though their elementary unit is the individual contributing area. In order to accumulate a spatial feature we should add the non accumulated feature just once per contributing area. To make this possible we accumulate only when we get to the downmost reach among those that share the same area. These downmost reaches, therefore, must be signalled.

Main reaches are the ones on the path that links contributing areas. They must also be signalled, so that the client routine that display the spatial features upstream will only display the accumulated feature value for reaches along the main path. For the ones not on the main path the non accumulated feature should be displayed.

Down reaches are set, among those that share a contributing area, to the ones with largest upstream area. Main reaches are set, among those that share a contributing area, to the down reach and those that follow the main (larger upstream area) path. A down reach should always connect downstream to a main reach. It usually does, but the last step of the routine corrects the situations where it does not, by setting all down reach downstream reaches as main, until a previously set main reach is found.

Procedures and Functions
------------------------



.. py:function:: set_main_down_reach ()

   Sets is_main_rch and is_down_rch markers on hydrography table


---

