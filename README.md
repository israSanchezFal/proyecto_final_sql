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
## Carga y análisis de datos

Para comenzar, se deben ejecutar los siguientes comandos en la terminal (psql) para crear la base de datos de destino:

1. Conectarse con el usuario desde la terminal 
```console
psql -U usuario
```
2. Crear la Bsse de Datos
```console
CREATE DATABASE proyecto_final_db;
```
3. Conectarse a la base de datos para ver que todo está correcto 
```console
\c proyecto_final_db;
```

Conecta tu base de datos en TablePlus, ya que ahí fue donde se realizaron todas las operaciones siguientes. El procedimiento es intuitivo, solo debes de llenar los espacios que estén vacíos después de escojer la opción "Creat Connection". En nuestro caso escogimos el nombre de proyecto_final_db, si se le es más fácil, escoja el mismo nombre.

Una vez dentro, abre un archivo sql vacío para poder crear la tabla. La mayoría de las columnas como TEXT para garantizar la carga segura de datos sucios o atípicos sin que se produzcan errores de casting durante la importación.

```console
CREATE TABLE traffic_crashes(
    CRASH_RECORD_ID TEXT,
    CRASH_DATE_EST_I TEXT,
    CRASH_DATE TIMESTAMP,    
    POSTED_SPEED_LIMIT TEXT,  
    TRAFFIC_CONTROL_DEVICE TEXT,
    DEVICE_CONDITION TEXT,
    WEATHER_CONDITION TEXT,
    LIGHTING_CONDITION TEXT,
    FIRST_CRASH_TYPE TEXT,
    TRAFFICWAY_TYPE TEXT,
    LANE_CNT TEXT,
    ALIGNMENT TEXT,
    ROADWAY_SURFACE_COND TEXT,
    ROAD_DEFECT TEXT,
    REPORT_TYPE TEXT,
    CRASH_TYPE TEXT,
    INTERSECTION_RELATED_I TEXT,
    NOT_RIGHT_OF_WAY_I TEXT,
    HIT_AND_RUN_I TEXT,
    DAMAGE TEXT,
    DATE_POLICE_NOTIFIED TIMESTAMP,
    PRIM_CONTRIBUTORY_CAUSE TEXT,
    SEC_CONTRIBUTORY_CAUSE TEXT,
    STREET_NO TEXT,
    STREET_DIRECTION TEXT,
    STREET_NAME TEXT,
    BEAT_OF_OCCURRENCE TEXT,
    PHOTOS_TAKEN_I TEXT,
    STATEMENTS_TAKEN_I TEXT,
    DOORING_I TEXT,
    WORK_ZONE_I TEXT,
    WORK_ZONE_TYPE TEXT,
    WORKERS_PRESENT_I TEXT,
    NUM_UNITS TEXT,          
    MOST_SEVERE_INJURY TEXT,
    INJURIES_TOTAL TEXT,
    INJURIES_FATAL TEXT,
    INJURIES_INCAPACITATING TEXT,
    INJURIES_NON_INCAPACITATING TEXT,
    INJURIES_REPORTED_NOT_EVIDENT TEXT,
    INJURIES_NO_INDICATION TEXT,
    INJURIES_UNKNOWN TEXT,
    CRASH_HOUR BIGINT,
    CRASH_DAY_OF_WEEK BIGINT,
    CRASH_MONTH BIGINT,
    LATITUDE NUMERIC,
    LONGITUDE NUMERIC,
    LOCATION TEXT
);
```
Una vez creada la tabla, realiza un “Refresh workspace” para poder visualizarla; luego, selecciónala y desde Archivo → Importar carga el dataset de Traffic Crashes de Chicago, puedes descargarlo aquí: 

https://data.cityofchicago.org/Transportation/Traffic-Crashes-Crashes/85ca-t3if/about_data

En la ventana de importación, elige importar dentro de traffic_crashes y, para asegurar el mapeo correcto, selecciona “Match Columns by Name – Case Insensitive” y después “Import”. 

Para confirmar que la carga quedó bien, se realizará un análisis preliminar enfocado en la estructura y consistencia general de la tabla más que en la interpretación de los datos.

1. Verificación de Integridad considerando y confirmando CRASH_RECORD_ID como clave.
```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT crash_record_id) AS distinct_id
FROM traffic_crashes;
```
2. Conteo de nulos
```sql
SELECT COUNT(*) FILTER (WHERE crash_date IS NULL) AS null_crash_date,
       COUNT(*) FILTER (WHERE posted_speed_limit IS NULL) AS null_speed_limit,
       COUNT(*) FILTER (WHERE weather_condition IS NULL) AS null_weather,
       COUNT(*) FILTER (WHERE lighting_condition IS NULL) AS null_lighting,
       COUNT(*) FILTER (WHERE first_crash_type IS NULL) AS null_first_crash_type
FROM traffic_crashes; 
```
3. Conteo por tipo de choque
```sql
SELECT crash_type, COUNT(*) 
FROM traffic_crashes
GROUP BY crash_type
ORDER BY COUNT(*) DESC;
```
# Limpieza de datos

Para el desarrollo del proyecto se creó una tabla intermedia llamada `traffic_crashes_clean` con el objetivo de limpiar, normalizar y tipificar los datos provenientes de la tabla original `traffic_crashes`, sin modificar la fuente original.

La limpieza se diseñó como un proceso sencillo basado en cinco operaciones principales, aplicadas a distintas columnas del conjunto de datos.



## 1. Normalización de valores vacíos (`TRIM` + `NULLIF`)

Muchos campos de texto contenían cadenas vacías (`''`) o únicamente espacios.  
Estos valores se normalizaron a `NULL` para evitar inconsistencias semánticas y facilitar el análisis posterior.

### Ejemplo
```sql
NULLIF(TRIM(weather_condition), '') AS weather_condition
```

## 2. Conversión de indicadores `Y` / `N` a valores booleanos

Varias columnas utilizaban indicadores tipo `Y` / `N` (o valores vacíos).
Estos valores se transformaron a tipo BOOLEAN (`TRUE`, `FALSE`, `NULL`) para mejorar la consistencia y el modelado de datos.

### Ejemplo
```sql
CASE
  WHEN NULLIF(TRIM(hit_and_run_i), '') = 'Y' THEN TRUE
  WHEN NULLIF(TRIM(hit_and_run_i), '') = 'N' THEN FALSE
  ELSE NULL
END AS hit_and_run
```

## 3. Validación y conversión segura de valores numéricos

Algunas columnas numéricas venían almacenadas como texto y podían contener valores no válidos.
Antes de convertirlas a tipo INT, se validó que el contenido incluyera únicamente dígitos.

### Ejemplo
```sql
CASE
  WHEN NULLIF(TRIM(posted_speed_limit), '') ~ '^[0-9]+$'
  THEN TRIM(posted_speed_limit)::INT
  ELSE NULL
END AS posted_speed_limit
```

## 4. Validación de rangos lógicos

Para variables temporales se verificó que los valores se encontraran dentro de rangos razonables.
Los valores fuera de rango se transformaron a `NULL`.

### Ejemplo
```sql
CASE
  WHEN crash_hour BETWEEN 0 AND 23
  THEN crash_hour::INT
  ELSE NULL
END AS crash_hour
```

## 5. Limpieza de valores inválidos o no informativos

Se identificaron valores que, aunque no eran técnicamente nulos, no aportaban información útil para el análisis y se normalizaron a `NULL`.

### Ejemplos
#### Coordenadas
```sql
CASE
  WHEN latitude = 0 OR latitude IS NULL THEN NULL
  ELSE latitude
END AS latitude
```
#### Categorías
```sql
UPDATE traffic_crashes_clean
SET weather_condition = NULL
WHERE weather_condition IN ('UNKNOWN', 'NOT APPLICABLE');
```
