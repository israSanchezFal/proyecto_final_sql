from datetime import datetime
from decimal import Decimal
from typing import Optional, Literal

from pydantic import BaseModel


# =========================
# Crash
# =========================
class CrashBase(BaseModel):
    crash_record_id: str

    crash_date_est: Optional[bool] = None
    crash_date: datetime
    date_police_notified: datetime

    crash_hour: int
    crash_day_of_week: int
    crash_month: int

    posted_speed_limit: int
    traffic_control_device: str
    device_condition: str
    weather_condition: Optional[str] = None
    lighting_condition: str
    first_crash_type: str
    trafficway_type: str

    lane_cnt: Optional[int] = None
    alignment: str
    roadway_surface_cond: str
    road_defect: Optional[str] = None
    report_type: Optional[str] = None
    crash_type: str

    intersection_related: Optional[bool] = None
    not_right_of_way: Optional[bool] = None
    hit_and_run: Optional[bool] = None

    damage: str
    photos_taken: Optional[bool] = None
    statements_taken: Optional[bool] = None
    dooring: Optional[bool] = None

    work_zone: Optional[bool] = None
    work_zone_type: Optional[str] = None
    workers_present: Optional[bool] = None

    num_units: int


class CrashCreate(CrashBase):
    pass


class CrashResponse(CrashBase):
    crash_id: int

    class Config:
        from_attributes = True


# =========================
# CrashLocation (1-1)
# =========================
class CrashLocationBase(BaseModel):
    crash_id: int

    street_no: int
    street_direction: Optional[str] = None
    street_name: Optional[str] = None
    beat_of_occurrence: Optional[int] = None

    latitude: Optional[Decimal] = None
    longitude: Optional[Decimal] = None
    location: Optional[str] = None


class CrashLocationCreate(CrashLocationBase):
    pass


class CrashLocationResponse(CrashLocationBase):
    class Config:
        from_attributes = True


# =========================
# CrashInjurySummary (1-1)
# =========================
class CrashInjurySummaryBase(BaseModel):
    crash_id: int

    most_severe_injury: Optional[str] = None

    injuries_total: Optional[int] = None
    injuries_fatal: Optional[int] = None
    injuries_incapacitating: Optional[int] = None
    injuries_non_incapacitating: Optional[int] = None
    injuries_reported_not_evident: Optional[int] = None
    injuries_no_indication: Optional[int] = None
    injuries_unknown: Optional[int] = None


class CrashInjurySummaryCreate(CrashInjurySummaryBase):
    pass


class CrashInjurySummaryResponse(CrashInjurySummaryBase):
    class Config:
        from_attributes = True


# =========================
# CatContributoryCause (catálogo)
# =========================
class CatContributoryCauseBase(BaseModel):
    cause_text: str


class CatContributoryCauseCreate(CatContributoryCauseBase):
    pass


class CatContributoryCauseResponse(CatContributoryCauseBase):
    cause_id: int

    class Config:
        from_attributes = True


# =========================
# CrashCause (tabla pivote)
# =========================
CauseRole = Literal["PRIMARY", "SECONDARY"]


class CrashCauseBase(BaseModel):
    crash_id: int
    cause_id: int
    cause_role: CauseRole


class CrashCauseCreate(CrashCauseBase):
    pass


class CrashCauseResponse(CrashCauseBase):
    class Config:
        from_attributes = True

