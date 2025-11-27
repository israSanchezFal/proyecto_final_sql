-- Script: carga.sql
-- Proyecto: Análisis de accidentes de tráfico en Chicago
-- Fecha: Noviembre 2025

--Abrir la terminal y conectarte a postgres
sql -U- usuario

-- Crear la base de datos desde la terminal
CREATE DATABASE proyecto_final_db;

-- Conectarse a la base recién creada solo para verificar
\c proyecto_final_db;

-- Una vez creada, entrar a TablePlus y crear la tabla 
-- (como está demasiado sucia empezaremos generalizando casi todo como TEXT)
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

-- Una vez creada, haz un "refresh workspace" para poder visualizar la tabla
-- Sitúate en ella y desde "Archivo" importa el documento que puedes descargar aqui:
https://data.cityofchicago.org/Transportation/Traffic-Crashes-Crashes/85ca-t3if/about_data

-- En la ventana que abre para importar, selecciona que quieres importar en traffic_crashes
-- Finalmente selecciona "Match Columns by Name - Case Insensitive" e "Import"
    

-- Para concretar la carga, vamos a hacer un análisis preliminar, más de la tabla que de los datos como tal

-- Total de Filas
SELECT COUNT(*) AS total_rows
FROM traffic_crashes;

-- Rango entre el choque más antiguo y el más actual
SELECT 
    MIN(crash_date) AS earliest_crash,
    MAX(crash_date) AS latest_crash
FROM traffic_crashes;

-- Al tener por el momento valores numéricos reducidos, un resumen de ellos es:
SELECT
    MIN(crash_hour) AS min_hour,
    MAX(crash_hour) AS max_hour,
    AVG(crash_hour) AS avg_hour,

    MIN(crash_day_of_week) AS min_day,
    MAX(crash_day_of_week) AS max_day,
    AVG(crash_day_of_week) AS avg_day,

    MIN(crash_month) AS min_month,
    MAX(crash_month) AS max_month,
    AVG(crash_month) AS avg_month
FROM traffic_crashes;

-- Para buscar columnas con valores únicos, analizando el db podemos ver que si total_rows = distinct_id, entonces el ID es único y confiable.
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT crash_record_id) AS distinct_id
FROM traffic_crashes;

-- Conteo de nulos por columnas importantes
SELECT COUNT(*) FILTER (WHERE crash_date IS NULL) AS null_crash_date,
       COUNT(*) FILTER (WHERE posted_speed_limit IS NULL) AS null_speed_limit,
       COUNT(*) FILTER (WHERE weather_condition IS NULL) AS null_weather,
       COUNT(*) FILTER (WHERE lighting_condition IS NULL) AS null_lighting,
       COUNT(*) FILTER (WHERE first_crash_type IS NULL) AS null_first_crash_type
FROM traffic_crashes; 

-- Para finalizar, un conteo por tipo de choque
SELECT crash_type, COUNT(*) 
FROM traffic_crashes
GROUP BY crash_type
ORDER BY COUNT(*) DESC;

