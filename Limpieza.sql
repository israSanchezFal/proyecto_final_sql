-- Vamos a limpiar la base de datos, buscando no cambiar la orignial, vamos a crear una base de datos nueva ya analizada y con el tipo de datos que queremos que tengan las columnas.

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
  trafficway_type TEXT,
  lane_cnt INT,
  alignment TEXT,
  roadway_surface_cond TEXT,
  road_defect TEXT,
  report_type TEXT,
  crash_type TEXT,
  intersection_related BOOLEAN,
  not_right_of_way BOOLEAN,
  hit_and_run BOOLEAN,
  damage TEXT,
  date_police_notified TIMESTAMP,
  prim_contributory_cause TEXT,
  sec_contributory_cause TEXT,
  street_no INT,
  street_direction TEXT,
  street_name TEXT,
  beat_of_occurrence INT,
  photos_taken BOOLEAN,
  statements_taken BOOLEAN,
  dooring BOOLEAN,
  work_zone BOOLEAN,
  work_zone_type TEXT,
  workers_present BOOLEAN,
  num_units INT,
  most_severe_injury TEXT,
  injuries_total INT,
  injuries_fatal INT,
  injuries_incapacitating INT,
  injuries_non_incapacitating INT,
  injuries_reported_not_evident INT,
  injuries_no_indication INT,
  injuries_unknown INT,
  crash_hour INT,
  crash_day_of_week INT,
  crash_month INT,
  latitude NUMERIC,
  longitude NUMERIC,
  location TEXT
);

INSERT INTO traffic_crashes_clean
SELECT
	-- TRIM quita espacios antes y después de la cadena, NULLIF convierte '' a NULL
  	NULLIF(TRIM(crash_record_id), '')::VARCHAR,

  	-- crash_date_est_i es un indicador tipo 'Y'/'N'/vacío, Primero revisamos vacío usando el NULLIF y TRIM
	-- luego hacemos: 'Y' = TRUE, 'N' = FALSE y NULL/espacio = NULL
  	CASE
    	WHEN NULLIF(TRIM(crash_date_est_i), '') = 'Y' THEN TRUE
    	WHEN NULLIF(TRIM(crash_date_est_i), '') = 'N' THEN FALSE
    	ELSE NULL
  	END AS crash_date_est,
	
	-- Se queda como TIMESTAMP
  	crash_date,

	-- posted_speed_limit es un campo tipo INT/NULL: Se usa NULLIF y TRIM para normalizar cadenas vacías, luego se 		checa que solo contenga dígitos. Si cumple, es un INT y si no, es NULL.
	CASE
    	WHEN NULLIF(TRIM(posted_speed_limit), '') ~ '^[0-9]+$'
    	THEN TRIM(posted_speed_limit)::INT
    	ELSE NULL
  	END AS posted_speed_limit,
  	
  	-- usando el NULLIF y TRIM revisamos y corregimos los vacíos a NULL
	NULLIF(TRIM(traffic_control_device), '') AS traffic_control_device,
  	NULLIF(TRIM(device_condition), '') AS device_condition,
  	NULLIF(TRIM(weather_condition), '') AS weather_condition,
  	NULLIF(TRIM(lighting_condition), '') AS lighting_condition,
  	NULLIF(TRIM(first_crash_type), '') AS first_crash_type,
  	NULLIF(TRIM(trafficway_type), '') AS trafficway_type,

	-- Misma lógica que en posted_speed_limit
	CASE
    	WHEN NULLIF(TRIM(lane_cnt), '') ~ '^[0-9]+$'
    	THEN TRIM(lane_cnt)::INT
    	ELSE NULL
  	END AS lane_cnt,
  	
  	-- usando el NULLIF y TRIM revisamos y corregimos los vacíos a NULL
  	NULLIF(TRIM(alignment), '') AS alignment,
  	NULLIF(TRIM(roadway_surface_cond), '') AS roadway_surface_cond,
  	NULLIF(TRIM(road_defect), '') AS road_defect,
  	NULLIF(TRIM(report_type), '') AS report_type,
  	NULLIF(TRIM(crash_type), '') AS crash_type,
  	
  	--Misma lógica que crash_date_est_i
  	CASE
    	WHEN NULLIF(TRIM(intersection_related_i), '') = 'Y' THEN TRUE
    	WHEN NULLIF(TRIM(intersection_related_i), '') = 'N' THEN FALSE
    	ELSE NULL
  	END AS intersection_related,
  	
  	CASE
    	WHEN NULLIF(TRIM(not_right_of_way_i), '') = 'Y' THEN TRUE
    	WHEN NULLIF(TRIM(not_right_of_way_i), '') = 'N' THEN FALSE
    	ELSE NULL
  	END AS not_right_of_way,

  	CASE
    	WHEN NULLIF(TRIM(hit_and_run_i), '') = 'Y' THEN TRUE
    	WHEN NULLIF(TRIM(hit_and_run_i), '') = 'N' THEN FALSE
    	ELSE NULL
  	END AS hit_and_run,
  	
  	NULLIF(TRIM(damage), '') AS damage,
  	
  	-- Ya está en TIMESTAMP
  	date_police_notified,
  	
  	NULLIF(TRIM(prim_contributory_cause), '') AS prim_contributory_cause,
  	NULLIF(TRIM(sec_contributory_cause), '') AS sec_contributory_cause,
  	
  	-- Misma lógica que en posted_speed_limit
  	CASE
    	WHEN NULLIF(TRIM(street_no), '') ~ '^[0-9]+$'
    	THEN TRIM(street_no)::INT
    	ELSE NULL
  	END AS street_no,

  	NULLIF(TRIM(street_direction), '') AS street_direction,
  	NULLIF(TRIM(street_name), '') AS street_name,
  	
  	CASE
    	WHEN NULLIF(TRIM(beat_of_occurrence), '') ~ '^[0-9]+$'
    	THEN TRIM(beat_of_occurrence)::INT
    	ELSE NULL
  	END AS beat_of_occurrence,
  	
  	CASE
    	WHEN NULLIF(TRIM(photos_taken_i), '') = 'Y' THEN TRUE
    	WHEN NULLIF(TRIM(photos_taken_i), '') = 'N' THEN FALSE
    	ELSE NULL
  	END AS photos_taken,

  	CASE
    	WHEN NULLIF(TRIM(statements_taken_i), '') = 'Y' THEN TRUE
    	WHEN NULLIF(TRIM(statements_taken_i), '') = 'N' THEN FALSE
    	ELSE NULL
  	END AS statements_taken,

  	CASE
    	WHEN NULLIF(TRIM(dooring_i), '') = 'Y' THEN TRUE
    	WHEN NULLIF(TRIM(dooring_i), '') = 'N' THEN FALSE
    	ELSE NULL
  	END AS dooring,

  	CASE
    	WHEN NULLIF(TRIM(work_zone_i), '') = 'Y' THEN TRUE
    	WHEN NULLIF(TRIM(work_zone_i), '') = 'N' THEN FALSE
    	ELSE NULL
  	END AS work_zone,

  	NULLIF(TRIM(work_zone_type), '') AS work_zone_type,
  	
  	CASE
    	WHEN NULLIF(TRIM(workers_present_i), '') = 'Y' THEN TRUE
    	WHEN NULLIF(TRIM(workers_present_i), '') = 'N' THEN FALSE
    	ELSE NULL
  	END AS workers_present,
  	
  	-- Misma lógica que en posted_speed_limit
  	CASE
    	WHEN NULLIF(TRIM(num_units), '') ~ '^[0-9]+$'
    	THEN TRIM(num_units)::INT
    	ELSE NULL
  	END AS num_units,

  	NULLIF(TRIM(most_severe_injury), '') AS most_severe_injury,
  	
  	-- En la siguientes si hay valores raros, quedan como NULL
  	CASE 
  		WHEN NULLIF(TRIM(injuries_total), '') ~ '^[0-9]+$' 
  		THEN TRIM(injuries_total)::INT 
  	END AS injuries_total,
  	
  	CASE 
  		WHEN NULLIF(TRIM(injuries_fatal), '') ~ '^[0-9]+$'
  		THEN TRIM(injuries_fatal)::INT
  		END AS injuries_fatal,
  		
  	CASE 
  		WHEN NULLIF(TRIM(injuries_incapacitating), '') ~ '^[0-9]+$'
  		THEN TRIM(injuries_incapacitating)::INT
  		END AS injuries_incapacitating,
  		
  	CASE 
  		WHEN NULLIF(TRIM(injuries_non_incapacitating), '') ~ '^[0-9]+$'
  		THEN TRIM(injuries_non_incapacitating)::INT
  		END AS injuries_non_incapacitating,
  		
  	CASE
  		WHEN NULLIF(TRIM(injuries_reported_not_evident), '') ~ '^[0-9]+$'
  		THEN TRIM(injuries_reported_not_evident)::INT
  		END AS injuries_reported_not_evident,
  		
  	CASE
  		WHEN NULLIF(TRIM(injuries_no_indication), '') ~ '^[0-9]+$'
  		THEN TRIM(injuries_no_indication)::INT
  		END AS injuries_no_indication,
  		
  	CASE
  		WHEN NULLIF(TRIM(injuries_unknown), '') ~ '^[0-9]+$'
  		THEN TRIM(injuries_unknown)::INT
  		END AS injuries_unknown,
  	
  	--Nos aseguramos que los rangos de los datos tengan sentido	
  	CASE 
  		WHEN crash_hour BETWEEN 0 AND 23
  		THEN crash_hour::INT
  		ELSE NULL
  	END AS crash_hour,
  	
  	CASE
  		WHEN crash_day_of_week BETWEEN 1 AND 7
  		THEN crash_day_of_week::INT
  		ELSE NULL
  	END AS crash_day_of_week,
  
  	CASE
  		WHEN crash_month BETWEEN 1 AND 12
  		THEN crash_month::INT
  		ELSE NULL
  	END AS crash_month,
  	
  	-- Tomamos como nulos los lugares en donde la longitud o la latitud es igual a 0
  	CASE 
  		WHEN latitude = 0 OR latitude IS NULL THEN NULL ELSE latitude
  	END AS latitude,
  		
  	CASE 
  		WHEN longitude = 0 OR longitude IS NULL THEN NULL ELSE longitude
  	END AS longitude,
  	
  	-- location es un campo de texto/NULL: Si el valor es el punto inválido 'POINT (0 0)', se transforma directamente a 	NULL. Si no, se usa TRIM y NULLIF para normalizar cualquier otro valor vacío o de solo espacios a NULL.
  	CASE
    	WHEN TRIM(location) = 'POINT (0 0)' THEN NULL
    	ELSE NULLIF(TRIM(location), '')
  	END AS location
  	
FROM traffic_crashes
-- Se usa TRIM y NULLIF para asegurar que el crash_record_id NO sea NULL, vacío o solo espacios. Las filas que no tienen un ID son descartadas.
WHERE NULLIF(TRIM(crash_record_id), '') IS NOT NULL;





-- ¿Cuántas filas quedaron?
SELECT (SELECT COUNT(*) FROM traffic_crashes) AS raw_rows,
       (SELECT COUNT(*) FROM traffic_crashes_clean) AS clean_rows;

-- ¿Cuántas coordenadas inválidas se limpiaron?
SELECT COUNT(*) AS null_coords_clean
FROM traffic_crashes_clean
WHERE latitude IS NULL OR longitude IS NULL;

-- ¿IDs duplicados en clean?
SELECT crash_record_id, COUNT(*)
FROM traffic_crashes_clean
GROUP BY crash_record_id
HAVING COUNT(*) > 1;



SELECT
  COUNT(*) AS total,
  COUNT(posted_speed_limit) AS speed_ok,
  COUNT(*) - COUNT(posted_speed_limit) AS speed_null,
  COUNT(num_units) AS units_ok,
  COUNT(*) - COUNT(num_units) AS units_null,
  COUNT(injuries_total) AS injuries_ok,
  COUNT(*) - COUNT(injuries_total) AS injuries_null
FROM traffic_crashes_clean;


-- Inconsistencias de lesiones:

SELECT COUNT(*) AS impossible_injuries
FROM traffic_crashes_clean
WHERE injuries_total IS NOT NULL
 	AND injuries_fatal IS NOT NULL
	AND injuries_total < injuries_fatal;


-- Vemos las filas donde injuries_total quedaron como null para saber si nos sirven
SELECT crash_record_id, crash_date, injuries_total, injuries_fatal, most_severe_injury
FROM traffic_crashes_clean
WHERE injuries_total IS NULL
LIMIT 30;

SELECT
  COUNT(*) AS total_inj_total_null,
  COUNT(*) FILTER (WHERE injuries_fatal IS NOT NULL
                OR injuries_incapacitating IS NOT NULL
                OR injuries_non_incapacitating IS NOT NULL
                OR injuries_reported_not_evident IS NOT NULL
                OR injuries_no_indication IS NOT NULL
                OR injuries_unknown IS NOT NULL) AS has_other_injury_data
FROM traffic_crashes_clean
WHERE injuries_total IS NULL;

-- Revisamos la clave
SELECT COUNT(*) AS impossible_injuries
FROM traffic_crashes_clean
WHERE injuries_total IS NOT NULL
  AND injuries_fatal IS NOT NULL
  AND injuries_total < injuries_fatal;


-- Validación de rangos de horas, días y meses:

-- Solo contamos cuentos nulls quedan para ver la mejor opción de manejo de datos
SELECT
  COUNT(*) FILTER (WHERE crash_hour IS NULL) AS null_hour,
  COUNT(*) FILTER (WHERE crash_day_of_week IS NULL) AS null_dow,
  COUNT(*) FILTER (WHERE crash_month IS NULL) AS null_month
FROM traffic_crashes_clean;


--Últimos detalles:

-- Al ver los datos, nos dimos cuenta que la mayoría de ellos tenía cosas como "UNKNOWN" O "NOT APPLICABLE" que para nuestra conveniencia lo dejaremos en NULL
UPDATE traffic_crashes_clean
SET weather_condition = NULL
WHERE weather_condition IN ('UNKNOWN', 'NOT APPLICABLE');

UPDATE traffic_crashes_clean
SET road_defect = NULL
WHERE road_defect IN ('UNKNOWN', 'NOT APPLICABLE');

-- Como último paso en el nombre de las calles buscamos eliminar los espacios dobles y poner todo el mayúsculas
UPDATE traffic_crashes_clean
SET street_name = UPPER(TRIM(street_name))
WHERE street_name IS NOT NULL;








