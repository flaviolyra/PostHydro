.. PostHydro documentation master file, created by
   sphinx-quickstart on Sun Apr  6 19:08:11 2025.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to PostHydro's documentation!
=====================================

The goal of this project is to make possible the representation of any surface water related information, waterstreams related (linear reference) and watersheds related (surface reference), in a relational database and to be able to query this information with simple, fast, non-geographical queries.

The project relies on the previous availability of a dual spatial database, with a linear table representing water streams and lakes centerlines and a spatial table with contributing areas. Water streams lines represent river reaches and lakes centerlines, with their from and to nodes, according to the water flow. Contributing areas may refer to one or a group of connected reaches.  The node links in this form of representation of the water centerlines is what make possible the search for upstream and downstream features, which is essential for water management and studies, as it allows linking causes to effects, concerning surface water quantity and quality. Databases like these have been developed all around the world, as for instance in the United States (NHDPlus_), Australia (Geofabric_), Europe (Ecrins_) and Brazil (Base_Hidrográfica_Ottocodificada_). 

Systems built around these concepts usually require specialized GIS software for upstream downstream navigation. With PostHydro, however, this kind of query is handled by the database manager as an ordinary, non-spatial query, since the reaches table (hydrography) incorporate the Pfafstetter coding, which can be used as a simple upstream / downstream index on the table. The association of each hydrography reach to an elementary contributing area turns the query for the upstream watershed into a simple matter of aggregation of the upstream reaches' contributing areas.

Besides the capability of instantaneous querying the form and the extent of a basin upstream and its downstream path, PostHydro provides, by means of ordinary non-geographical database queries, the capability of querying, on the surface water context (that is, upstream or downstream querying), different kinds of georeferenced information related to surface water, once they have been previously referenced to the waterbasin, in a process we can call "hydroreference". This new positional reference is all we really need for water management processes or studies.

The project was developed over a PostGIS database, a geographical extension of the PostgreSQL database. The project was structured as a simple extension of PostGIS, not consisting of a formal PostgreSQL extension, but only a template database.The goal of the project is to extend PosgreSQL scope to the hydro domain, hence the name PostHydro.

As part of the project, one first mutilingual desktop client application has been developed, as a QGIS extension. The concepts used in this client can be easily applied to other client applications, such as a web application, for example.

.. _NHDPlus: https://www.epa.gov/waterdata/nhdplus-national-hydrography-dataset-plus
.. _Geofabric: https://www.ga.gov.au/scientific-topics/national-location-information/national-surface-water-information
.. _Ecrins: https://www.eea.europa.eu/en/datahub/datahubitem-view/a9844d0c-6dfb-4c0c-a693-7d991cc82e6e
.. _Base_Hidrográfica_Ottocodificada: https://metadados.snirh.gov.br/geonetwork/srv/por/catalog.search#/metadata/0c698205-6b59-48dc-8b5e-a58a5dfcc989

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   informationstructure
   pfafstettercoding
   capabilities
   desktopclient


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
