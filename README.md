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
```console
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT crash_record_id) AS distinct_id
FROM traffic_crashes;
```
2. Conteo de nulos
```console
SELECT COUNT(*) FILTER (WHERE crash_date IS NULL) AS null_crash_date,
       COUNT(*) FILTER (WHERE posted_speed_limit IS NULL) AS null_speed_limit,
       COUNT(*) FILTER (WHERE weather_condition IS NULL) AS null_weather,
       COUNT(*) FILTER (WHERE lighting_condition IS NULL) AS null_lighting,
       COUNT(*) FILTER (WHERE first_crash_type IS NULL) AS null_first_crash_type
FROM traffic_crashes; 
```
3. Conteo por tipo de choque
```console
SELECT crash_type, COUNT(*) 
FROM traffic_crashes
GROUP BY crash_type
ORDER BY COUNT(*) DESC;
```

## 💸 Análisis de Impacto Económico: El Costo Invisible del Clima

### 🎯 Objetivo del Análisis
Identificar qué combinaciones de **clima e iluminación** generan los accidentes más costosos. A diferencia de la frecuencia (dónde ocurren más choques), este análisis se centra en la **severidad económica**, permitiendo a las aseguradoras y organismos públicos prever reservas de capital para condiciones específicas.

### 🧠 Metodología y Lógica SQL
Dado que el costo exacto es una variable discreta por rangos, creamos un **Atributo Enriquecido** llamado `costo_promedio_estimado`.
* **Transformación:** Convertimos las categorías de texto (`OVER $1,500`) a valores numéricos ponderados mediante una expresión `CASE`.
* **Ranking:** Utilizamos la función de ventana `DENSE_RANK()` para clasificar las condiciones de mayor a menor impacto financiero, sin saltos en la numeración.

### 📊 Top Hallazgos: Condiciones de Mayor Riesgo Financiero

La siguiente tabla destaca las combinaciones de clima e iluminación que generan los costos estimados más altos por accidente. Se han seleccionado tanto eventos raros de pérdida total como eventos frecuentes de alto costo.

| Ranking 🏆 | Condición Climática 🌧️ | Iluminación 💡 | Frecuencia (n) 📉 | Costo Promedio Est. 💰 |
| :---: | :--- | :--- | :---: | :---: |
| **#1** | **BLOWING SAND, SOIL** | DARKNESS, LIGHTED ROAD | 2 | **$1,500.00** |
| **#1** | **BLOWING SAND, SOIL** | DARKNESS | 3 | **$1,500.00** |
| **#2** | FOG/SMOKE/HAZE | UNKNOWN | 12 | $1,416.67 |
| **#3** | FOG/SMOKE/HAZE | DAWN | 69 | $1,351.45 |
| **#5** | **FREEZING RAIN/DRIZZLE** | DARKNESS, LIGHTED ROAD | **977** | $1,344.16 |
| **#6** | BLOWING SNOW | DUSK | 22 | $1,284.09 |
| **#13** | SLEET/HAIL | DARKNESS, LIGHTED ROAD | 416 | $1,298.67 |

> **Interpretación:**
> * **Ranking #1:** Representa pérdida total del vehículo casi garantizada, aunque son eventos poco frecuentes.
> * **Ranking #5:** *Freezing Rain* en oscuridad es el **riesgo sistémico más alto**, combinando un costo muy elevado ($1,344) con una frecuencia masiva (casi 1,000 eventos).


```console
-- Consulta: Ranking de Severidad Económica (Top 15)
SELECT 
    c.weather_condition,
    c.lighting_condition,
    COUNT(c.crash_id) AS cantidad_accidentes,
    AVG(CASE 
        WHEN c.damage = 'OVER $1,500' THEN 1500
        WHEN c.damage = '$501 - $1,500' THEN 1000
        WHEN c.damage = '$500 OR LESS' THEN 250
        ELSE 0 
    END) AS costo_promedio_estimado,
    DENSE_RANK() OVER (
        ORDER BY AVG(CASE 
            WHEN c.damage = 'OVER $1,500' THEN 1500
            ELSE 0 
        END) DESC
    ) AS ranking_severidad
FROM 
    public.crash c
WHERE 
    c.weather_condition != 'UNKNOWN'
GROUP BY 
    c.weather_condition, c.lighting_condition
ORDER BY 
    ranking_severidad ASC
LIMIT 15;
```


