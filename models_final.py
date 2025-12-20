from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from database import Base
from sqlalchemy import (
    Column, BigInteger, Integer, String, Text, Boolean, DateTime, Numeric,
    ForeignKey, UniqueConstraint, CheckConstraint
)

#proyecto
class Crash(Base):
    __tablename__ = "crash"

    crash_id = Column(BigInteger, primary_key=True, index=True)
    crash_record_id = Column(String, nullable=False, unique=True)

    crash_date_est = Column(Boolean, nullable=True)
    crash_date = Column(DateTime, nullable=False)
    date_police_notified = Column(DateTime, nullable=False)

    crash_hour = Column(Integer, nullable=False)
    crash_day_of_week = Column(Integer, nullable=False)
    crash_month = Column(Integer, nullable=False)

    posted_speed_limit = Column(Integer, nullable=False)
    traffic_control_device = Column(Text, nullable=False)
    device_condition = Column(Text, nullable=False)
    weather_condition = Column(Text, nullable=True)
    lighting_condition = Column(Text, nullable=False)

    first_crash_type = Column(Text, nullable=False)
    trafficway_type = Column(Text, nullable=False)
    alignment = Column(Text, nullable=False)
    roadway_surface_cond = Column(Text, nullable=False)
    road_defect = Column(Text, nullable=True)

    report_type = Column(Text, nullable=True)
    crash_type = Column(Text, nullable=False)

    intersection_related = Column(Boolean, nullable=True)
    not_right_of_way = Column(Boolean, nullable=True)
    hit_and_run = Column(Boolean, nullable=True)

    damage = Column(Text, nullable=False)

    photos_taken = Column(Boolean, nullable=True)
    statements_taken = Column(Boolean, nullable=True)
    dooring = Column(Boolean, nullable=True)

    work_zone = Column(Boolean, nullable=True)
    work_zone_type = Column(Text, nullable=True)
    workers_present = Column(Boolean, nullable=True)

    lane_cnt = Column(Integer, nullable=True)
    num_units = Column(Integer, nullable=False)

    location = relationship(
        "CrashLocation",
        back_populates="crash",
        uselist=False,
        cascade="all, delete-orphan"
    )

    injury_summary = relationship(
        "CrashInjurySummary",
        back_populates="crash",
        uselist=False,
        cascade="all, delete-orphan"
    )

    causes = relationship(
        "CrashCause",
        back_populates="crash",
        cascade="all, delete-orphan"
    )


class CrashLocation(Base):
    __tablename__ = "crash_location"

    crash_id = Column(
        BigInteger,
        ForeignKey("crash.crash_id"),
        primary_key=True,
        nullable=False
    )

    street_no = Column(Integer, nullable=False)
    street_direction = Column(Text, nullable=True)
    street_name = Column(Text, nullable=True)
    beat_of_occurrence = Column(Integer, nullable=True)

    latitude = Column(Numeric, nullable=True)
    longitude = Column(Numeric, nullable=True)
    location = Column(Text, nullable=True)

    crash = relationship("Crash", back_populates="location")


class CrashInjurySummary(Base):
    __tablename__ = "crash_injury_summary"

    crash_id = Column(
        BigInteger,
        ForeignKey("crash.crash_id"),
        primary_key=True,
        nullable=False
    )

    most_severe_injury = Column(Text, nullable=True)

    injuries_total = Column(Integer, nullable=True)
    injuries_fatal = Column(Integer, nullable=True)
    injuries_incapacitating = Column(Integer, nullable=True)
    injuries_non_incapacitating = Column(Integer, nullable=True)
    injuries_reported_not_evident = Column(Integer, nullable=True)
    injuries_no_indication = Column(Integer, nullable=True)
    injuries_unknown = Column(Integer, nullable=True)

    crash = relationship("Crash", back_populates="injury_summary")


class CatContributoryCause(Base):
    __tablename__ = "cat_contributory_cause"

    cause_id = Column(BigInteger, primary_key=True, index=True)
    cause_text = Column(Text, nullable=False, unique=True)

    crash_causes = relationship(
        "CrashCause",
        back_populates="cause",
        cascade="all, delete-orphan"
    )


class CrashCause(Base):
    __tablename__ = "crash_cause"
    __table_args__ = (
        UniqueConstraint("crash_id", "cause_role", name="uq_crash_role"),
        CheckConstraint("cause_role IN ('PRIMARY', 'SECONDARY')", name="ck_cause_role"),
    )

    crash_id = Column(
        BigInteger,
        ForeignKey("crash.crash_id"),
        primary_key=True,
        nullable=False
    )

    cause_id = Column(
        BigInteger,
        ForeignKey("cat_contributory_cause.cause_id"),
        primary_key=True,
        nullable=False
    )

    cause_role = Column(Text, nullable=False)

    crash = relationship("Crash", back_populates="causes")
    cause = relationship("CatContributoryCause", back_populates="crash_causes")
