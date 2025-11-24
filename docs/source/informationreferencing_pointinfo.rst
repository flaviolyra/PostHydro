Point Information Referencing
=============================

The reference of a point or linear characteristic is done by adding water stream location information (reach id, pfafstetter code, river code and name, distance to the river and basin mouths) as new columns on the original point table (or on a table of the linear characteristic).

The process of point information referencing consists on the linear referencing of a point on the nearest reach on the database to which it refers. Some of the points to be referenced do not lie on a represented reach, but instead are located on a non represented reach, upstream of a specific point on one of the represented reaches. These points can also be indirectly referenced to the reaches, once their corresponding influence points are provided.

The process of referencing of a specific point feature is generic. It takes as input a generic table called pts_direct_indirect, where the point key, name and geometry are provided, besides the hydroreferencing form ('direct' or 'indirect') and the additional influence point geometry, if the referencing form is indirect.

The hydroref_points procedure generates the generic hydroref_points table, with point key, name, geometry and hydroreference form, plus information on its location on the hydrography reach database (id and pfafstetter code of the reach, distance along the hydrography to the basin mouth, river code, name and distance to the river mouth, if available, distance between the direct or indirect point and the exact point on the geometry of the reach and the geometry of the exact point on the hydrography reach).

The locating information is transfered from the hydroref_points table to the point feature specific table, as additional columns. 


Tables
------


.. csv-table:: Points to Hydroreference (pts_direct_indirect table)
   :file: tables/pts_direct_indirect.csv
   :widths: 20, 30, 50
   :header-rows: 1

---

.. csv-table:: Hydroreferenced Points (hydroref_points table)
   :file: tables/hydroref_points.csv
   :widths: 20, 30, 50
   :header-rows: 1


Procedures and Functions
------------------------



.. py:function:: hydroref_points (max_dist)

   Create table hydroref_points, from locating points, on pts_direct_indirect table, on the nearest reach of the hydrography table
   Points on the  pts_direct_indirect table have an id, name, a geometry, a hydroreference form ('direct' or 'indirect')
   and, if the point's reach is not represented in the hydrography ('indirect' form), the geometry of the point's influence
   point on the hydrography, that is, the nearest downstream point on the represented hydrography.
   The hydroref_points table has the id, name, real geometry and hydroreference form of the point, plus its location in the hydrography
   table (id and pfafstetter code of the reach, distance along the hydrography to the basin mouth, river code, name and distance
   to the river mouth, if available, distance between the direct or indirect point and the exact point on the geometry of the reach,
   plus the geometry of the exact point on the hydrography.
   To account for the rare cases in which there are representation errors in the hydrography that would lead to error in the
   hydroreference of the point, a hydref_disregard table, with the id of the reaches that should not be considered in the process, is
   provided. The search for the hydrography reaches is done within a max_dist distance of the point.

   :param max_dist: search radius when looking for a point coastline
   :type max_dist: double precision

---

