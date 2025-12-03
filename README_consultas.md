
## 💸 Análisis de Impacto Económico: El Costo Invisible del Clima

### 🎯 Objetivo del Análisis
Identificar qué combinaciones de **clima e iluminación** generan los accidentes más costosos. A diferencia de la frecuencia (dónde ocurren más choques), este análisis se centra en la **severidad económica**, permitiendo a las aseguradoras y organismos públicos prever reservas de capital para condiciones específicas.

### 🧠 Metodología y Lógica SQL
Dado que el costo exacto es una variable discreta por rangos, creamos un **Atributo Enriquecido** llamado `costo_promedio_estimado`.
* **Transformación:** Convertimos las categorías de texto (`OVER $1,500`) a valores numéricos ponderados mediante una expresión `CASE`.
* **Ranking:** Utilizamos la función de ventana `DENSE_RANK()` para clasificar las condiciones de mayor a menor impacto financiero, sin saltos en la numeración.

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


## 💀 Análisis de Letalidad: Distinguiendo lo Frecuente de lo Mortal

### 🎯 Objetivo del Análisis
En seguridad vial, es común confundir la *frecuencia* de un accidente con su *peligrosidad*. Este análisis busca calcular el **Índice de Letalidad** real de cada causa.
* **Pregunta clave:** Si tienes un accidente por la causa X, ¿qué probabilidad hay de que sea fatal?

### 🧠 Lógica del Atributo Enriquecido
Creamos una métrica llamada `indice_letalidad` que normaliza los datos. No nos importa cuántos accidentes ocurrieron en total, sino la proporción de muertes por evento.

$$\text{Índice de Letalidad} = \left( \frac{\text{Total Muertes}}{\text{Total Accidentes de esa Causa}} \right) \times 100$$

```console
-- Consulta: Top 10 Causas con mayor índice de mortalidad
SELECT 
    cat.cause_text AS causa_principal,
    COUNT(c.crash_id) AS total_eventos,
    SUM(cis.injuries_fatal) AS total_muertes,
    SUM(cis.injuries_total) AS total_heridos,
    ROUND(
        (SUM(cis.injuries_fatal)::numeric / NULLIF(COUNT(c.crash_id), 0)) * 100, 
    4) AS indice_letalidad
FROM 
    public.crash c
JOIN 
    public.crash_cause cc ON c.crash_id = cc.crash_id 
JOIN 
    public.cat_contributory_cause cat ON cc.cause_id = cat.cause_id
JOIN 
    public.crash_injury_summary cis ON c.crash_id = cis.crash_id
WHERE 
    cc.cause_role = 'PRIMARY' 
GROUP BY 
    cat.cause_text
HAVING 
    COUNT(c.crash_id) > 50 
ORDER BY 
    indice_letalidad DESC 
LIMIT 10;
```
