PostHydro
=========

PostHydro is a database template that makes possible building a client-server water resources information system, exclusively based on a relational database. It was built on a PostgreSQL - PostGIS database, but the concepts used can easily be adapted to any other relational database with a vector spatial information extension.

PostHydro Database Capabilities
-------------------------------

The PostHydro database is just a generic template, not related to any hydrological region. It provides a set of tools to assist the development of a region specific database. It also provides tools to reference any kind of spatial or water streams related geographical feature to the specific region hydrography context (surface water referencing, or hydroreferencing, the information), and to query the entire resulting database, made of the hydrography elements of a region and the added features, on a surface water context (upstream or downstream of a point) with fast, non-spatial, ordinary database queries.

Client Application
------------------

A first client application was also developed, a desktop client built as a generic Python plugin for a QGIS application. The Python plugin is not region or feature specific. It relies on the hydrography information on the database and on the tables that express the streams related and spatial hydroreferenced information. It is completely guided by a database table called information_application that serves as a directory of the available features and as a pointer to the plugin functions and database tables to be used to query and depict the results on QGIS. These same concepts can easily be extended in the development of other clients, as for instance a web client.

Creating a PostHydro Database
-----------------------------

The PostHydro database can be created on top of a PostGIS enabled database, using the postthydro.gz file with:

gunzip -c posthydro.gz | psql -U your_username -d posthydro

Plugin Creation
---------------

The plugin can be installed from its zipfile (upstream_downstream/zip_build/upstream_downstream.zip).

Documentation
-------------

Project documentation is available at https://posthydro.readthedocs.io/en/latest/index.html


