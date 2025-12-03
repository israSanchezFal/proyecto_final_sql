# Consultas 

## ❄️ Cómo tiene que ver el clima con los accidentes

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

