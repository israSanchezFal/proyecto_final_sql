-- Script: analisis.sql
-- Proyecto: Análisis de accidentes de tráfico en Chicago
-- Fecha: Noviembre 2025

-- Conteo total de registros y columnas
SELECT COUNT(*) AS total_filas FROM crashes_clean;

SELECT COUNT(column_name) AS total_columnas
FROM information_schema.columns
WHERE table_name = 'crashes_clean';

-- Columnas con valores únicos
SELECT 'crash_record_id' AS columna,
       COUNT(DISTINCT crash_record_id) AS valores_unicos,
       COUNT(*) AS total_filas
FROM crashes_clean;

-- Mínimos y máximos de fechas
SELECT MIN(crash_date) AS fecha_mas_antigua,
       MAX(crash_date) AS fecha_mas_reciente
FROM crashes_clean;

-- Mínimos, máximos y promedios de valores numéricos
SELECT MIN(posted_speed_limit) AS min_velocidad,
       MAX(posted_speed_limit) AS max_velocidad,
       ROUND(AVG(posted_speed_limit), 2) AS promedio_velocidad
FROM crashes_clean
WHERE posted_speed_limit IS NOT NULL;

SELECT MIN(injuries_total) AS min_heridos,
       MAX(injuries_total) AS max_heridos,
       ROUND(AVG(injuries_total), 2) AS promedio_heridos
FROM crashes_clean
WHERE injuries_total IS NOT NULL;

-- Columnas potencialmente redundantes
SELECT 'work_zone_i' AS columna,
       COUNT(DISTINCT work_zone_i) AS valores_unicos,
       COUNT(*) AS total_filas
FROM crashes_clean;

SELECT 'workers_present_i' AS columna,
       COUNT(DISTINCT workers_present_i) AS valores_unicos,
       COUNT(*) AS total_filas
FROM crashes_clean;

-- Conteo de valores nulos por columna
SELECT COUNT(*) FILTER (WHERE crash_date IS NULL) AS fecha_nula,
       COUNT(*) FILTER (WHERE posted_speed_limit IS NULL) AS velocidad_nula,
       COUNT(*) FILTER (WHERE num_units IS NULL) AS unidades_nulas,
       COUNT(*) FILTER (WHERE injuries_total IS NULL) AS heridos_nulos,
       COUNT(*) FILTER (WHERE latitude IS NULL) AS latitud_nula,
       COUNT(*) FILTER (WHERE longitude IS NULL) AS longitud_nula
FROM crashes_clean;

-- Inconsistencias en el set de datos
SELECT *
FROM crashes_clean
WHERE (num_units = 0 AND injuries_total > 0)
   OR (posted_speed_limit <= 0)
   OR (crash_hour < 0 OR crash_hour > 23)
   OR (crash_day_of_week < 1 OR crash_day_of_week > 7)
LIMIT 20;

-- Resumen general por mes y día de la semana
SELECT crash_month, COUNT(*) AS accidentes
FROM crashes_clean
GROUP BY crash_month
ORDER BY crash_month;

SELECT crash_day_of_week, COUNT(*) AS accidentes
FROM crashes_clean
GROUP BY crash_day_of_week
ORDER BY crash_day_of_week;


