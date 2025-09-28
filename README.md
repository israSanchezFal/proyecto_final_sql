# proyecto_final_sql
Usaremos el dataset **Traffic Crashes – Crashes del Chicago Data Portal.** Contiene un registro por choque vial ocurrido en calles dentro de la ciudad y bajo jurisdicción del Chicago Police Department (CPD). Los datos provienen del sistema electrónico E-Crash, sin información personal identificable. Se agregan cuando un reporte se finaliza o se enmienda; los choques en autopistas/interstates donde CPD no responde no se incluyen. Desde el 21-nov-2023 se retiró el campo RD_NO por privacidad.
Los datos están públicos en el Chicago Data Portal (vista y exportación CSV/JSON) y en el catálogo de Data.gov (ficha espejo). Al portal se suben cuando un reporte se finaliza o se corrige; por eso **el conteo cambia con el tiempo**.


Con el siguiente dataset se planea analizar
-Tendencias por mes/año y por hora.
-Zonas y tipos de vía con mayor frecuencia y severidad.
-Relación entre clima/superficie y tipos de choque.
-Causas primarias más comunes.

El dataset cuenta con lo siguiente:
Filas (tuplas): 988,167
Columnas (atributos): 48

CRASH_RECORD_ID: identificador único del choque.
CRASH_DATE_EST_I: indicador si la fecha es estimada.
CRASH_DATE: fecha y hora del choque.
POSTED_SPEED_LIMIT: límite de velocidad señalado (mph).
TRAFFIC_CONTROL_DEVICE: control en la vía (semáforo, señal, etc.).
DEVICE_CONDITION: condición del dispositivo (funcional, apagado…).
WEATHER_CONDITION: clima al momento.
LIGHTING_CONDITION: iluminación (día, noche, alumbrado…).
FIRST_CRASH_TYPE: primer tipo de impacto (ángulo, trasero, etc.).
TRAFFICWAY_TYPE: tipo de vía (calle, avenida, rampa…).
LANE_CNT: número de carriles.
ALIGNMENT: alineación de la vía (recta, curva…).
ROADWAY_SURFACE_COND: condición de superficie (seca, mojada…).
ROAD_DEFECT: defecto en la vía (bache, irregularidad…).
REPORT_TYPE: tipo de reporte (policial, a distancia, etc.).
CRASH_TYPE: clasificación general del choque.
INTERSECTION_RELATED_I: indicador si está relacionado con intersección.
NOT_RIGHT_OF_WAY_I: indicador de no ceder paso.
HIT_AND_RUN_I: fuga del lugar.
DAMAGE: nivel de daños (p. ej., estimado económico).
DATE_POLICE_NOTIFIED: fecha/hora en que la policía fue notificada.
PRIM_CONTRIBUTORY_CAUSE: causa primaria atribuida.
SEC_CONTRIBUTORY_CAUSE: causa secundaria.
STREET_NO: número de calle/dirección.
STREET_DIRECTION: dirección (N, S, E, W).
STREET_NAME: nombre de la calle.
BEAT_OF_OCCURRENCE: cuadrante/beat policial.
PHOTOS_TAKEN_I: indicador de fotos tomadas.
STATEMENTS_TAKEN_I: indicador de declaraciones tomadas.
DOORING_I: indicador de “dooring” (puerta de auto a ciclista).
WORK_ZONE_I: indicador de zona de obra.
WORK_ZONE_TYPE: tipo de zona de obra.
WORKERS_PRESENT_I: trabajadores presentes.
NUM_UNITS: número de unidades/vehículos involucrados.
MOST_SEVERE_INJURY: lesión más severa presente.
INJURIES_TOTAL: total de lesionados.
INJURIES_FATAL: fallecidos.
INJURIES_INCAPACITATING: lesiones incapacitantes.
INJURIES_NON_INCAPACITATING: lesiones no incapacitantes.
INJURIES_REPORTED_NOT_EVIDENT: lesión reportada sin evidencia.
INJURIES_NO_INDICATION: sin indicio de lesión.
INJURIES_UNKNOWN: lesión desconocida.
CRASH_HOUR: hora del choque (0–23).
CRASH_DAY_OF_WEEK: día de la semana (1–7).
CRASH_MONTH: mes (1–12).
LATITUDE, LONGITUDE: coordenadas del evento.
LOCATION: punto geográfico (objeto/geo-WKT

Numéricos: POSTED_SPEED_LIMIT, LANE_CNT, STREET_NO, BEAT_OF_OCCURRENCE, NUM_UNITS, todos los INJURIES_*, CRASH_HOUR, CRASH_DAY_OF_WEEK, CRASH_MONTH, LATITUDE, LONGITUDE.


Categóricos (incluye banderas Y/N): TRAFFIC_CONTROL_DEVICE, DEVICE_CONDITION, WEATHER_CONDITION, LIGHTING_CONDITION, FIRST_CRASH_TYPE, TRAFFICWAY_TYPE, ALIGNMENT, ROADWAY_SURFACE_COND, ROAD_DEFECT, REPORT_TYPE, CRASH_TYPE, INTERSECTION_RELATED_I, NOT_RIGHT_OF_WAY_I, HIT_AND_RUN_I, DAMAGE, PHOTOS_TAKEN_I, STATEMENTS_TAKEN_I, DOORING_I, WORK_ZONE_I, WORK_ZONE_TYPE, WORKERS_PRESENT_I, MOST_SEVERE_INJURY, STREET_DIRECTION, PRIM_CONTRIBUTORY_CAUSE, SEC_CONTRIBUTORY_CAUSE, CRASH_DATE_EST_I.


Texto/ID: CRASH_RECORD_ID (identificador), STREET_NAME, LOCATION (texto geográfico).


Temporales/fecha-hora: CRASH_DATE, DATE_POLICE_NOTIFIED.
