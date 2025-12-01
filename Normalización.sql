BEGIN;

DROP TABLE IF EXISTS crash_cause;
DROP TABLE IF EXISTS cat_contributory_cause;
DROP TABLE IF EXISTS crash_injury_summary;
DROP TABLE IF EXISTS crash_location;
DROP TABLE IF EXISTS crash;

-- Es la entidad principal
CREATE TABLE crash (
  crash_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  crash_record_id VARCHAR NOT NULL UNIQUE,

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

  photos_taken BOOLEAN,
  statements_taken BOOLEAN,
  dooring BOOLEAN,

  work_zone BOOLEAN,
  work_zone_type TEXT,
  workers_present BOOLEAN,

  num_units INT,

  crash_hour INT,
  crash_day_of_week INT,
  crash_month INT
);

-- Relacion 1 a 1 (o sea hay una ubicación por accidente)
CREATE TABLE crash_location (
  location_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  crash_id BIGINT NOT NULL UNIQUE REFERENCES crash(crash_id),

  street_no INT,
  street_direction TEXT,
  street_name TEXT,
  beat_of_occurrence INT,

  latitude NUMERIC,
  longitude NUMERIC,
  location TEXT
);

-- Todo el resumen de las lesiones es por accidente
CREATE TABLE crash_injury_summary (
  injury_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  crash_id BIGINT NOT NULL UNIQUE REFERENCES crash(crash_id),

  most_severe_injury TEXT,

  injuries_total INT,
  injuries_fatal INT,
  injuries_incapacitating INT,
  injuries_non_incapacitating INT,
  injuries_reported_not_evident INT,
  injuries_no_indication INT,
  injuries_unknown INT
);

-- Causas contribuyentes con un ID artificial y el texto único de cada causa, para evitar repetir ese texto múltiples veces y poder referenciarlo desde otras tablas.
CREATE TABLE cat_contributory_cause (
  cause_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cause_text TEXT NOT NULL UNIQUE
);

-- Tabla pivote, para cada choque (crash_id), su causa primaria y/o secundaria.
CREATE TABLE crash_cause (
  crash_cause_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

  crash_id BIGINT NOT NULL REFERENCES crash(crash_id),
  cause_id BIGINT NOT NULL REFERENCES cat_contributory_cause(cause_id),

  cause_role TEXT NOT NULL CHECK (cause_role IN ('PRIMARY', 'SECONDARY')),

  CONSTRAINT uq_crash_role UNIQUE (crash_id, cause_role)
);


-- Poblamos las tablas con una transacción

BEGIN;

-- Columnas en donde voy a insertar
INSERT INTO crash (
  crash_record_id,
  crash_date_est, crash_date, posted_speed_limit,
  traffic_control_device, device_condition, weather_condition, lighting_condition,
  first_crash_type, trafficway_type,
  lane_cnt, alignment, roadway_surface_cond, road_defect, report_type, crash_type,
  intersection_related, not_right_of_way, hit_and_run,
  damage, date_police_notified,
  photos_taken, statements_taken, dooring,
  work_zone, work_zone_type, workers_present,
  num_units,
  crash_hour, crash_day_of_week, crash_month
)
-- Lo que voy a insertar
SELECT DISTINCT ON (t.crash_record_id)
  t.crash_record_id,
  t.crash_date_est, t.crash_date, t.posted_speed_limit,
  t.traffic_control_device, t.device_condition, t.weather_condition, t.lighting_condition,
  t.first_crash_type, t.trafficway_type,
  t.lane_cnt, t.alignment, t.roadway_surface_cond, t.road_defect, t.report_type, t.crash_type,
  t.intersection_related, t.not_right_of_way, t.hit_and_run,
  t.damage, t.date_police_notified,
  t.photos_taken, t.statements_taken, t.dooring,
  t.work_zone, t.work_zone_type, t.workers_present,
  t.num_units,
  t.crash_hour, t.crash_day_of_week, t.crash_month
FROM traffic_crashes_clean t
ORDER BY t.crash_record_id;



-- 2) Poblar crash_location
INSERT INTO crash_location(
  crash_id,
  street_no, street_direction, street_name, beat_of_occurrence,
  latitude, longitude, location
)
SELECT
  crash.crash_id,
  t.street_no, t.street_direction, t.street_name, t.beat_of_occurrence,
  t.latitude, t.longitude, t.location
FROM traffic_crashes_clean t
JOIN crash
	ON crash.crash_record_id = t.crash_record_id;

-- 3) Poblar crash_injury_summary
INSERT INTO crash_injury_summary(
  crash_id,
  most_severe_injury,
  injuries_total, injuries_fatal, injuries_incapacitating, injuries_non_incapacitating,
  injuries_reported_not_evident, injuries_no_indication, injuries_unknown
)
SELECT
  crash.crash_id,
  t.most_severe_injury,
  t.injuries_total, t.injuries_fatal, t.injuries_incapacitating, t.injuries_non_incapacitating,
  t.injuries_reported_not_evident, t.injuries_no_indication, t.injuries_unknown
FROM traffic_crashes_clean t
JOIN crash 
	ON crash.crash_record_id = t.crash_record_id;

-- 4) Poblar cat_contributory_cause
INSERT INTO cat_contributory_cause(cause_text)
SELECT DISTINCT cause_text
FROM (
  SELECT prim_contributory_cause AS cause_text 
  FROM traffic_crashes_clean
  UNION
  SELECT sec_contributory_cause  AS cause_text 
  FROM traffic_crashes_clean
) s
WHERE cause_text IS NOT NULL
ON CONFLICT (cause_text) DO NOTHING;

-- 5) Poblar crash_cause
INSERT INTO crash_cause (crash_id, cause_id, cause_role)
SELECT crash.crash_id, cat.cause_id, 'PRIMARY'
FROM traffic_crashes_clean t
JOIN crash 
	ON crash.crash_record_id = t.crash_record_id
JOIN cat_contributory_cause cat 
	ON cat.cause_text = t.prim_contributory_cause
WHERE t.prim_contributory_cause IS NOT NULL
ON CONFLICT (crash_id, cause_role) DO UPDATE
SET cause_id = EXCLUDED.cause_id;

INSERT INTO crash_cause (crash_id, cause_id, cause_role)
SELECT crash.crash_id, cat.cause_id, 'SECONDARY'
FROM traffic_crashes_clean t
JOIN crash 
	ON crash.crash_record_id = t.crash_record_id
JOIN cat_contributory_cause cat 
	ON cat.cause_text = t.sec_contributory_cause
WHERE t.sec_contributory_cause IS NOT NULL
ON CONFLICT (crash_id, cause_role) DO UPDATE
SET cause_id = EXCLUDED.cause_id;

COMMIT;
