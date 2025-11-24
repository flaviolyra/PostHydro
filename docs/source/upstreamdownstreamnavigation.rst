Upstream Downstream Navigation
==============================

These are the functions that extend the ordinary relational database querying capabilities to the surface water domain. One of them gives as result the set of contributing area ids corresponding to the areas upstream and including that of the reach (up_areas), two others the set of ids of the upstream reaches to a given reach, including it (up_reaches), and the set of ids of the downstream reaches (down_reaches). The reach in the argument of these functions is described in a unique way by its pfafstetter code (which works as a water domain index) and the distance of its upstream point to the mouth. The remaining are auxiliary functions.


Types
-----


.. csv-table:: Downstream Stream - Upper Limit Tuple (downstreach)
   :file: types/downstreach.csv
   :widths: 20, 30, 50
   :header-rows: 1

---

.. csv-table:: Watershed Downstream - Upstream Range (uplimits)
   :file: types/uplimits.csv
   :widths: 20, 30, 50
   :header-rows: 1


Procedures and Functions
------------------------



.. py:function:: upbounds (pfcode)

   Given a Pfafstetter code pfcode, generate an uplimits record with the downstream inclusive (codedown) and upstream (codeup) pfcodes
   boundaries of the basin upstream

   :param pfcode: downstream pfafstetter code
   :type pfcode: text
   :return: limits
   :rtype: uplimits

---


.. py:function:: total_down_reaches (code, dist, prev_id_reaches, first_reach)

   Given a reach pfafstetter code (code) and distance to the mouth (dist) and an array of reach codes already found
   on a downstream path, adds to the array those reaches, not already on the array, corresponding to reaches downstream
   of the divergences nodes (on the divergences table) found on the downstream path (including the one corresponding to pfcode and
   dist, if first_reach is true)

   :param code: reach pfafstetter code
   :type code: text
   :param dist: reach upstream point distance to the basin mouth
   :type dist: double precision
   :param prev_id_reaches: array of previously found reaches ids on the downstream path 
   :type prev_id_reaches: array of integer
   :param first_reach: signals this is the first reach on a downstream path, to be added to the array of ids, if true
   :type first_reach: boolean
   :return: out_idd_reaches
   :rtype: array of integer

---


.. py:function:: up_areas (pfcode, dist)

   Generate a set of contributing area ids corresponding to the reaches upstream, and including, the one whose pfafstetter code is
   pfcode and distance of the upstream point to the mouth is dist

   :param pfcode: reach pfafstetter code
   :type pfcode: text
   :param dist: reach upstream point distance to the basin mouth
   :type dist: double precision
   :return: areaid
   :rtype: set of integer

---


.. py:function:: up_reaches (pfcode, dist)

   Generate a set of reaches ids corresponding to the reaches upstream, and including, the one whose pfafstetter code is
   pfcode and distance of the upstream point to the mouth is dist

   :param pfcode: reach pfafstetter code
   :type pfcode: text
   :param dist: reach upstream point distance to the basin mouth
   :type dist: double precision
   :return: gid
   :rtype: set of integer

---


.. py:function:: down_reaches (code, dist)

   Given a reach Pfafstetter code (code) and distance to the mouth (dist),
   return the set of ids of the reaches in the downstream main stream segments corresponding to its main downstream path

   :param code: reach pfafstetter code
   :type code: character varying
   :param dist: reach upstream point distance to the basin mouth
   :type dist: double precision
   :return: gid
   :rtype: set of integer

---


.. py:function:: downpath (pfcode)

   Interpret pfcode and generate a set of downstreach records,
   each corresponding to a mainstream segment found on the way from pfcode to the mouth
   of the basin, with their mainstream code (stream) and its upper reach code limit (upstrbasin)

   :param pfcode: Pfafstetter code to be interpreted
   :type pfcode: character varying
   :return: down
   :rtype: set of downstreach records

---

