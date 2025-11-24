# -*- coding: utf-8 -*-
"""
/***************************************************************************
 UpstreamDownstreamTool
                                 
 on clicking a hydrography reach, identifies the river reach and opens a
 dialog box that allows specifying the desired upstream or downstream features
 and creating the corresponding layers and attribute tables
                               -------------------
        begin                : 2021-07-12
        git sha              : $Format:%H$
        copyright            : (C) 2021 by Flavio J. Lyra
        email                : flavio.jose.lyra@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""

from qgis.PyQt.QtCore import QSettings, QTranslator, QCoreApplication, QVariant, QLocale
from qgis.gui import QgsMapToolEmitPoint
from qgis.utils import iface, plugins
from qgis.core import QgsRectangle, QgsDataSourceUri, QgsVectorLayer, QgsProject, QgsFillSymbol, QgsField, QgsFeature
from qgis.PyQt.QtWidgets import QMessageBox, QTreeWidgetItem
from .upstream_downstream_dialog import UpstreamDownstreamDialog
import psycopg2
import os.path

class LayerError(Exception):
    pass

class NoneSelectedError(Exception):
    pass

class InvalidMapError(Exception):
    pass

class DataBaseAccessError(Exception):
    pass

class InformationApplicationTableAcessError(Exception):
    pass

class AccumulatedFeatureTablesAcessError(Exception):
    pass

class UpstreamDownstreamTool(QgsMapToolEmitPoint):

    def __init__(self, canvas):
        self.canvas = canvas
        QgsMapToolEmitPoint.__init__(self, canvas)

        
    # noinspection PyMethodMayBeStatic
    def tr(self, message):
        """Get the translation for a string using Qt translation API.
        
        :param message: String for translation.
        :type message: str, QString

        :returns: Translated version of message.
        :rtype: QString
        """
        # noinspection PyTypeChecker,PyArgumentList,PyCallByClass
        return QCoreApplication.translate('UpstreamDownstreamTool', message)

    def canvasPressEvent(self, e):
        """React to clicking on the canvas.
        
        :param e: Mouse click event.
        :type e: event, QMouseEvent
        """
        try:
            # if current layer is not hydrography signal error
            self.layer=self.canvas.currentLayer()
            if not self.layer or self.layer.name() != 'hydrography':
                raise LayerError()
            # extract in uri_ex the PostGIS connection info of the layer
            self.uri_ex = QgsDataSourceUri(self.layer.source())
            self.host = self.uri_ex.host()
            self.port = self.uri_ex.port()
            self.database = self.uri_ex.database()
            self.username = self.uri_ex.username()
            self.password = self.uri_ex.password()
            # select on the layer using a 4 x 4 pixels square around the click
            lwrleftpt = self.canvas.getCoordinateTransform().toMapCoordinates(e.pos().x()-2, e.pos().y()+2)
            upprightpt = self.canvas.getCoordinateTransform().toMapCoordinates(e.pos().x()+2, e.pos().y()-2)
            self.layer.removeSelection()
            self.layer.selectByRect(QgsRectangle(lwrleftpt, upprightpt))
            #look for river name, pfafstetter code, upstream area, river code, distance to the mouth, length up and gid
            # of the selected reaches
            sel_attr_lst=[]
            for reach in self.layer.selectedFeatures():
                sel_attr_lst.append([reach['rivname'], reach['pfcode'], reach['areaupkm2'], reach['rivcode'], reach['lngthtomouth'],
                    reach['lngthrivmouth'], reach['mxlengthup'], reach['gid'], reach['areaid'], reach['is_main_rch']])
            if not sel_attr_lst:
                raise NoneSelectedError()
            # take the reach with longest length up
            reach = sorted(sel_attr_lst, key = lambda rch: rch[6])[-1]
            pfcode = reach[1]
            reachid = reach[7]
            areaid = reach[8]
            dist_basin_mouth = reach[4]
            dist_river_mouth = reach[5]
            ismainrch = reach[9]
            # disable the tool
            self.canvas.unsetMapTool(self.canvas.mapTool())
            # Create the dialog
            self.dlg = UpstreamDownstreamDialog()
            # write on the dialog river name, distance along the river in km and watershed area
            if reach[0]:
                textlabel = ("{0} - km {1} - " + self.tr("Code:") + " {2}").format(
                    reach[0], QLocale().toString(round(dist_river_mouth, 2)), reach[3])
                self.dlg.label.setText(textlabel)
            textlabel = self.tr("Distance to Basin Mouth:") + " - {0} km".format(QLocale().toString(round(dist_basin_mouth, 2)))
            self.dlg.label_2.setText(textlabel)
            textlabel = (self.tr("Watershed Area:") + " {0} km2").format(QLocale().toString(round(reach[2], 2)))
            self.dlg.label_3.setText(textlabel)
            # create and present as a GUI table a list of available topological features according to the information application table
            self.dlg.treeWidget.setHeaderLabels([self.tr('Feature'), self.tr('Topology'),
                 self.tr('Form')])
            try:
                conn = psycopg2.connect(host=self.host, port=self.port, database=self.database, user=self.username,
                    password=self.password)
            except:
                raise DataBaseAccessError()
            cur = conn.cursor()
            # rows get the information_application table records corresponding to present locale
            locale = QSettings().value('locale/userLocale')[0:2]
            try:
                cur.execute("SELECT * FROM information_application WHERE locale = \'" + locale + "\';")
            except:
                raise InformationApplicationTableAcessError()
            rows = cur.fetchall()
            # if no records are found for the present locale, get those corresponding to english
            if not any(rows):
                try:
                    cur.execute("SELECT * FROM information_application WHERE locale = \'en\';")
                except:
                    raise InformationApplicationTableAcessError()
                rows = cur.fetchall()
            tableItems = []
            methodTableItems = []
            for row in rows:
                # generate a table line item (listItem) with the feature, topology and type of the information item
                lineItems = []
                lineItems.append(row[1])
                lineItems.append(row[2])
                lineItems.append(row[3])
                listItem = QTreeWidgetItem(lineItems, 0)
                # add the item to the table items list
                tableItems.append(listItem)
                # generates the tableline-parameters-method list with listItem as its first element,
                # identifying the desired feature, along with variable, accumtable_name, nonaccumtable_name, key_table, description_name,
                # value_name and method
                methodTableLine = []
                methodTableLine.append(listItem)
                methodTableLine.append(row[1])
                methodTableLine.append(row[4])
                methodTableLine.append(row[5])
                methodTableLine.append(row[6])
                methodTableLine.append(row[7])
                methodTableLine.append(row[8])
                methodTableLine.append(row[9])
                # add the the table-method pair to the table line-method list
                methodTableItems.append(methodTableLine)
            # creates the table with tableItems list 
            self.dlg.treeWidget.insertTopLevelItems(0, tableItems)
            # exhibit the dialog
            self.dlg.show()
            # Enter the dialog loop
            result = self.dlg.exec_()
            # Once OK is pressed
            if result:
                # create a new uri of the PostGIS database with connection data corresponding to the hydrography layer
                self.uri = QgsDataSourceUri()
                self.uri.setConnection (self.host, self.port, self.database, self.username, self.password)
                selected_items = self.dlg.treeWidget.selectedItems()
                # call those methods on the table line - method table that were selected  
                for methodTableLine in methodTableItems:
                    item = methodTableLine[0]
                    title = methodTableLine[1]
                    tablename = methodTableLine[2]
                    nonaccum_tbl = methodTableLine[3]
                    key_table = methodTableLine[4]
                    description_name = methodTableLine[5]
                    value_name = methodTableLine[6]
                    method = methodTableLine[7]
                    if selected_items.count(item):
                        getattr(self, method)(reachid, areaid, pfcode, dist_basin_mouth, title, tablename, nonaccum_tbl,
                            key_table, description_name, value_name, ismainrch)
                # sets current layer back to hydrography
                iface.setActiveLayer(self.layer)

        except DataBaseAccessError:
            msgBox = QMessageBox()
            msgBox.setText(self.tr("No access to the database"))
            msgBox.exec_()
            
        except InformationApplicationTableAcessError:
            msgBox = QMessageBox()
            msgBox.setText(self.tr("No access to the information_application table"))
            msgBox.exec_()
            
        except AccumulatedFeatureTablesAcessError:
            msgBox = QMessageBox()
            msgBox.setText(self.tr("No access to the accumulated features tables"))
            msgBox.exec_()
            
        except LayerError:
            msgBox = QMessageBox()
            msgBox.setText(self.tr("Please select hydrography layer"))
            msgBox.exec_()
            
        except NoneSelectedError:
            pass
            
        except KeyError:
            msgBox = QMessageBox()
            msgBox.setText(self.tr("Hydrography layer does not have the right attributes"))
            msgBox.exec_()
            
        except InvalidMapError:
            msgBox = QMessageBox()
            msgBox.setText(self.tr("Could not create the map"))
            msgBox.exec_()
            
    def generateWatershed(self, reachid, areaid, pfcode, dist, title, tablename, nonaccum_tbl, key_table, description_name, value_name,
                          ismainrch):
        """Generate a new layer with the set of upstream contributing areas.
        
        :param reachid: Selected reach id.
        :type reachid: int
        :param areaid: Selected reach contributing area id.
        :type areaid: int
        :param pfcode: pfcode: Selected reach Pfafstetter code.
        :type pfcode: str
        :param dist: Selected reach distance to the basin mouth.
        :type dist: float
        :param title: Feature of interest in locale (or default english) language.
        :type title: str
        :param tablename: Not applicable in this context.
        :type tablename: str
        :param nonaccum_tbl: Not applicable in this context.
        :type nonaccum_tbl: str
        :param key_table: Not applicable in this context.
        :type key_table: str
        :param description_name: Not applicable in this context.
        :type description_name: str
        :param value_name: Not applicable in this context.
        :type value_name: str
        :param ismainrch: Selected reach main reach flag.
        :type ismainrch: bool
        """
        # get active layer (hydrography) credentials
        # select table contrib_area - column geom as data source
        self.uri.setDataSource('public', 'contrib_area', 'geom')
        # generate the sql string for all contributing areas upstream of the reach whose pfafstetter code
        # is pfcode and distance to the mouth is dist (those where up_reachid is in up_reaches(pfcode, dist))
        string_sql = '"gid" IN (SELECT * FROM up_areas(\'' + pfcode + '\', ' + '{0:f}'.format(dist) + '))'
        self.uri.setSql(string_sql)
        #generate the map title
        title = self.tr('Area Upstream of ') + str(reachid)
        # generate the layer and add to the project
        layer = QgsVectorLayer(self.uri.uri(), title, 'postgres')
        if not layer.isValid():
            raise InvalidMapError
        project = QgsProject.instance()
        project.addMapLayer(layer)
        # set border of the polygons with the same color of the fill and refresh the map
        properties = layer.renderer().symbol().symbolLayers()[0].properties()
        color = properties['color']
        properties['outline_color'] = color
        fillsymbol = QgsFillSymbol.createSimple(properties)
        layer.renderer().setSymbol(fillsymbol)
        layer.triggerRepaint()
        
    def generateMainStreamDown(self, reachid, areaid, pfcode, dist, title, tablename, nonaccum_tbl, key_table, description_name,
                               value_name, ismainrch):
        """Generate a new layer with the set of downstream reaches along the main path.
        
        :param reachid: Selected reach id.
        :type reachid: int
        :param areaid: Selected reach contributing area id.
        :type areaid: int
        :param pfcode: pfcode: Selected reach Pfafstetter code.
        :type pfcode: str
        :param dist: Selected reach distance to the basin mouth.
        :type dist: float
        :param title: Feature of interest in locale (or default english) language.
        :type title: str
        :param tablename: Not applicable in this context.
        :type tablename: str
        :param nonaccum_tbl: Not applicable in this context.
        :type nonaccum_tbl: str
        :param key_table: Not applicable in this context.
        :type key_table: str
        :param description_name: Not applicable in this context.
        :type description_name: str
        :param value_name: Not applicable in this context.
        :type value_name: str
        :param ismainrch: Selected reach main reach flag.
        :type ismainrch: bool
       """
        # select table hydrography - column geom as data source
        self.uri.setDataSource('public', 'hydrography', 'geom')
        # generate the sql string for reaches downstream on the main path of the reach whose pfafstetter code
        # is pfcode and distance to the mouth is dist (those where gid is in down_reaches(pfcode, dist))
        string_sql = '"gid" IN (SELECT * FROM down_reaches(\'' + pfcode + '\', ' + '{0:f}'.format(dist) + '))'
        self.uri.setSql(string_sql)
        #generate the layer title
        layertitle = self.tr('Path Downstream of ') + str(reachid)
        # generate the layer and add to the project
        layer = QgsVectorLayer(self.uri.uri(), layertitle, 'postgres')
        if not layer.isValid():
            raise InvalidMapError
        project = QgsProject.instance()
        project.addMapLayer(layer)
        
    def generateUpstreamReaches(self, reachid, areaid, pfcode, dist, title, tablename, nonaccum_tbl, key_table, description_name,
                                value_name, ismainrch):
        """Generate a new layer with the set of upstream reaches.
        
        :param reachid: Selected reach id.
        :type reachid: int
        :param areaid: Selected reach contributing area id.
        :type areaid: int
        :param pfcode: pfcode: Selected reach Pfafstetter code.
        :type pfcode: str
        :param dist: Selected reach distance to the basin mouth.
        :type dist: float
        :param title: Feature of interest in locale (or default english) language.
        :type title: str
        :param tablename: Not applicable in this context.
        :type tablename: str
        :param nonaccum_tbl: Not applicable in this context.
        :type nonaccum_tbl: str
        :param key_table: Not applicable in this context.
        :type key_table: str
        :param description_name: Not applicable in this context.
        :type description_name: str
        :param value_name: Not applicable in this context.
        :type value_name: str
        :param ismainrch: Selected reach main reach flag.
        :type ismainrch: bool
       """
        # select table hydrography - column geom as data source
        self.uri.setDataSource('public', 'hydrography', 'geom')
        # generate the sql string for all reaches upstream of the reach whose pfafstetter code
        # is pfcode and distance to the mouth is dist (those where gid is in up_reaches(pfcode, dist))
        string_sql = '"gid" IN (SELECT * FROM up_reaches(\'' + pfcode + '\', ' + '{0:f}'.format(dist) + '))'
        self.uri.setSql(string_sql)
        #generate the layer title
        layertitle = self.tr('Reaches Upstream of ') + str(reachid)
        # generate the layer and add to the project
        layer = QgsVectorLayer(self.uri.uri(), layertitle, 'postgres')
        if not layer.isValid():
            raise InvalidMapError
        project = QgsProject.instance()
        project.addMapLayer(layer)
        
    def generateCompletePathDownstream(self, reachid, areaid, pfcode, dist, title, tablename, nonaccum_tbl, key_table,
                                       description_name, value_name, ismainrch):
        """Generate a new layer with the set of downstream reaches along the main path and divergences.
        
        :param reachid: Selected reach id.
        :type reachid: int
        :param areaid: Selected reach contributing area id.
        :type areaid: int
        :param pfcode: pfcode: Selected reach Pfafstetter code.
        :type pfcode: str
        :param dist: Selected reach distance to the basin mouth.
        :type dist: float
        :param title: Feature of interest in locale (or default english) language.
        :type title: str
        :param tablename: Not applicable in this context.
        :type tablename: str
        :param nonaccum_tbl: Not applicable in this context.
        :type nonaccum_tbl: str
        :param key_table: Not applicable in this context.
        :type key_table: str
        :param description_name: Not applicable in this context.
        :type description_name: str
        :param value_name: Not applicable in this context.
        :type value_name: str
        :param ismainrch: Selected reach main reach flag.
        :type ismainrch: bool
       """
        # select table hydrography - column geom as data source
        self.uri.setDataSource('public', 'hydrography', 'geom')
        # generate the sql string for reaches downstream on all paths of the reach whose pfafstetter code
        # is cobacia and distance to the mouth is dist (those where gid is in total_down_reaches(pfcode, dist))
        string_sql = '"gid" IN (SELECT unnest(total_down_reaches(\'' + pfcode + '\', ' + '{0:f}'.format(dist) + ', \'{}\', TRUE)))'
        self.uri.setSql(string_sql)
        #generate the layer title
        layertitle = self.tr('Total Downstream path of ') + str(reachid)
        # generate the layer and add to the project
        layer = QgsVectorLayer(self.uri.uri(), layertitle, 'postgres')
        if not layer.isValid():
            raise InvalidMapError
        project = QgsProject.instance()
        project.addMapLayer(layer)
        
    def generateDownstreamPointFeatures(self, reachid, areaid, pfcode, dist, title, tablename, nonaccum_tbl, key_table,
                                        description_name, value_name, ismainrch):
        """Generate a new layer with the set of a point feature elements directly on reaches along the main path downstream.
        
        :param reachid: Selected reach id.
        :type reachid: int
        :param areaid: Selected reach contributing area id.
        :type areaid: int
        :param pfcode: pfcode: Selected reach Pfafstetter code.
        :type pfcode: str
        :param dist: Selected reach distance to the basin mouth.
        :type dist: float
        :param title: Feature of interest in locale (or default english) language.
        :type title: str
        :param tablename: Point feature table name.
        :type tablename: str
        :param nonaccum_tbl: Not applicable in this context.
        :type nonaccum_tbl: str
        :param key_table: Not applicable in this context.
        :type key_table: str
        :param description_name: Not applicable in this context.
        :type description_name: str
        :param value_name: Not applicable in this context.
        :type value_name: str
        :param ismainrch: Selected reach main reach flag.
        :type ismainrch: bool
        """
        # select tablename - column geom as data source
        self.uri.setDataSource('public', tablename, 'geom')
        # generate the sql string for features on reaches downstream on the main path of the reach whose pfafstetter code
        # is pfcode and distance to the mouth is dist (those where reachid is in down_reaches(pfcode, dist))
        string_sql_1 = '"reachid" IN (SELECT * FROM down_reaches(\'' + pfcode + '\', ' + '{0:f}'.format(dist) + '))'
        string_sql_2 = ' AND "hydroref_form" = \'direct\''
        self.uri.setSql(string_sql_1 + string_sql_2)
        #generate the layer title
        layertitle = title + self.tr(' Downstream of ') + str(reachid)
        # generate the layer and add to the project
        layer = QgsVectorLayer(self.uri.uri(), layertitle, 'postgres')
        if not layer.isValid():
            raise InvalidMapError
        project = QgsProject.instance()
        project.addMapLayer(layer)
             
    def generateUpstreamPointFeatures(self, reachid, areaid, pfcode, dist, title, tablename, nonaccum_tbl, key_table,
                                      description_name, value_name, ismainrch):
        """Generate a new layer with the set of a point feature elements on reaches upstream.
        
        :param reachid: Selected reach id.
        :type reachid: int
        :param areaid: Selected reach contributing area id.
        :type areaid: int
        :param pfcode: pfcode: Selected reach Pfafstetter code.
        :type pfcode: str
        :param dist: Selected reach distance to the basin mouth.
        :type dist: float
        :param title: Feature of interest in locale (or default english) language.
        :type title: str
        :param tablename: Point feature table name.
        :type tablename: str
        :param nonaccum_tbl: Not applicable in this context.
        :type nonaccum_tbl: str
        :param key_table: Not applicable in this context.
        :type key_table: str
        :param description_name: Not applicable in this context.
        :type description_name: str
        :param value_name: Not applicable in this context.
        :type value_name: str
        :param ismainrch: Selected reach main reach flag.
        :type ismainrch: bool
       """
        # select tablename - column geom as data source
        self.uri.setDataSource('public', tablename, 'geom')
        # generate the sql string for features on reaches upstream of the reach whose pfafs tetter code
        # is pfcode and distance to the mouth is dist (those where reachid is in up_reaches(pfcode, dist)))
        string_sql_1 = '"reachid" IN (SELECT * FROM up_reaches(\'' + pfcode + '\', ' + '{0:f}'.format(dist) + '))'
        self.uri.setSql(string_sql_1)
        #generate the layer title
        layertitle = title + self.tr(' Upstream of ') + str(reachid)
        # generate the layer and add to the project
        layer = QgsVectorLayer(self.uri.uri(), layertitle, 'postgres')
        if not layer.isValid():
            raise InvalidMapError
        project = QgsProject.instance()
        project.addMapLayer(layer)
                
    def generateUpstreamSpatialFeatures(self, reachid, areaid, pfcode, dist, title, tablename, nonaccum_tbl, key_table,
                                        description_name, value_name, ismainrch):
        """Generate a table layer with feature element - value pairs describing upstream characteristics of a spatial feature.
        
        :param reachid: Selected reach id.
        :type reachid: int
        :param areaid: Selected reach contributing area id.
        :type areaid: int
        :param pfcode: pfcode: Selected reach Pfafstetter code.
        :type pfcode: str
        :param dist: Selected reach distance to the basin mouth.
        :type dist: float
        :param title: Feature of interest in locale (or default english) language.
        :type title: str
        :param tablename: Spatial feature accumulated value table name.
        :type tablename: str
        :param nonaccum_tbl: Spatial feature non accumulated value table name.
        :type nonaccum_tbl: str
        :param key_table: Spatial feature key table name.
        :type key_table: str
        :param description_name: Spatial feature table feature descriptor in locale (or default english) language.
        :type description_name: str
        :param value_name: Spatial feature table value descriptor in locale (or default english) language.
        :type value_name: str
        :param ismainrch: Selected reach main reach flag.
        :type ismainrch: bool
       """
        # create a memory table layer without geometry
        layertitle = title + self.tr(' Upstream of ') + str(reachid)
        layer = QgsVectorLayer("None", layertitle, "memory")
        # enter layer editing mode
        layer.startEditing()
        # add description_name and value_name fields
        provider = layer.dataProvider()
        provider.addAttributes([QgsField(description_name, QVariant.String), QgsField(value_name, QVariant.Double)])
        layer.updateFields()
        # query the join of the key_table with the accumulated value table (tablename)
        # corresponding to the present locale and areaid
        try:
            conn = psycopg2.connect(host=self.host, port=self.port, database=self.database, user=self.username, password=self.password)
        except:
            raise DataBaseAccessError()
        cur = conn.cursor()
        locale = QSettings().value('locale/userLocale')[0:2]
        objtable = tablename
        if not ismainrch:
            objtable = nonaccum_tbl
        string_sql1 = "SELECT description, value FROM {0} AS d INNER JOIN {1} AS a ".format(key_table, objtable)
        string_sql2 = "ON a.id = d.id WHERE d.locale = \'{0}\' AND areaid = {1} ORDER BY d.id;".format(locale, areaid)
        try:
            cur.execute(string_sql1 + string_sql2)
        except:
            raise AccumulatedFeatureTablesAcessError()
        rows = cur.fetchall()
        # if no records are found for the present locale, get those corresponding to english
        if not any(rows):
            string_sql2 = "ON a.id = d.id WHERE d.locale = \'en\' AND areaid = {0} ORDER BY d.id;".format(areaid)
            try:
                cur.execute(string_sql1 + string_sql2)
            except:
                raise AccumulatedFeatureTablesAcessError()
            rows = cur.fetchall()
        # add the result of the query to the memory table layer and add the table to the project
        for row in rows:
            feat = QgsFeature()
            feat.setAttributes([row[0], row[1]])
            provider.addFeatures([feat])
        layer.commitChanges()
        project = QgsProject.instance()
        project.addMapLayer(layer)

