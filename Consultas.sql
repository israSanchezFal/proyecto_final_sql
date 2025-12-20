--C1.  Análisis de crecimiento mensual de accidentes
SELECT 
    TO_CHAR(c.crash_date, 'YYYY-MM') AS mes_anio,
    COUNT(c.crash_id) AS total_accidentes,
    -- Función de ventana para obtener el valor del mes anterior
    LAG(COUNT(c.crash_id)) OVER (ORDER BY TO_CHAR(c.crash_date, 'YYYY-MM')) AS accidentes_mes_anterior,
    -- Atributo Enriquecido: Cálculo del cambio porcentual
    ROUND(
        (COUNT(c.crash_id) - LAG(COUNT(c.crash_id)) OVER (ORDER BY TO_CHAR(c.crash_date, 'YYYY-MM')))::numeric / 
        NULLIF(LAG(COUNT(c.crash_id)) OVER (ORDER BY TO_CHAR(c.crash_date, 'YYYY-MM')), 0) * 100, 
    2) AS cambio_mensual_pct
FROM 
    public.crash c
GROUP BY 
    TO_CHAR(c.crash_date, 'YYYY-MM')
ORDER BY 
    mes_anio DESC;




--C2.  Ranking de condiciones climáticas por severidad económica--
SELECT 
    c.weather_condition,
    c.lighting_condition,
    COUNT(c.crash_id) AS cantidad_accidentes,
    -- Atributo enriquecido: Transformar el texto de daños a un valor numérico estimado para ordenar
    AVG(CASE 
        WHEN c.damage = 'OVER $1,500' THEN 1500
        WHEN c.damage = '$501 - $1,500' THEN 1000
        WHEN c.damage = '$500 OR LESS' THEN 250
        ELSE 0 
    END) AS costo_promedio_estimado,
    -- Función de ventana: Ranking de peligrosidad
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
    c.weather_condition, 
    c.lighting_condition
ORDER BY 
    ranking_severidad ASC
LIMIT 15;




--C3.  Relación entre la causa contributiva y la fatalidad--
SELECT 
    cat.cause_text AS causa_principal,
    COUNT(c.crash_id) AS total_eventos,
    SUM(cis.injuries_fatal) AS total_muertes,
    SUM(cis.injuries_total) AS total_heridos,
    -- Atributo Enriquecido: Índice de letalidad (muertes por cada 100 accidentes de este tipo)
    ROUND(
        (SUM(cis.injuries_fatal)::numeric / NULLIF(COUNT(c.crash_id), 0)) * 100, 
    4) AS indice_letalidad
FROM 
    public.crash c
JOIN 
    public.crash_cause cc ON c.crash_id = cc.crash_id  -- CORRECCIÓN AQUÍ: Usamos crash_id
JOIN 
    public.cat_contributory_cause cat ON cc.cause_id = cat.cause_id
JOIN 
    public.crash_injury_summary cis ON c.crash_id = cis.crash_id
WHERE 
    cc.cause_role = 'PRIMARY' -- Filtramos solo la causa principal para no duplicar
GROUP BY 
    cat.cause_text
HAVING 
    COUNT(c.crash_id) > 50 -- Filtramos causas muy raras para limpiar el análisis
ORDER BY 
    indice_letalidad DESC 
LIMIT 10;




--C4. Severidad vs límite de velocidad--
SELECT 
    -- 1. Creación de Bandas de Velocidad (Binning)
    CASE 
        WHEN c.posted_speed_limit <= 20 THEN '00-20 MPH (Zona Lenta)'
        WHEN c.posted_speed_limit > 20 AND c.posted_speed_limit <= 30 THEN '21-30 MPH (Urbano)'
        WHEN c.posted_speed_limit > 30 AND c.posted_speed_limit <= 45 THEN '31-45 MPH (Avenidas)'
        WHEN c.posted_speed_limit > 45 AND c.posted_speed_limit <= 60 THEN '46-60 MPH (Rápida)'
        WHEN c.posted_speed_limit > 60 THEN '61+ MPH (Autopista)'
        ELSE 'Desconocido'
    END AS banda_velocidad,

    -- 2. Métricas Base
    COUNT(c.crash_id) AS total_accidentes,
    SUM(cis.injuries_total) AS total_heridos,
    SUM(cis.injuries_fatal) AS total_muertes,

    -- 3. Atributo Analítico: Severidad Promedio (Heridos por accidente)
    ROUND(AVG(cis.injuries_total), 4) AS promedio_heridos_por_evento,

    -- 4. Atributo Analítico: Probabilidad de Lesión (%)
    -- Porcentaje de accidentes en esta banda que tuvieron al menos 1 herido
    ROUND(
        (COUNT(CASE WHEN cis.injuries_total > 0 THEN 1 END)::numeric / 
        NULLIF(COUNT(c.crash_id), 0)) * 100, 
    2) AS probabilidad_lesion_pct

FROM 
    public.crash c
JOIN 
    public.crash_injury_summary cis ON c.crash_id = cis.crash_id
WHERE 
    c.posted_speed_limit > 0 -- Filtramos errores de captura (velocidad 0)
GROUP BY 
    1 -- Agrupamos por la primera columna (el CASE)
ORDER BY 
    banda_velocidad ASC;



--C5. Calle más peligrosa (Ranking y Contribución)
WITH rankin_calles AS (
    SELECT 
        street_name,
        COUNT(*) AS total_choques,
        -- Sumamos todos los conteos para tener el gran total global
        SUM(COUNT(*)) OVER () AS gran_total_choques,
        -- Ranking para identificar el Top 10 de peligrosidad
        RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking_peligrosidad
    FROM crash_location
    GROUP BY street_name
)
SELECT 
    ranking_peligrosidad AS puesto,
    street_name,
    total_choques,
    -- Porcentaje de impacto de la calle sobre el total de la ciudad
    ROUND(
        (total_choques::numeric / NULLIF(gran_total_choques, 0)) * 100, 4
    ) AS porcentaje_del_total_global
FROM rankin_calles
WHERE ranking_peligrosidad <= 10
ORDER BY ranking_peligrosidad ASC;

--C6. Análisis de 'Hit and Run': Distribución y peso porcentual por tipo de daño
WITH fugas_por_costo AS (
    SELECT 
        damage AS tipo_daño,
        COUNT(*) AS total_casos,
        -- Suma total de fugas (sin agrupar) para sacar el porcentaje
        SUM(COUNT(*)) OVER () AS total_fugas_global
    FROM crash
    WHERE hit_and_run = 'TRUE'
    GROUP BY damage
)
SELECT 
    tipo_daño,
    total_casos,
    -- ¿Qué porcentaje representa este daño del total de fugas?
    ROUND(
        (total_casos::numeric / NULLIF(total_fugas_global, 0)) * 100, 2
    ) AS porcentaje
FROM fugas_por_costo
ORDER BY total_casos DESC;



--C7. Mes/Año con mayor cantidad de choques y su porcentaje anual
WITH datos_por_mes AS (
    SELECT 
        EXTRACT(YEAR FROM crash_date) AS anio, 
        EXTRACT(MONTH FROM crash_date) AS mes, 
        COUNT(*) AS choques_mes
    FROM crash
    GROUP BY anio, mes
),
ranking_totales AS (
    -- Totales anuales y ranking
    SELECT 
        anio, 
        mes, 
        choques_mes, 
        SUM(choques_mes) OVER (PARTITION BY anio) AS choques_anio, 
        -- Ranking para identificar el mes #1 de cada año
        RANK() OVER (PARTITION BY anio ORDER BY choques_mes DESC) AS ranking_mes
    FROM datos_por_mes
)
SELECT 
    anio,
    mes,
    choques_mes,
    choques_anio,
    -- Cálculo del porcentaje (parseando a decimal para precisión)
    ROUND((choques_mes::numeric / choques_anio) * 100, 2) AS porcentaje_del_anio 
FROM rankingYtotales
WHERE ranking_mes = 1
ORDER BY anio;



--C8. Horario por zona con mayor cantidad de choques (zonas más peligrosas)--
WITH zona_y_hora AS (
    SELECT 
        crash_location.beat_of_occurrence AS zona,
        crash_location.street_name AS nombre_calle,
        crash.crash_hour AS hora,
        COUNT(*) AS total_choques
    FROM crash
    JOIN crash_location ON crash.crash_id = crash_location.crash_id
    GROUP BY crash_location.beat_of_occurrence, crash_location.street_name, crash.crash_hour
),
ranking_horario AS (
	SELECT 
        zona, 
        nombre_calle, 
        hora, 
        total_choques, 
        RANK() OVER (PARTITION BY zona ORDER BY total_choques DESC) AS ranking
	FROM zona_y_hora
)
SELECT 
    zona, 
    nombre_calle, 
    hora AS hora_mas_peligrosa, 
    total_choques
FROM ranking_horario
WHERE ranking = 1 
ORDER BY zona ASC;
