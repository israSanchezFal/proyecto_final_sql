-- Script: carga.sql
-- Proyecto: Análisis de accidentes de tráfico en Chicago
-- Fecha: Noviembre 2025
-- HECHO TODO DESDE LA TERMINAL DE MAC

-- 1. Crear la base de datos
CREATE DATABASE traffic_crashes_chicago;

-- 2. Conectarse a la base recién creada
\c traffic_crashes_chicago;

-- 3. Crear tabla base con todas las columnas (48 en total)
CREATE TABLE crashes_raw (
    crash_record_id VARCHAR(100),
    crash_date_est_i VARCHAR(10),
    crash_date TIMESTAMP,
    posted_speed_limit INTEGER,
    traffic_control_device VARCHAR(100),
    device_condition VARCHAR(100),
    weather_condition VARCHAR(100),
    lighting_condition VARCHAR(100),
    first_crash_type VARCHAR(100),
    trafficway_type VARCHAR(100),
    lane_cnt INTEGER,
    alignment VARCHAR(100),
    roadway_surface_cond VARCHAR(100),
    road_defect VARCHAR(100),
    report_type VARCHAR(100),
    crash_type VARCHAR(150),
    intersection_related_i VARCHAR(5),
    not_right_of_way_i VARCHAR(5),
    hit_and_run_i VARCHAR(5),
    damage VARCHAR(100),
    date_police_notified TIMESTAMP,
    prim_contributory_cause VARCHAR(200),
    sec_contributory_cause VARCHAR(200),
    street_no INTEGER,
    street_direction VARCHAR(10),
    street_name VARCHAR(100),
    beat_of_occurrence VARCHAR(20),
    photos_taken_i VARCHAR(5),
    statements_taken_i VARCHAR(5),
    dooring_i VARCHAR(5),
    work_zone_i VARCHAR(5),
    work_zone_type VARCHAR(100),
    workers_present_i VARCHAR(5),
    num_units INTEGER,
    most_severe_injury VARCHAR(100),
    injuries_total INTEGER,
    injuries_fatal INTEGER,
    injuries_incapacitating INTEGER,
    injuries_non_incapacitating INTEGER,
    injuries_reported_not_evident INTEGER,
    injuries_no_indication INTEGER,
    injuries_unknown INTEGER,
    crash_hour INTEGER,
    crash_day_of_week INTEGER,
    crash_month INTEGER,
    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),
    location VARCHAR(100)
);

-- 4. Cargar los datos desde el CSV (ajustar la ruta según tu carpeta)
\copy crashes_raw FROM '/Users/parisschool/Downloads/Traffic_Crashes_-_Crashes_20251104.csv' DELIMITER ',' CSV HEADER;

-- 5. Verificar que la carga fue exitosa
SELECT COUNT(*) FROM crashes_raw;
SELECT * FROM crashes_raw LIMIT 10;

