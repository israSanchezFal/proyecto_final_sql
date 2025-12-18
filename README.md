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

```sql
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
    ...
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
---
## Limpieza de datos

Para el desarrollo del proyecto se creó una tabla intermedia llamada `traffic_crashes_clean` con el objetivo de limpiar, normalizar y tipificar los datos provenientes de la tabla original `traffic_crashes`, sin modificar la fuente original.

La limpieza se diseñó como un proceso sencillo basado en cinco operaciones principales, aplicadas a distintas columnas del conjunto de datos.

Lo primero que se realizó fue la creación de una nueva tabla:
```sql
DROP TABLE IF EXISTS traffic_crashes_clean;

CREATE TABLE traffic_crashes_clean (
crash_record_id VARCHAR,
crash_date_est BOOLEAN,
crash_date TIMESTAMP,
posted_speed_limit INT,
traffic_control_device TEXT,
device_condition TEXT,
weather_condition TEXT,
lighting_condition TEXT,
first_crash_type TEXT,
...
```
Para posteriormente realizar las operaciones pertinentes.

### 1. Normalización de valores vacíos (`TRIM` + `NULLIF`)

Muchos campos de texto contenían cadenas vacías (`''`) o únicamente espacios.  
Estos valores se normalizaron a `NULL` para evitar inconsistencias semánticas y facilitar el análisis posterior.

#### Ejemplo
```sql
NULLIF(TRIM(weather_condition), '') AS weather_condition
```

### 2. Conversión de indicadores `Y` / `N` a valores booleanos

Varias columnas utilizaban indicadores tipo `Y` / `N` (o valores vacíos).
Estos valores se transformaron a tipo BOOLEAN (`TRUE`, `FALSE`, `NULL`) para mejorar la consistencia y el modelado de datos.

#### Ejemplo
```sql
CASE
  WHEN NULLIF(TRIM(hit_and_run_i), '') = 'Y' THEN TRUE
  WHEN NULLIF(TRIM(hit_and_run_i), '') = 'N' THEN FALSE
  ELSE NULL
END AS hit_and_run
```

### 3. Validación y conversión segura de valores numéricos

Algunas columnas numéricas venían almacenadas como texto y podían contener valores no válidos.
Antes de convertirlas a tipo INT, se validó que el contenido incluyera únicamente dígitos.

#### Ejemplo
```sql
CASE
  WHEN NULLIF(TRIM(posted_speed_limit), '') ~ '^[0-9]+$'
  THEN TRIM(posted_speed_limit)::INT
  ELSE NULL
END AS posted_speed_limit
```

### 4. Validación de rangos lógicos

Para variables temporales se verificó que los valores se encontraran dentro de rangos razonables.
Los valores fuera de rango se transformaron a `NULL`.

#### Ejemplo
```sql
CASE
  WHEN crash_hour BETWEEN 0 AND 23
  THEN crash_hour::INT
  ELSE NULL
END AS crash_hour
```

### 5. Limpieza de valores inválidos o no informativos

Se identificaron valores que, aunque no eran técnicamente nulos, no aportaban información útil para el análisis y se normalizaron a `NULL`.

#### Ejemplos
##### Coordenadas
```sql
CASE
  WHEN latitude = 0 OR latitude IS NULL THEN NULL
  ELSE latitude
END AS latitude
```
##### Categorías
```sql
UPDATE traffic_crashes_clean
SET weather_condition = NULL
WHERE weather_condition IN ('UNKNOWN', 'NOT APPLICABLE');
```

Para poder completar la limipeza basta con descargar el archivo sql.

---
## Normalización de Datos hasta Cuarta Forma Normal (4FN)

A partir de la tabla `traffic_crashes_clean`, previamente limpiada y tipificada, se realizó un proceso de **normalización hasta Cuarta Forma Normal (4FN)** con el objetivo de eliminar redundancias, evitar anomalías de actualización y garantizar la consistencia de los datos.

El proceso se desarrolló en cinco etapas: diseño intuitivo, identificación de dependencias, descomposición progresiva, diseño final en 4FN e implementación mediante scripts SQL.


### 1. Diseño intuitivo inicial

El conjunto de datos describe **accidentes de tránsito**, donde cada registro contiene información heterogénea correspondiente a:

- El accidente en sí
- Su ubicación
- El resumen de lesiones
- Las causas contribuyentes (primaria y secundaria)

Intuitivamente, estos conceptos representan **entidades distintas**, aunque en la tabla original aparecían combinados en una sola relación.


### 2. Identificación de dependencias funcionales

A partir del análisis del dataset, se identificaron las siguientes **dependencias funcionales no triviales**:

#### Dependencias funcionales principales

- `crash_record_id → (todos los atributos del accidente)`
- `crash_id → información del accidente`
- `crash_id → información de ubicación`
- `crash_id → resumen de lesiones`
- `cause_id → cause_text`

Estas dependencias indican que la mayoría de los atributos dependen **únicamente del identificador del accidente**, mientras que el texto de la causa depende exclusivamente de la causa en sí.


### 3. Identificación de dependencias multivaluadas

Se identificó una **dependencia multivaluada no trivial** en las causas contribuyentes:

- Un accidente puede tener **más de una causa** (primaria y secundaria).
- Las causas no dependen entre sí, sino de forma independiente del accidente.

Formalmente:
`cause_id →→ cause_text`

Esto viola la Cuarta Forma Normal si se mantiene en una sola tabla, por lo que requiere una descomposición adicional.

---

### 4. Proceso de normalización y descomposición

#### - Entidad `crash` (3FN)

Se creó la entidad principal `crash`, que contiene únicamente atributos que dependen **directamente del accidente**.

- Llave primaria artificial: `crash_id`
- Llave candidata natural: `crash_record_id`

Esto elimina redundancia y garantiza unicidad.


#### - Entidad `crash_location` (1:1)

La información de ubicación depende completamente del accidente, pero conceptualmente representa otra entidad.

- Relación 1 a 1 con `crash`
- Llave primaria y foránea: `crash_id`

Esto evita repetir información espacial y mantiene cohesión semántica.


#### - Entidad `crash_injury_summary` (1:1)

El resumen de lesiones es independiente del resto de los atributos del accidente y se separa en su propia entidad.

- Relación 1 a 1 con `crash`
- Llave primaria y foránea: `crash_id`

Esta descomposición facilita validaciones y análisis específicos de lesiones.

#### - Entidad `cat_contributory_cause`

Las causas contribuyentes se normalizaron en un catálogo, eliminando la repetición del texto de la causa.

- Llave primaria artificial: `cause_id`
- Restricción `UNIQUE` sobre `cause_text`

Esto reduce redundancia y mejora consistencia.

#### - Entidad `crash_cause` (resolución de dependencia multivaluada)

Para resolver la dependencia multivaluada de las causas, se creó una tabla pivote:

- Relación N:M entre `crash` y `cat_contributory_cause`
- Se distingue el rol de la causa (`PRIMARY`, `SECONDARY`)
- Llave primaria compuesta: `(crash_id, cause_role)`

Esto garantiza:
- Máximo una causa primaria y una secundaria por accidente
- Eliminación completa de la dependencia multivaluada

Con esta descomposición, el diseño alcanza Cuarta Forma Normal (4FN).

## 5. Diseño final en Cuarta Forma Normal

El modelo final queda compuesto por las siguientes entidades:

- `crash`
- `crash_location`
- `crash_injury_summary`
- `cat_contributory_cause`
- `crash_cause`

Cada entidad:
- Tiene una llave primaria artificial
- No contiene dependencias funcionales parciales o transitivas
- No presenta dependencias multivaluadas no triviales


## 7. Implementación y carga de datos

La descomposición se implementó mediante scripts SQL que:

- Insertan datos desde `traffic_crashes_clean`
- Evitan duplicados mediante `DISTINCT ON`
- Mantienen integridad referencial con llaves foráneas
- Utilizan transacciones para asegurar atomicidad
- Evitan la generación de tuplas idénticas

El proceso garantiza que los datos limpios se proyectan correctamente en el esquema normalizado.


## Conclusión

El diseño resultante cumple con los principios de la Cuarta Forma Normal, eliminando redundancia, evitando anomalías de actualización y proporcionando una base sólida para análisis posteriores y expansión del modelo.

La normalización se realizó de forma intuitiva, justificada y consistente con la estructura real de los datos.



