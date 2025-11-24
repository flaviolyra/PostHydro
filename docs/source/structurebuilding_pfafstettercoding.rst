Pfafstetter Coding
==================

Pfafstetter coding is done in two different steps: establishing the base code of each of the basins draining to a coastline and additional coding of each basin (adding digits to its base code). The first part is addressed on the ordered mouth nodes table. The functions in this section refer to the coding of the basins, that is, coding each group of reaches between two nodes (pfcode) and developing the reaches main stream code (pfcodestr).

The process is done in steps: first the main stream is identified and coded (pfcodestr), then the nine sub basins are identified and their digits added to the code, then the even basins (proper basins) are further coded by the same recursive procedure and the odd (interbasins) by a slightly different procedure. This recursive procedure is repeated until there are no more reaches to be coded.

Types
-----


.. csv-table:: Confluences (confluence)
   :file: types/confluence.csv
   :widths: 20, 30, 50
   :header-rows: 1


Procedures and Functions
------------------------



.. py:function:: code_assign_basin (code, reachid)

   Assign code to pfcode on reachid and all its upstream reaches on hydrography table

   :param code: code to be assigned to pfcode on reachid and its upstream reaches
   :type code: character varying
   :param reachid: id of the downstream reach of the basin where code is to be assigned to pfcode
   :type reachid: integer

---


.. py:function:: index_pfcode ()

   Create an index on pfcode and pfcodestr, on hydrography table


---


.. py:function:: code (basecode)

   Code all basins starting with the single digit basecode

   :param basecode: pfafstetter code initial digit
   :type basecode: character varying(1)

---


.. py:function:: code_assign_interbasin (code, reachid, upstr_node)

   Assign code to pfcode on reachid, all its upstream reaches on the main stream up to upstr_node
   and all tributary basins found on the path, on hydrography table

   :param code: code to be assigned to pfcode on reachid and its upstream reaches until upstr_node
   :type code: character varying
   :param reachid: id of the downstream reach of the interbasin where code is to be assigned to pfcode
   :type reachid: integer
   :param upstr_node: id of the upstream node on the main stream of the interbasin where code is to be assigned to pfcode
   :type upstr_node: integer

---


.. py:function:: pfafstetter_code (basecode, reachid, main_basin)

   Pfafstetter code (pfcode and pfcodestr) an entire basin consisting of reachid and its upstream reaches, on hydrography table,
   taking as seed basecode. The basin can be a proper basin (main_basin true) or a code 9 interbasin (main_basin false)

   :param basecode: seed code upon which the basin will be further coded by the Pfafstetter method
   :type basecode: character varying
   :param reachid: id of the downstream reach of the basin to be coded
   :type reachid: integer
   :param main_basin: signals if the basin to be coded is a proper basin (true) or a 9 interbasin (false)
   :type main_basin: boolean

---


.. py:function:: main_stream (pfcodemain, reachid, mainbasin, endnode)

   Find the main stream in a Pfafstetter basin, following in the confluences the reaches with the largest area upstream,
   set its Pfafstetter stream code (pfcodestr in hydrography table), if mainbasin is true, and return the set of its confluences

   :param pfcodemain: stream pfafstetter code
   :type pfcodemain: character varying
   :param reachid: id of the downstream reach of the main stream
   :type reachid: integer
   :param mainbasin: if true, signals that it is the main stream of a proper basin, not of an interbasin 
   :type mainbasin: boolean
   :param endnode: id of the upstream node of an interbasin
   :type endnode: integer
   :return: conf
   :rtype: set of confluence records

---


.. py:function:: pfafstetter_code_interbasin (basecode, reachid, upstr_node)

   Pfafstetter code (pfcode and pfcodestr) an interbasin consisting of reachid and its upstream reaches on main stream up to upstr_node,
   and all tributary basins found on the path, on hydrography table, taking as seed basecode.

   :param basecode: seed code upon which the interbasin will be further coded by the Pfafstetter method
   :type basecode: character varying
   :param reachid: id of the downstream reach of the interbasin to be coded
   :type reachid: integer
   :param upstr_node: node code of the upstream limit (on main stream) of the interbasin to be coded
   :type upstr_node: integer

---

