from fastapi import FastAPI, Depends, HTTPException, Query
from pydantic import BaseModel, ConfigDict
from sqlalchemy.orm import Session
from sqlalchemy import text
from database import get_db
import schemas
import models_final
from sqlalchemy.exc import IntegrityError

app = FastAPI()

#Proyecto

# CRASH

@app.post("/crash")
def create_crash(crash: schemas.CrashCreate, db: Session = Depends(get_db)):
    db_crash = models_final.Crash(**crash.dict())
    db.add(db_crash)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        return {"message": "Error: crash_record_id duplicado (o constraint violada)"}
    db.refresh(db_crash)
    return {"message": "Crash creado", "crash": db_crash}

@app.get("/crash/{id}")
def get_crash(id: int, db: Session = Depends(get_db)):
    db_crash = db.query(models_final.Crash).filter(models_final.Crash.crash_id == id).first()
    return {"crash": db_crash}

@app.get("/crash")
def get_crashes(db: Session = Depends(get_db), limit: int = 10, skip: int = 0):
    return db.query(models_final.Crash).offset(skip).limit(limit).all()

@app.put("/crash/{id}")
def update_crash(id: int, data: schemas.CrashCreate, db: Session = Depends(get_db)):
    db_crash = db.query(models_final.Crash).filter(models_final.Crash.crash_id == id).first()
    if db_crash:
        for key, value in data.dict().items():
            setattr(db_crash, key, value)
        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            return {"message": "Error: constraint violada (posible crash_record_id duplicado)", "crash": db_crash}
        db.refresh(db_crash)
    return {"crash": db_crash}

@app.delete("/crash/{id}")
def delete_crash(id: int, db: Session = Depends(get_db)):
    db_crash = db.query(models_final.Crash).filter(models_final.Crash.crash_id == id).first()
    if db_crash:
        db.delete(db_crash)
        db.commit()
    return {"crash": db_crash}


# CRASH_LOCATION

@app.post("/crash_location")
def create_crash_location(location: schemas.CrashLocationCreate, db: Session = Depends(get_db)):
    db_location = models_final.CrashLocation(**location.dict())
    db.add(db_location)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        return {"message": "Error: ya existe location para ese crash_id (o crash_id no existe)"}
    db.refresh(db_location)
    return {"message": "CrashLocation creada", "crash_location": db_location}

@app.get("/crash_location/{id}")
def get_crash_location(id: int, db: Session = Depends(get_db)):
    db_location = db.query(models_final.CrashLocation).filter(models_final.CrashLocation.crash_id == id).first()
    return {"crash_location": db_location}

@app.get("/crash_location")
def get_crash_locations(db: Session = Depends(get_db), limit: int = 10, skip: int = 0):
    return db.query(models_final.CrashLocation).offset(skip).limit(limit).all()

@app.put("/crash_location/{id}")
def update_crash_location(id: int, data: schemas.CrashLocationCreate, db: Session = Depends(get_db)):
    db_location = db.query(models_final.CrashLocation).filter(models_final.CrashLocation.crash_id == id).first()
    if db_location:
        for key, value in data.dict().items():
            setattr(db_location, key, value)
        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            return {"message": "Error: constraint violada (unique crash_id / FK)", "crash_location": db_location}
        db.refresh(db_location)
    return {"crash_location": db_location}

@app.delete("/crash_location/{id}")
def delete_crash_location(id: int, db: Session = Depends(get_db)):
    db_location = db.query(models_final.CrashLocation).filter(models_final.CrashLocation.location_id == id).first()
    if db_location:
        db.delete(db_location)
        db.commit()
    return {"crash_location": db_location}



# CRASH_INJURY_SUMMARY

@app.post("/crash_injury_summary")
def create_injury_summary(summary: schemas.CrashInjurySummaryCreate, db: Session = Depends(get_db)):
    db_summary = models_final.CrashInjurySummary(**summary.dict())
    db.add(db_summary)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        return {"message": "Error: ya existe injury_summary para ese crash_id (o crash_id no existe)"}
    db.refresh(db_summary)
    return {"message": "CrashInjurySummary creada", "crash_injury_summary": db_summary}

@app.get("/crash_injury_summary/{id}")
def get_injury_summary(id: int, db: Session = Depends(get_db)):
    db_summary = db.query(models_final.CrashInjurySummary).filter(models_final.CrashInjurySummary.crash_id== id).first()
    return {"crash_injury_summary": db_summary}

@app.get("/crash_injury_summary")
def get_injury_summaries(db: Session = Depends(get_db), limit: int = 10, skip: int = 0):
    return db.query(models_final.CrashInjurySummary).offset(skip).limit(limit).all()

@app.put("/crash_injury_summary/{id}")
def update_injury_summary(id: int, data: schemas.CrashInjurySummaryCreate, db: Session = Depends(get_db)):
    db_summary = db.query(models_final.CrashInjurySummary).filter(models_final.CrashInjurySummary.crash_id== id).first()
    if db_summary:
        for key, value in data.dict().items():
            setattr(db_summary, key, value)
        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            return {"message": "Error: constraint violada (unique crash_id / FK)", "crash_injury_summary": db_summary}
        db.refresh(db_summary)
    return {"crash_injury_summary": db_summary}

@app.delete("/crash_injury_summary/{id}")
def delete_injury_summary(id: int, db: Session = Depends(get_db)):
    db_summary = db.query(models_final.CrashInjurySummary).filter(models_final.CrashInjurySummary.injury_id == id).first()
    if db_summary:
        db.delete(db_summary)
        db.commit()
    return {"crash_injury_summary": db_summary}



# CAT_CONTRIBUTORY_CAUSE

@app.post("/cat_contributory_cause")
def create_cause(cause: schemas.CatContributoryCauseCreate, db: Session = Depends(get_db)):
    db_cause = models_final.CatContributoryCause(**cause.dict())
    db.add(db_cause)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        return {"message": "Error: cause_text duplicado"}
    db.refresh(db_cause)
    return {"message": "Causa creada", "cat_contributory_cause": db_cause}

@app.get("/cat_contributory_cause/{id}")
def get_cause(id: int, db: Session = Depends(get_db)):
    db_cause = db.query(models_final.CatContributoryCause).filter(models_final.CatContributoryCause.cause_id == id).first()
    return {"cat_contributory_cause": db_cause}

@app.get("/cat_contributory_cause")
def get_causes(db: Session = Depends(get_db)):
    return db.query(models_final.CatContributoryCause).all()

@app.put("/cat_contributory_cause/{id}")
def update_cause(id: int, data: schemas.CatContributoryCauseCreate, db: Session = Depends(get_db)):
    db_cause = db.query(models_final.CatContributoryCause).filter(models_final.CatContributoryCause.cause_id == id).first()
    if db_cause:
        for key, value in data.dict().items():
            setattr(db_cause, key, value)
        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            return {"message": "Error: cause_text duplicado", "cat_contributory_cause": db_cause}
        db.refresh(db_cause)
    return {"cat_contributory_cause": db_cause}

@app.delete("/cat_contributory_cause/{id}")
def delete_cause(id: int, db: Session = Depends(get_db)):
    db_cause = db.query(models_final.CatContributoryCause).filter(models_final.CatContributoryCause.cause_id == id).first()
    if db_cause:
        db.delete(db_cause)
        db.commit()
    return {"cat_contributory_cause": db_cause}



# CRASH_CAUSE (PIVOTE)

@app.post("/crash_cause")
def create_crash_cause(cc: schemas.CrashCauseCreate, db: Session = Depends(get_db)):
    db_cc = models_final.CrashCause(**cc.dict())
    db.add(db_cc)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        return {"message": "Error: (crash_id, cause_role) ya existe o FK inválida (crash/cause no existe)"}
    db.refresh(db_cc)
    return {"message": "CrashCause creada", "crash_cause": db_cc}

@app.get("/crash_cause/{id}")
def get_crash_cause(id: int, db: Session = Depends(get_db)):
    db_cc = db.query(models_final.CrashCause).filter(models_final.CrashCause.crash_cause_id == id).first()
    return {"crash_cause": db_cc}

@app.get("/crash_cause")
def get_crash_causes(db: Session = Depends(get_db), limit: int = 10, skip: int = 0):
    return db.query(models_final.CrashCause).offset(skip).limit(limit).all()

@app.put("/crash_cause/{id}")
def update_crash_cause(id: int, data: schemas.CrashCauseCreate, db: Session = Depends(get_db)):
    db_cc = db.query(models_final.CrashCause).filter(models_final.CrashCause.crash_cause_id == id).first()
    if db_cc:
        for key, value in data.dict().items():
            setattr(db_cc, key, value)
        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            return {"message": "Error: uq_crash_role / ck_cause_role / FK", "crash_cause": db_cc}
        db.refresh(db_cc)
    return {"crash_cause": db_cc}

@app.delete("/crash_cause/{id}")
def delete_crash_cause(id: int, db: Session = Depends(get_db)):
    db_cc = db.query(models_final.CrashCause).filter(models_final.CrashCause.crash_cause_id == id).first()
    if db_cc:
        db.delete(db_cc)
        db.commit()
    return {"crash_cause": db_cc}



##--Consultas--

@app.get("/consultas/letalidad")
def top_letalidad_por_causa(
    min_events: int = Query(50, ge=0),
    limit: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db),
    ):
    sql = text("""
        SELECT 
            cat.cause_text AS causa_principal,
            COUNT(c.crash_id) AS total_eventos,
            COALESCE(SUM(cis.injuries_fatal), 0) AS total_muertes,
            COALESCE(SUM(cis.injuries_total), 0) AS total_heridos,
            ROUND(
                (COALESCE(SUM(cis.injuries_fatal), 0)::numeric / NULLIF(COUNT(c.crash_id), 0)) * 100,
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
            COUNT(c.crash_id) > :min_events
        ORDER BY 
            indice_letalidad DESC
        LIMIT :limit;
    """)

    rows = db.execute(
        sql,
        {"min_events": min_events, "limit": limit}
    ).mappings().all()

    return {
        "results": [dict(r) for r in rows],
    }


#climas
@app.get("/consultas/clima")
def ranking_severidad_por_condiciones(
    limit: int = Query(15, ge=1, le=100),
    db: Session = Depends(get_db),
):
    sql = text("""
        SELECT 
            c.weather_condition,
            c.lighting_condition,
            COUNT(c.crash_id) AS cantidad_accidentes,
            AVG(
                CASE 
                    WHEN c.damage = 'OVER $1,500' THEN 1500
                    WHEN c.damage = '$501 - $1,500' THEN 1000
                    WHEN c.damage = '$500 OR LESS' THEN 250
                    ELSE 0 
                END
            ) AS costo_promedio_estimado,
            DENSE_RANK() OVER (
                ORDER BY AVG(
                    CASE 
                        WHEN c.damage = 'OVER $1,500' THEN 1500
                        ELSE 0 
                    END
                ) DESC
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
        LIMIT :limit;
    """)

    rows = db.execute(
        sql,
        {"limit": limit}
    ).mappings().all()

    return [dict(r) for r in rows]

@app.get("/consultas/velocidad")
def severidad_por_banda_velocidad(
    db: Session = Depends(get_db),
):
    sql = text("""
        SELECT 
            CASE 
                WHEN COALESCE(c.posted_speed_limit, 0) <= 20 THEN '00-20 MPH (Zona Lenta)'
                WHEN COALESCE(c.posted_speed_limit, 0) > 20 AND COALESCE(c.posted_speed_limit, 0) <= 30 THEN '21-30 MPH (Urbano)'
                WHEN COALESCE(c.posted_speed_limit, 0) > 30 AND COALESCE(c.posted_speed_limit, 0) <= 45 THEN '31-45 MPH (Avenidas)'
                WHEN COALESCE(c.posted_speed_limit, 0) > 45 AND COALESCE(c.posted_speed_limit, 0) <= 60 THEN '46-60 MPH (Rápida)'
                WHEN COALESCE(c.posted_speed_limit, 0) > 60 THEN '61+ MPH (Autopista)'
                ELSE 'Desconocido'
            END AS banda_velocidad,

            COUNT(c.crash_id) AS total_accidentes,
            COALESCE(SUM(cis.injuries_total), 0) AS total_heridos,
            COALESCE(SUM(cis.injuries_fatal), 0) AS total_muertes,

            ROUND(AVG(COALESCE(cis.injuries_total, 0)), 4) AS promedio_heridos_por_evento,

            ROUND(
                (COUNT(CASE WHEN COALESCE(cis.injuries_total, 0) > 0 THEN 1 END)::numeric /
                 NULLIF(COUNT(c.crash_id), 0)) * 100,
            2) AS probabilidad_lesion_pct

        FROM 
            public.crash c
        LEFT JOIN 
            public.crash_injury_summary cis ON c.crash_id = cis.crash_id
        WHERE 
            COALESCE(c.posted_speed_limit, 0) > 0
        GROUP BY 
            1
        ORDER BY 
            banda_velocidad ASC;
    """)

    rows = db.execute(sql).mappings().all()
    return [dict(r) for r in rows]

@app.get("/consultas/mes_anio")
def mes_pico_por_anio(db: Session = Depends(get_db)):
    sql = text("""
        WITH datos_por_mes AS (
            SELECT 
                EXTRACT(YEAR FROM crash_date) AS anio, 
                EXTRACT(MONTH FROM crash_date) AS mes, 
                COUNT(*) AS choques_mes
            FROM crash
            GROUP BY anio, mes
        ),
        ranking_totales AS (
            SELECT 
                anio, 
                mes, 
                choques_mes, 
                SUM(choques_mes) OVER (PARTITION BY anio) AS choques_anio, 
                RANK() OVER (
                    PARTITION BY anio 
                    ORDER BY choques_mes DESC
                ) AS ranking_mes
            FROM datos_por_mes
        )
        SELECT 
            anio,
            mes,
            choques_mes,
            choques_anio,
            ROUND(
                (choques_mes::numeric / NULLIF(choques_anio, 0)) * 100,
            2) AS porcentaje_del_anio
        FROM ranking_totales
        WHERE ranking_mes = 1
        ORDER BY anio;
    """)

    rows = db.execute(sql).mappings().all()
    return [dict(r) for r in rows]
