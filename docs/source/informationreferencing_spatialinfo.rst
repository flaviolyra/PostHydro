Spatial Information Referencing
===============================

Spatial information is described in a PostHydro database by three tables: the first, whose generic name is feature_area, presenting the features in an elementary contributing area, has a value for every feature present in an elementary contributing area; the second, named accum_feature_area, has a value for every feature present upstream of an elementary contributing area; the third has as generic name feature_keys, is a multilingual table presenting the feature keys description.

The generic feature_area table is developed by crossing the specific feature map with the contrib_area table. The spatial procedure accumulate_map generates, taking as input the feature_area table, the generic accum_feature_area table. These two generic tables should then be renamed, according to the feature in question, and their names added to a corresponding register in the information_application table, along with their specific feature_keys table name.


Tables
------


.. csv-table:: Contributing Area Features (feature_area table)
   :file: tables/feature_area.csv
   :widths: 20, 30, 50
   :header-rows: 1

---

.. csv-table:: Contributing Area Upstream Features (accum_feature_area table)
   :file: tables/accum_feature_area.csv
   :widths: 20, 30, 50
   :header-rows: 1

---

.. csv-table:: Feature Keys (feature_keys table)
   :file: tables/feature_keys.csv
   :widths: 20, 30, 50
   :header-rows: 1


Types
------


.. csv-table:: Feature - Value (feature_value)
   :file: types/feature_value.csv
   :widths: 20, 30, 50
   :header-rows: 1


Procedures and Functions
------------------------



.. py:function:: accumulate_map_upstream (reachid, maxfeat)

   Add to the accum_feature_area table records with feature upstream accumulated values corresponding to reachid's contributing
   area, by upstream accumulation of feature values in a feature_area table, with values for every feature in an elementary
   contributing area. Returns the accumulated values upstream as an array of feature_value with feature id and value

   :param reachid: id of the reach whose feature values will be accumulated
   :type reachid: integer
   :param maxfeat: maximum number of the features
   :type maxfeat: integer
   :return: feat_val
   :rtype: array of feature_value

---


.. py:function:: accumulate_map (maxfeat)

   Upstream accumulate in accum_feature_area the feature_area table, expressing the upstream accumulated features values

   :param maxfeat: maximum number of features
   :type maxfeat: integer

---

