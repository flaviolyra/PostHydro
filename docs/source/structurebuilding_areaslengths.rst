Areas and Lengths
=================

In this part of structure building the reaches get associated to their contributing areas, their lengths and areas (as a length weighed portion among all the reaches that share the same contributing area) calculated and areas and lengths are accumulated by traversing each of the basins tree, generating length of each reach to the basin and river mouth, maximum length up and area upstream.

Types
-----


.. csv-table:: Upstream Characteristics (up_char)
   :file: types/up_char.csv
   :widths: 20, 30, 50
   :header-rows: 1


Procedures and Functions
------------------------



.. py:function:: gen_length ()

   Generate lengthkm, lngthtomouth, mxlengthup and lngthrivmouth in table hydrography


---


.. py:function:: gen_tree_length (currrch, l2mouth)

   Given a reach id (currrch) and the distance of its downstream point to the mouth of the watershed (l2mouth)
   Update lngthtomouth and mxlengthup of the reach and its upstream reaches on hydrography table
   with distance to the mouth and longest distance upstream 

   :param currrch: id of the reach whose upstream reaches' lngthtomouth and mxlengthup we want to update
   :type currrch: integer
   :return: mxlengthup
   :rtype: double precision

---


.. py:function:: gen_tree_area (currrch)

   Update areaupkm2 in currrch and all upstream reaches with their upstream area 

   :param currrch: id of the reach whose upstream reaches' areaupkm2 we want to update
   :type currrch: integer
   :return: areaup
   :rtype: double precision

---


.. py:function:: update_areakm2 ()

   Update area_km2 on hydrography table with a reach length weighed proportion of the area of its elementary contributing area


---


.. py:function:: gen_area ()

   Generate areaupkm2 in table hydrography


---

