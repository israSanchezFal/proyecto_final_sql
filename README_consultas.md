# Consultas 

## ❄️ ¿Cómo tiene que ver el clima con los accidentes?

### 🎯 Objetivo del Análisis
Identificar qué combinaciones de **clima e iluminación** generan los accidentes más costosos. A diferencia de la frecuencia (dónde ocurren más choques), este análisis se centra en la **severidad económica**, permitiendo a las aseguradoras y organismos públicos prever reservas de capital para condiciones específicas.

### 🧠 Metodología y Lógica SQL
Dado que el costo exacto es una variable discreta por rangos, creamos un **Atributo Enriquecido** llamado `costo_promedio_estimado`.
* **Transformación:** Convertimos las categorías de texto (`OVER $1,500`) a valores numéricos ponderados mediante una expresión `CASE`.
* **Ranking:** Utilizamos la función de ventana `DENSE_RANK()` para clasificar las condiciones de mayor a menor impacto financiero, sin saltos en la numeración.

```sql
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



## 🚑🤕 Causas principales de los accidentes e indices de letalidad 

Para identificar qué comportamientos de los conductores están asociados con los choques más graves, se construyó una consulta que:

- Toma únicamente la **causa principal** del siniestro (`cause_role = 'PRIMARY'`).
- Agrupa por la descripción de la causa (`cause_text`).
- Calcula, para cada causa:
  - `total_eventos`: número de choques en los que esa es la causa principal.
  - `total_muertes`: número total de víctimas fatales.
  - `total_heridos`: número total de personas lesionadas.
  - `indice_letalidad`: muertes por cada 100 choques de ese tipo:

   $$\text{Índice de Letalidad} = \left( \frac{\text{Total Muertes}}{\text{Total Accidentes de esa Causa}} \right) \times 100$$

Además, se filtran las causas con menos de 50 eventos para evitar resultados poco representativos y se ordena por `indice_letalidad` de mayor a menor, mostrando el **Top 10**.

A partir de esta consulta se observa que:

- Causas como **“PHYSICAL CONDITION OF DRIVER”** y **“EXCEEDING AUTHORIZED SPEED LIMIT”** presentan los **índices de letalidad más altos** (más de 1 muerte por cada 100 choques de ese tipo).
- Otras causas, como **“DRIVING ON WRONG SIDE/WRONG WAY”**, **“UNDER THE INFLUENCE OF ALCOHOL/DRUGS”** o **“DISREGARDING TRAFFIC SIGNALS”**, combinan un **volumen muy alto de eventos** con un índice de letalidad elevado.
- En conjunto, estos resultados sugieren que las políticas de seguridad vial deberían priorizar:
  - el control de velocidad,
  - la condición física y estado del conductor,
  - y el cumplimiento de la señalización y reglas de tránsito.

Este análisis convierte los datos crudos de lesiones y muertes en un atributo analítico interpretable (`indice_letalidad`), útil para priorizar intervenciones y campañas de prevención.

<img width="957" height="277" alt="Captura de pantalla 2025-12-03 a la(s) 11 18 37 a m" src="https://github.com/user-attachments/assets/21b41976-f251-45ec-9ec8-0e59afcdec05" />

## 🛣️ La Calle más Peligrosa: Ranking y Contribución
### 🎯 Objetivo del Análisis
Identificar las zonas que concentran la mayor cantidad de accidentes de acuerdo a los registros historicos de la base(desde 2013). De ésta consulta no se espera encontrar puntos criticos aislados (independientes entre sí). Queremos un **patrón** repetitivo de las caracteristicas en común que podrían estarse generalizando en las zonas.
### 🧠 Metodología y Lógica SQL
Agrupamos los accidentes por nombre de la calle y ,con una funcion de ventana, obtenemos la suma total de de choques de la ciudad para luego calcular los porcentajes por calle. Finalmente, usamos `RANK()` para extraer las 10 zonas de mayor urgencia (se tuvo en mente los empates).

| Puesto | Street Name  | Total Choques | % del Total Global |
|-------:|--------------|---------------:|-------------------:|
| 1 | WESTERN AVE  | 27,416 | 2.7435 |
| 2 | PULASKI RD  | 23,993 | 2.4010 |
| 3 | CICERO AVE   | 22,449 | 2.2465 |
| 4 | ASHLAND AVE  | 21,673 | 2.1688 |
| 5 | HALSTED ST   | 19,257 | 1.9271 |
| 6 | KEDZIE AVE   | 17,471 | 1.7483 |
| 7 | MICHIGAN AVE | 12,824 | 1.2833 |
| 8 | NORTH AVE    | 11,544 | 1.1552 |
| 9 | STATE ST     | 11,209 | 1.1217 |
|10 | CLARK ST     | 10,723 | 1.0731 |


### 🛠️ Plan de Acción y Medidas de Prevención
* **Análisis de Características Comunes:** Estudiar si estas 10 calles comparten problemas de infraestructura (como mala iluminación o falta de señales reflectantes) para aplicar una solución estandarizada en todas ellas.

* **Focalización de Presupuesto:** Priorizar estas vialidades en los programas de mantenimiento, ya que intervenir el Top 10 tiene un impacto masivo en la reducción del porcentaje total de accidentes de la ciudad.

* **Vigilancia por Patrones:** Implementar radares de velocidad y operativos de tránsito en estos puntos, dado que presentan comportamientos de riesgo que se repiten de forma constante.

## 🏎️💨 Análisis de 'Hit and Run': Distribución y peso porcentual
### 🎯 Objetivo del Análisis
Determinar la gravedad de los accidentes donde el responsable se da a la fuga (Hit and Run). El objetivo es entender si estos incidentes suelen ser colisiones menores o si existe una correlación entre daños severos y la decisión de abandonar la escena.
### 🧠 Metodología y Lógica SQL
* **Filtrar:** Necesitamos filtrar los datos de manera que solamente manejemos el conjunto de accidentes en los cuales se dieron a la fuga, por lo que seleccionaremos exclusivamente los registros donde hit_and_run = 'TRUE' .
* **Calculo porcentual:** Aplicamos la funcion de ventana `SUM(COUNT(*)) OVER ()` para obtener el total de fugas "sin agrupar", lo que nos permite calcular el total de fugas y el porcentaje de cada categoria de daño sobre el conjunto.
*  **Precision:** Casteamos a numeric para segurar decimales precisos.

```sql
ch
```

### 🛡️ Estrategias Basadas en la Severidad de las Fugas
a) Para Daños Mayores (Over $1,500)
Si el porcentaje en esta categoría es alto, indica que los conductores huyen para evitar consecuencias legales graves.
Implementación de Cámaras: Instalar lectores de matrículas en intersecciones con alta incidencia de fugas de alto costo para rastrear vehículos en tiempo real tras el impacto.
Agravamiento de Penas: Proponer reformas donde el "abandono de escena" en accidentes de alto costo tenga una penalización superior a la del propio accidente, eliminando el "incentivo" de huir.
Botón de Reporte Inmediato.

b) Para Daños Menores ($500 or Less)
   
Simplificación del Reporte: Crear un portal digital donde los involucrados puedan intercambiar datos y fotos sin necesidad de esperar a una patrulla por horas (lo cual motiva la fuga en choques leves).

Seguros de "Responsabilidad Civil" Accesibles: Campañas de concientización sobre seguros de bajo costo que cubran daños a terceros, reduciendo el miedo del conductor a afrontar el gasto.

## 📅📈 Meses con Mayor Siniestralidad y Peso Anual
### 🎯 Objetivo del Análisis
Identificar los meses con mayor volumen de accidentes por año.
Con una subconsulta se agrupan los datos por mes y por año y, con ayuda de funciones de ventana, se calcula el total de choques anuales y clasifica por frecuencia de forma descendente. Finalmente se extrae el primer lugar de cada periodo **anual**.

| Año | Mes | Choques del Mes | Choques del Año | % del Año |
|----:|----:|----------------:|----------------:|----------:|
| 2013 | 6  | 1     | 2     | 50.00 |
| 2013 | 3  | 1     | 2     | 50.00 |
| 2014 | 1  | 2     | 6     | 33.33 |
| 2015 | 10 | 2,808 | 9,831 | 28.56 |
| 2016 | 12 | 5,052 | 44,297 | 11.40 |
| 2017 | 12 | 10,108 | 83,786 | 12.06 |
| 2018 | 5  | 10,714 | 118,951 | 9.01 |
| 2019 | 5  | 10,709 | 117,764 | 9.09 |
| 2020 | 8  | 9,161 | 92,095 | 9.95 |
| 2021 | 6  | 10,335 | 108,766 | 9.50 |
| 2022 | 10 | 9,910 | 108,411 | 9.14 |
| 2023 | 5  | 10,142 | 110,752 | 9.16 |
| 2024 | 5  | 10,741 | 112,050 | 9.59 |
| 2025 | 8  | 10,188 | 92,581 | 11.00 |


### 💡Acciones estrategicas
* Optimización Operativa: Ajustar los roles de patrullaje y turnos de servicios de emergencia para maximizar la cobertura durante los meses que concentran el mayor porcentaje de accidentes anuales.

* Mantenimiento Preventivo de Vías: Programar la renovación de señalización antes de periodos criticos, asegurando que la infraestructura esté en óptimas condiciones.

* Alertas Basadas en Datos: Ejecutar campañas de comunicación focalizadas en los factores de riesgo específicos del mes detectado.

## 📍🕒 Horarios Críticos por Zona
### 🎯 Objetivo del Análisis
Identificar el momento exacto de mayor riesgo en cada sector. No todas las zonas son peligrosas a la misma hora; este análisis nos dice cuándo y dónde debemos reforzar la seguridad para prevenir accidentes de manera estratégica.
### 🧠 Metodología y Lógica SQL
Unimos ( `JOIN` ) crash con crash_location para obtener las zonas de los choques, y como primer subconsulta seleccionamos la zona, nombre de la calle, hora y contamos el total de choques. La segunda subconsulta usa función de ventana para que el sistema elija automáticamente solo la hora con más choques de cada lugar, enfocandonos en las zonas problemáticas.

```sql

```
### 🚀 Estrategias de Intervención y Respuesta
* **Vigilancia**: Programar patrullajes preventivos que coincidan con la "hora pico" de cada calle, asegurando presencia policial en el momento de mayor vulnerabilidad.

* **Semáforos**: Ajustar los tiempos de los semáforos en avenidas conflictivas durante las horas detectadas para calmar el flujo de tráfico y evitar colisiones.

* **Iluminación**: En las zonas donde la hora más peligrosa sea nocturna, priorizar la revisión de luminarias para garantizar que los conductores tengan visibilidad total.
