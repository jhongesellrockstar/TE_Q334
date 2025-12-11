# Informe de revisión MapSWAT v3.1 (fork Q334)

## 1. Propósito y alcance
Documento informativo para el avance mensual: resume la arquitectura del plugin MapSWAT, los cambios de interfaz detectados entre versiones originales y modificadas, y las acciones necesarias para mantenerlo operativo en QGIS 3.34, preparar una variante personalizada (p.ej., "MapSWAT_IGP") y dejar la base lista para empaquetar un instalador.

## 2. Arquitectura del plugin
1. **Carga en QGIS**: `__init__.py` expone `classFactory`, que crea la instancia principal (`Base`). Esta añade la acción con icono `:/imgMapSWAT/images/icon.png` al menú/toolbar y abre el diálogo principal al activarse.
2. **Inicialización de GUI**: `Base` instancia `BaseDialog` (flujo MapSWAT) o `BaseDialog_GEE` (flujo GEE) según elección del usuario. Cada clase hereda de `QDialog` y de las clases generadas por `pyuic5` (`Ui_BaseDialog`, `Ui_BaseDialog_GEE`), inicializando filtros de archivo, CRS y lógicas de botones.
3. **Recursos**: `resources_rc.py` registra los iconos/imágenes de `resources.qrc`, permitiendo rutas `:/imgMapSWAT/...` usadas en la UI y en las acciones del plugin.

## 3. Comparación de interfaces y recursos
1. **BaseDialog (offline)**: No hay diferencias entre `ui.resources_original/ui_BaseDialog.ui` y `ui.resources/ui_BaseDialog.ui`; los `objectName` y layouts se mantienen, sin riesgo para `BaseDialog.py`.
2. **BaseDialog_GEE (online)**:
   * Versión modificada amplía el tamaño de ventana y reorganiza controles en `QGroupBox` por etapas.
   * Se añaden botones de información (`pushButton_infoMaps_*`), un botón "GET MAPS" y se reagrupan combos/etiquetas para descargas GEE.
   * Los `objectName` usados por `BaseDialog_GEE.py` (combos de DEM/LANDUSE/SOIL/AUTOBASIN) se conservan, pero el código no interactúa con los nuevos botones de ayuda (solo las señales definidas en el `.ui`).
3. **Recursos (.qrc)**: No hay cambios entre `ui.resources_original/resources.qrc` y `ui.resources/resources.qrc`; la lista de iconos permanece.

## 4. Recompilación y ajustes necesarios
1. Con los `.ui` actuales, basta recompilar:
   * `python-qgis-ltr.bat -m PyQt5.uic.pyuic ui.resources/ui_BaseDialog.ui -o gui/generated/ui_dialog.py`
   * `python-qgis-ltr.bat -m PyQt5.uic.pyuic ui.resources/ui_BaseDialog_GEE.ui -o gui/generated/ui_dialog_GEE.py`
   * `python-qgis-ltr.bat -m PyQt5.pyrcc_main ui.resources/resources.qrc -o gui/generated/resources_rc.py`
2. No se requieren cambios adicionales en imports ni rutas de recursos. `BaseDialog.py` y `BaseDialog_GEE.py` seguirán funcionando siempre que el paquete conserve el nombre actual; si se renombra el plugin, ajustar los imports al nuevo paquete.
3. `metadata.txt` solo necesita actualización si se cambia el nombre/versión/icono del plugin.

## 5. Compatibilidad con QGIS 3.34
1. El código generado usa PyQt5 y widgets de QGIS modernos (`QgsFileWidget`, `QgsProjectionSelectionWidget`); no hay referencias a PyQt4.
2. APIs como `QgsProject.instance().setCrs(...)` son compatibles con QGIS 3.34. Mejora opcional: sustituir imports comodín de `qgis.core` por imports explícitos para limpieza de código.

## 6. Plan para variante personalizada ("MapSWAT_IGP")
1. **Estabilizar el fork**: recompilar `.ui` y `.qrc`, probar ambos flujos (MapSWAT y GEE) en QGIS 3.34 verificando botones de info y descargas.
2. **Renombrar plugin**:
   * Actualizar `metadata.txt` (name, description, icon, version).
   * Renombrar carpeta/paquete y ajustar imports internos (`__init__.py`, `Base.py`, diálogos) al nuevo nombre, manteniendo `gui/generated`.
   * Revisar textos visibles (menú/toolbar) en `Base.py` para reflejar el nuevo nombre.
3. **Simplificar flujo a 3 pasos (DEM, LANDUSE, SOIL → cuenca → CRS)**:
   * Reorganizar/ocultar pasos en `BaseDialog.py` y, si aplica, ajustar layouts en `ui_BaseDialog*.ui` usando Qt Designer.
   * En GEE, aprovechar los `QGroupBox` añadidos para agrupar los tres pasos y validar entradas antes de "GET MAPS".
4. **Fuentes de datos para Sudamérica**:
   * Extender combos en `ui_BaseDialog_GEE.ui` y mapearlos en `BaseDialog_GEE.py` para nuevas fuentes (p.ej., ALOS PALSAR o MERIT DEM; MapBiomas o Copernicus global para LULC; SoilGrids/HWSD para suelos).
   * En modo offline, añadir presets en los JSON de `resources` si se incorporan leyendas/reescalados nuevos.
5. **Preparar instalador .exe**:
   * Tras renombrar y probar, generar los archivos compilados (`ui_dialog*.py`, `resources_rc.py`) y empaquetar la carpeta del plugin.
   * Replicar el script de Inno Setup del instalador original ajustando nombre, ruta y versión para "MapSWAT_IGP" y probar en QGIS 3.34 LTR.

## 7. Observaciones finales
* Los cambios de GUI en GEE son principalmente estéticos/organización; no afectan la lógica existente.
* No se detectan riesgos de rotura por `objectName` cambiados; sólo hay que asegurar que los nuevos botones de info sigan conectados a sus funciones si se modifican.
