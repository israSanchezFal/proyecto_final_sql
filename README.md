# 🚦 Chicago Traffic Crashes 

![Estado](https://img.shields.io/badge/status-en_progreso-blue)
![Licencia](https://img.shields.io/badge/licencia-MIT-green)
![Dataset](https://img.shields.io/badge/dataset-Chicago_Data_Portal-black)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16.x-316192)

---
## Descripción general
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
| Columna | Tipo | Descripción breve |
|---|---|---|
| CRASH_RECORD_ID | ID | Identificador único de choque |
| CRASH_DATE_EST_I | Categórica (Y/N) | Fecha estimada |
| CRASH_DATE | Fecha-hora | Momento del choque |
| POSTED_SPEED_LIMIT | Numérico | Límite de velocidad (mph) |
| TRAFFIC_CONTROL_DEVICE | Categórica | Semáforo, señal, etc. |
| DEVICE_CONDITION | Categórica | Condición del dispositivo |
| WEATHER_CONDITION | Categórica | Clima |
| LIGHTING_CONDITION | Categórica | Iluminación |
| FIRST_CRASH_TYPE | Categórica | Primer tipo de impacto |
| TRAFFICWAY_TYPE | Categórica | Tipo de vía |
| LANE_CNT | Numérico | Número de carriles |
| ALIGNMENT | Categórica | Recta, curva… |
| ROADWAY_SURFACE_COND | Categórica | Superficie (seca, mojada…) |
| ROAD_DEFECT | Categórica | Bache, irregularidad… |
| REPORT_TYPE | Categórica | Tipo de reporte |
| CRASH_TYPE | Categórica | Clasificación general |
| INTERSECTION_RELATED_I | Categórica (Y/N) | Relación con intersección |
| NOT_RIGHT_OF_WAY_I | Categórica (Y/N) | No ceder el paso |
| HIT_AND_RUN_I | Categórica (Y/N) | Fuga |
| DAMAGE | Categórica | Nivel de daños |
| DATE_POLICE_NOTIFIED | Fecha-hora | Aviso a policía |
| PRIM_CONTRIBUTORY_CAUSE | Categórica | Causa primaria |
| SEC_CONTRIBUTORY_CAUSE | Categórica | Causa secundaria |
| STREET_NO / DIRECTION / NAME | Texto / Numérico | Dirección |
| BEAT_OF_OCCURRENCE | Numérico | Beat/cuadrante policial |
| PHOTOS_TAKEN_I / STATEMENTS_TAKEN_I | Categórica (Y/N) | Evidencias |
| DOORING_I | Categórica (Y/N) | Dooring a ciclista |
| WORK_ZONE_I / TYPE / WORKERS_PRESENT_I | Categórica | Zona de obra |
| NUM_UNITS | Numérico | Unidades/vehículos |
| MOST_SEVERE_INJURY | Categórica | Lesión más severa |
| INJURIES_TOTAL / *_FATAL / … | Numérico | Lesiones (desagregadas) |
| CRASH_HOUR / DAY_OF_WEEK / MONTH | Numérico | Hora, día, mes |
| LATITUDE / LONGITUDE / LOCATION | Numérico / Texto | Coordenadas / punto |

</details>

---

## Tipos de atributos
- **Numéricos:** `POSTED_SPEED_LIMIT`, `LANE_CNT`, `STREET_NO`, `BEAT_OF_OCCURRENCE`, `NUM_UNITS`, `INJURIES_*`, `CRASH_HOUR`, `CRASH_DAY_OF_WEEK`, `CRASH_MONTH`, `LATITUDE`, `LONGITUDE`.
- **Categóricos (incluye banderas Y/N):** `TRAFFIC_CONTROL_DEVICE`, `DEVICE_CONDITION`, `WEATHER_CONDITION`, `LIGHTING_CONDITION`, `FIRST_CRASH_TYPE`, `TRAFFICWAY_TYPE`, `ALIGNMENT`, `ROADWAY_SURFACE_COND`, `ROAD_DEFECT`, `REPORT_TYPE`, `CRASH_TYPE`, `INTERSECTION_RELATED_I`, `NOT_RIGHT_OF_WAY_I`, `HIT_AND_RUN_I`, `DAMAGE`, `PHOTOS_TAKEN_I`, `STATEMENTS_TAKEN_I`, `DOORING_I`, `WORK_ZONE_I`, `WORK_ZONE_TYPE`, `WORKERS_PRESENT_I`, `MOST_SEVERE_INJURY`, `STREET_DIRECTION`, `PRIM_CONTRIBUTORY_CAUSE`, `SEC_CONTRIBUTORY_CAUSE`, `CRASH_DATE_EST_I`.
- **Texto/ID:** `CRASH_RECORD_ID`, `STREET_NAME`, `LOCATION`.
- **Temporales:** `CRASH_DATE`, `DATE_POLICE_NOTIFIED`.

---
## Ética y uso responsable
> [!WARNING]
> Evitar re-identificación: publicar resultados **agregados** por zona/periodo.  
> Documentar **faltantes**, posibles **sesgos** y **enmiendas** de reportes.  
> No estigmatizar colonias; controlar por **exposición al tráfico** e **infraestructura**.

---
## Scripts de carga y análisis de datos
Iniciamos el script `carga.sql` para la base de datos `traffic_accident_chicago` y la tabla principal donde se cargan los datos de origen del archivo CSV. A continuación, el script `analisis.sql` realiza, mediante una consulta SQL, un análisis general del conjunto de datos del informe. Este análisis considera los siguientes aspectos:

- La existencia de columnas con objetos iguales
- Los valores mínimos tienen el área máxima del valor numérico
- Los promedios de las variables cuantitativas
- La presencia de detecciones duplicadas con inconsistencias
- El recuento de valores tiene un registro nulo para una categoría

Este procedimiento opera sobre los posibles errores, valores atípicos y patrones generales en los datos, lo cual constituye un paso preliminar en el proceso de normalización con análisis detallado.



erDiagram
  CRASH ||--|| CRASH_LOCATION : has
  CRASH ||--|| CRASH_INJURY_SUMMARY : has
  CRASH ||--o{ CRASH_CONTRIBUTORY_CAUSE : has

  CRASH {
    int crash_id PK
    varchar crash_record_id UNIQUE
    boolean crash_date_est
    timestamp crash_date
    int posted_speed_limit
    text traffic_control_device
    text device_condition
    text weather_condition
    text lighting_condition
    text first_crash_type
    text trafficway_type
    int lane_cnt
    text alignment
    text roadway_surface_cond
    text road_defect
    text report_type
    text crash_type
    boolean intersection_related
    boolean not_right_of_way
    boolean hit_and_run
    text damage
    timestamp date_police_notified
    boolean photos_taken
    boolean statements_taken
    boolean dooring
    boolean work_zone
    text work_zone_type
    boolean workers_present
    int num_units
    int crash_hour
    int crash_day_of_week
    int crash_month
  }

  CRASH_LOCATION {
    int location_id PK
    int crash_id FK UNIQUE
    int street_no
    text street_direction
    text street_name
    int beat_of_occurrence
    numeric latitude
    numeric longitude
    text location
  }

  CRASH_INJURY_SUMMARY {
    int injury_id PK
    int crash_id FK UNIQUE
    text most_severe_injury
    int injuries_total
    int injuries_fatal
    int injuries_incapacitating
    int injuries_non_incapacitating
    int injuries_reported_not_evident
    int injuries_no_indication
    int injuries_unknown
  }

  CRASH_CONTRIBUTORY_CAUSE {
    int crash_cause_id PK
    int crash_id FK
    text cause_role
    text contributory_cause
    UNIQUE crash_id_cause_role
  }
