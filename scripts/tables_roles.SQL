-- ============================================================================
-- SYSTÈME DE GESTION DE TRANSPORT PUBLIC
-- Script SQL complet : Utilisateurs, Rôles, Tables et Privilèges
-- Auteurs : Mustapha Idabella, Abdessamad Lahlaoui, Othman Gadrouz
-- Année universitaire : 2025/2026
-- ============================================================================

-- ============================================================================
-- SECTION 1 : CRÉATION DES TABLESPACES
-- ============================================================================

CREATE TABLESPACE BUS_DATA
DATAFILE 'bus_data01.dbf' SIZE 500M
AUTOEXTEND ON NEXT 100M MAXSIZE 2G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TEMPORARY TABLESPACE BUS_TEMP
TEMPFILE 'bus_temp01.dbf' SIZE 100M
AUTOEXTEND ON NEXT 50M MAXSIZE 500M;

-- ============================================================================
-- SECTION 2 : CRÉATION DES TABLES (CONFORME AU SCHÉMA)
-- ============================================================================

-- Table CITY
CREATE TABLE CITY (
    id_city      NUMBER(10)     NOT NULL,
    name         VARCHAR2(100)  NOT NULL,
    region       VARCHAR2(100),
    postal_code  VARCHAR2(10),
    country      VARCHAR2(100),
    created_at   TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_city PRIMARY KEY (id_city)
);

-- Table BUS
CREATE TABLE BUS (
    id_bus               NUMBER(10)     NOT NULL,
    plate_number         VARCHAR2(100)  NOT NULL,
    model                VARCHAR2(100)  NOT NULL,
    capacity             NUMBER(5)      NOT NULL,
    year                 NUMBER(4)      NOT NULL,
    status               VARCHAR2(20)   DEFAULT 'AVAILABLE',
    last_maintenance_date DATE,
    created_at           TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_bus PRIMARY KEY (id_bus),
    CONSTRAINT uk_bus_plate_number UNIQUE (plate_number),
    CONSTRAINT chk_bus_status CHECK (status IN ('AVAILABLE', 'IN_SERVICE', 'MAINTENANCE', 'OUT_OF_SERVICE')),
    CONSTRAINT chk_bus_capacity CHECK (capacity > 0),
    CONSTRAINT chk_bus_year CHECK (year >= 1990 AND year <= EXTRACT(YEAR FROM SYSDATE) + 1)
);

-- Table DRIVER
CREATE TABLE DRIVER (
    id_driver         NUMBER(10)     NOT NULL,
    name              VARCHAR2(100)  NOT NULL,
    email             VARCHAR2(100),
    phone             VARCHAR2(15),
    license_number    VARCHAR2(50)   NOT NULL,
    license_expiry    DATE           NOT NULL,
    status            VARCHAR2(20)   DEFAULT 'ACTIVE',
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_driver PRIMARY KEY (id_driver),
    CONSTRAINT uk_driver_license_number UNIQUE (license_number),
    CONSTRAINT chk_driver_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'IN_SERVICE', 'ON_LEAVE')),
    CONSTRAINT chk_driver_email CHECK (email LIKE '%@%.%')
);

-- Table BUS_LINE
CREATE TABLE BUS_LINE (
    id_line           NUMBER(10)     NOT NULL,
    name              VARCHAR2(100)  NOT NULL,
    code              VARCHAR2(20)   NOT NULL,
    duration_minutes  NUMBER(5)      NOT NULL,
    status            VARCHAR2(20)   DEFAULT 'ACTIVE',
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_bus_line PRIMARY KEY (id_line),
    CONSTRAINT uk_bus_line_code UNIQUE (code),
    CONSTRAINT chk_bus_line_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    CONSTRAINT chk_duration CHECK (duration_minutes > 0)
);

-- Table STATION
CREATE TABLE STATION (
    id_station    NUMBER(10)      NOT NULL,
    name          VARCHAR2(100)   NOT NULL,
    address       VARCHAR2(250),
    latitude      DECIMAL(10, 7),
    longitude     DECIMAL(10, 7),
    created_at    TIMESTAMP DEFAULT SYSTIMESTAMP,
    id_city       NUMBER(10)      NOT NULL,
    CONSTRAINT pk_station PRIMARY KEY (id_station),
    CONSTRAINT fk_station_city FOREIGN KEY (id_city) REFERENCES CITY (id_city) ON DELETE CASCADE,
    CONSTRAINT chk_latitude CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_longitude CHECK (longitude BETWEEN -180 AND 180)
);

-- Table LINE_STATION (table de liaison)
CREATE TABLE LINE_STATION (
    id_line                    NUMBER(10)     NOT NULL,
    id_station                 NUMBER(10)     NOT NULL,
    stop_order                 NUMBER(5)      NOT NULL,
    distance_from_start_km     DECIMAL(6, 2),
    CONSTRAINT pk_line_station PRIMARY KEY (id_line, id_station),
    CONSTRAINT uk_line_station_order UNIQUE (id_line, stop_order),
    CONSTRAINT fk_ls_line FOREIGN KEY (id_line) REFERENCES BUS_LINE (id_line) ON DELETE CASCADE,
    CONSTRAINT fk_ls_station FOREIGN KEY (id_station) REFERENCES STATION (id_station) ON DELETE CASCADE,
    CONSTRAINT chk_stop_order CHECK (stop_order > 0),
    CONSTRAINT chk_distance CHECK (distance_from_start_km >= 0)
);

-- Table SCHEDULE
CREATE TABLE SCHEDULE (
    id_schedule      NUMBER(10)    NOT NULL,
    service_type     VARCHAR2(20)  NOT NULL,
    day_of_week      VARCHAR2(20),
    frequency_min    NUMBER(3),
    id_line          NUMBER(10)    NOT NULL,
    CONSTRAINT pk_schedule PRIMARY KEY (id_schedule),
    CONSTRAINT fk_schedule_bus_line FOREIGN KEY (id_line) REFERENCES BUS_LINE (id_line) ON DELETE CASCADE,
    CONSTRAINT chk_schedule_service CHECK (service_type IN ('WEEKDAY', 'WEEKEND', 'HOLIDAY')),
    CONSTRAINT chk_day_of_week CHECK (day_of_week IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY') OR day_of_week IS NULL),
    CONSTRAINT chk_frequency CHECK (frequency_min > 0)
);

-- Table SCHEDULE_STOP
CREATE TABLE SCHEDULE_STOP (
    id_schedule            NUMBER(10)     NOT NULL,
    id_station             NUMBER(10)     NOT NULL,
    scheduled_stop_time    VARCHAR2(10)   NOT NULL,
    CONSTRAINT pk_schedule_stop PRIMARY KEY (id_schedule, id_station),
    CONSTRAINT fk_ss_schedule FOREIGN KEY (id_schedule) REFERENCES SCHEDULE (id_schedule) ON DELETE CASCADE,
    CONSTRAINT fk_ss_station FOREIGN KEY (id_station) REFERENCES STATION (id_station) ON DELETE CASCADE,
    CONSTRAINT chk_time_format CHECK (REGEXP_LIKE(scheduled_stop_time, '^([0-1][0-9]|2[0-3]):[0-5][0-9]$'))
);

-- Table TRIP
CREATE TABLE TRIP (
    id_trip          NUMBER(10)     NOT NULL,
    departure_time   TIMESTAMP      NOT NULL,
    arrival_time     TIMESTAMP,
    status           VARCHAR2(20)   NOT NULL DEFAULT 'SCHEDULED',
    available_seats  NUMBER(3)      NOT NULL,
    price            DECIMAL(8, 2)  NOT NULL,
    created_at       TIMESTAMP DEFAULT SYSTIMESTAMP,
    id_line          NUMBER(10)     NOT NULL,
    id_bus           NUMBER(10)     NOT NULL,
    id_driver        NUMBER(10)     NOT NULL,
    id_schedule      NUMBER(10),
    CONSTRAINT pk_trip PRIMARY KEY (id_trip),
    CONSTRAINT fk_trip_bus_line FOREIGN KEY (id_line) REFERENCES BUS_LINE (id_line),
    CONSTRAINT fk_trip_bus FOREIGN KEY (id_bus) REFERENCES BUS (id_bus),
    CONSTRAINT fk_trip_driver FOREIGN KEY (id_driver) REFERENCES DRIVER (id_driver),
    CONSTRAINT fk_trip_schedule FOREIGN KEY (id_schedule) REFERENCES SCHEDULE (id_schedule),
    CONSTRAINT chk_trip_status CHECK (status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'DELAYED')),
    CONSTRAINT chk_trip_seats CHECK (available_seats >= 0),
    CONSTRAINT chk_trip_price CHECK (price >= 0),
    CONSTRAINT chk_trip_times CHECK (arrival_time IS NULL OR arrival_time > departure_time)
);

-- Table MAINTENANCE
CREATE TABLE MAINTENANCE (
    id_maintenance NUMBER(10)     NOT NULL,
    type           VARCHAR2(30)   NOT NULL,
    description    VARCHAR2(500),
    scheduled_date DATE           NOT NULL,
    completed_date DATE,
    cost           DECIMAL(8, 2),
    status         VARCHAR2(20)   NOT NULL DEFAULT 'SCHEDULED',
    created_at     TIMESTAMP DEFAULT SYSTIMESTAMP,
    id_bus         NUMBER(10)     NOT NULL,
    CONSTRAINT pk_maintenance PRIMARY KEY (id_maintenance),
    CONSTRAINT fk_maintenance_bus FOREIGN KEY (id_bus) REFERENCES BUS (id_bus) ON DELETE CASCADE,
    CONSTRAINT chk_maintenance_status CHECK (status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT chk_maintenance_type CHECK (type IN ('PREVENTIVE', 'CORRECTIVE', 'REVISION', 'INSPECTION', 'REPAIR')),
    CONSTRAINT chk_maintenance_cost CHECK (cost IS NULL OR cost >= 0),
    CONSTRAINT chk_maintenance_dates CHECK (completed_date IS NULL OR completed_date >= scheduled_date)
);

-- Table INCIDENT
CREATE TABLE INCIDENT (
    id_incident      NUMBER(10)     NOT NULL,
    type             VARCHAR2(30)   NOT NULL,
    description      VARCHAR2(500),
    severity         VARCHAR2(20)   NOT NULL,
    resolved_date    TIMESTAMP,
    status           VARCHAR2(20)   NOT NULL DEFAULT 'OPEN',
    created_at       TIMESTAMP DEFAULT SYSTIMESTAMP,
    id_trip          NUMBER(10)     NOT NULL,
    id_bus           NUMBER(10),
    id_driver        NUMBER(10),
    CONSTRAINT pk_incident PRIMARY KEY (id_incident),
    CONSTRAINT fk_incident_trip FOREIGN KEY (id_trip) REFERENCES TRIP (id_trip),
    CONSTRAINT fk_incident_bus FOREIGN KEY (id_bus) REFERENCES BUS (id_bus),
    CONSTRAINT fk_incident_driver FOREIGN KEY (id_driver) REFERENCES DRIVER (id_driver),
    CONSTRAINT chk_incident_severity CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_incident_status CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    CONSTRAINT chk_incident_type CHECK (type IN ('MECHANICAL', 'ACCIDENT', 'DELAY', 'BREAKDOWN', 'OTHER'))
);

-- Table TICKET
CREATE TABLE TICKET (
    id_ticket             NUMBER(10)     NOT NULL,
    ticket_number         VARCHAR2(50)   NOT NULL,
    ticket_type           VARCHAR2(30)   NOT NULL,
    price                 DECIMAL(8, 2)  NOT NULL,
    issue_date            TIMESTAMP      NOT NULL DEFAULT SYSTIMESTAMP,
    ticket_status         VARCHAR2(20)   NOT NULL DEFAULT 'VALID',
    id_trip               NUMBER(10)     NOT NULL,
    id_boarding_station   NUMBER(10)     NOT NULL,
    id_alighting_station  NUMBER(10)     NOT NULL,
    CONSTRAINT pk_ticket PRIMARY KEY (id_ticket),
    CONSTRAINT uk_ticket_number UNIQUE (ticket_number),
    CONSTRAINT fk_ticket_trip FOREIGN KEY (id_trip) REFERENCES TRIP (id_trip),
    CONSTRAINT fk_ticket_boarding FOREIGN KEY (id_boarding_station) REFERENCES STATION (id_station),
    CONSTRAINT fk_ticket_alighting FOREIGN KEY (id_alighting_station) REFERENCES STATION (id_station),
    CONSTRAINT chk_ticket_type CHECK (ticket_type IN ('STANDARD', 'STUDENT', 'SENIOR', 'CHILD')),
    CONSTRAINT chk_ticket_status CHECK (ticket_status IN ('VALID', 'USED', 'CANCELLED', 'REFUNDED')),
    CONSTRAINT chk_ticket_price CHECK (price >= 0),
    CONSTRAINT chk_ticket_stations CHECK (id_boarding_station != id_alighting_station)
);

-- Table SUBSCRIPTION
CREATE TABLE SUBSCRIPTION (
    id_subscription NUMBER(10)     NOT NULL,
    user_name       VARCHAR2(100)  NOT NULL,
    user_email      VARCHAR2(100),
    start_date      DATE           NOT NULL,
    end_date        DATE           NOT NULL,
    price           DECIMAL(8, 2)  NOT NULL,
    status          VARCHAR2(20)   NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    id_line         NUMBER(10),
    CONSTRAINT pk_subscription PRIMARY KEY (id_subscription),
    CONSTRAINT fk_subscription_bus_line FOREIGN KEY (id_line) REFERENCES BUS_LINE (id_line),
    CONSTRAINT chk_subscription_status CHECK (status IN ('ACTIVE', 'EXPIRED', 'CANCELLED', 'SUSPENDED')),
    CONSTRAINT chk_subscription_price CHECK (price >= 0),
    CONSTRAINT chk_subscription_dates CHECK (end_date > start_date),
    CONSTRAINT chk_subscription_email CHECK (user_email IS NULL OR user_email LIKE '%@%.%')
);

-- ============================================================================
-- SECTION 3 : CRÉATION DES SÉQUENCES
-- ============================================================================

CREATE SEQUENCE SEQ_CITY START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_BUS START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_DRIVER START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_BUS_LINE START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_STATION START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_SCHEDULE START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_TRIP START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_MAINTENANCE START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_INCIDENT START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_TICKET START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_SUBSCRIPTION START WITH 1 INCREMENT BY 1 NOCACHE;

-- ============================================================================
-- SECTION 4 : CRÉATION DES INDEX OPTIMISÉS
-- ============================================================================

-- Index pour les clés étrangères
CREATE INDEX idx_station_city ON STATION(id_city);
CREATE INDEX idx_line_station_line ON LINE_STATION(id_line);
CREATE INDEX idx_line_station_station ON LINE_STATION(id_station);
CREATE INDEX idx_schedule_line ON SCHEDULE(id_line);
CREATE INDEX idx_schedule_stop_schedule ON SCHEDULE_STOP(id_schedule);
CREATE INDEX idx_schedule_stop_station ON SCHEDULE_STOP(id_station);
CREATE INDEX idx_trip_line ON TRIP(id_line);
CREATE INDEX idx_trip_bus ON TRIP(id_bus);
CREATE INDEX idx_trip_driver ON TRIP(id_driver);
CREATE INDEX idx_trip_schedule ON TRIP(id_schedule);
CREATE INDEX idx_ticket_trip ON TICKET(id_trip);
CREATE INDEX idx_ticket_boarding ON TICKET(id_boarding_station);
CREATE INDEX idx_ticket_alighting ON TICKET(id_alighting_station);
CREATE INDEX idx_maintenance_bus ON MAINTENANCE(id_bus);
CREATE INDEX idx_incident_trip ON INCIDENT(id_trip);
CREATE INDEX idx_incident_bus ON INCIDENT(id_bus);
CREATE INDEX idx_incident_driver ON INCIDENT(id_driver);
CREATE INDEX idx_subscription_line ON SUBSCRIPTION(id_line);

-- Index pour les recherches fréquentes
CREATE INDEX idx_trip_departure ON TRIP(departure_time);
CREATE INDEX idx_trip_status ON TRIP(status);
CREATE INDEX idx_bus_status ON BUS(status);
CREATE INDEX idx_driver_status ON DRIVER(status);
CREATE INDEX idx_driver_license_expiry ON DRIVER(license_expiry);
CREATE INDEX idx_maintenance_status ON MAINTENANCE(status);
CREATE INDEX idx_maintenance_scheduled ON MAINTENANCE(scheduled_date);
CREATE INDEX idx_incident_status ON INCIDENT(status);
CREATE INDEX idx_incident_severity ON INCIDENT(severity);
CREATE INDEX idx_ticket_status ON TICKET(ticket_status);
CREATE INDEX idx_subscription_status ON SUBSCRIPTION(status);
CREATE INDEX idx_subscription_dates ON SUBSCRIPTION(start_date, end_date);

-- Index composites pour les recherches complexes
CREATE INDEX idx_trip_bus_date ON TRIP(id_bus, departure_time);
CREATE INDEX idx_trip_driver_date ON TRIP(id_driver, departure_time);
CREATE INDEX idx_line_station_order ON LINE_STATION(id_line, stop_order);

-- ============================================================================
-- SECTION 5 : CRÉATION DES RÔLES
-- ============================================================================

-- Rôle ADMIN - Accès complet
CREATE ROLE BUS_ADMIN_ROLE;

-- Rôle MANAGER - Gestion opérationnelle
CREATE ROLE BUS_MANAGER_ROLE;

-- Rôle CHAUFFEUR - Consultation et signalement
CREATE ROLE BUS_CHAUFFEUR_ROLE;

-- Rôle MAINTENANCE - Gestion de la flotte
CREATE ROLE BUS_MAINTENANCE_ROLE;

-- Rôle COMMERCIAL - Billetterie et abonnements
CREATE ROLE BUS_COMMERCIAL_ROLE;

-- Rôle ANALYSTE - Consultation uniquement
CREATE ROLE BUS_ANALYSTE_ROLE;

-- ============================================================================
-- SECTION 6 : ATTRIBUTION DES PRIVILÈGES AUX RÔLES (CONFORME PRÉSENTATION)
-- ============================================================================

-- ================================
-- RÔLE ADMIN - Accès complet
-- ================================
GRANT CONNECT, RESOURCE TO BUS_ADMIN_ROLE;
GRANT CREATE SESSION TO BUS_ADMIN_ROLE;
GRANT CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER, CREATE SEQUENCE TO BUS_ADMIN_ROLE;

-- Privilèges sur toutes les tables
GRANT ALL PRIVILEGES ON CITY TO BUS_ADMIN_ROLE;
GRANT ALL PRIVILEGES ON BUS TO BUS_ADMIN_ROLE;
GRANT ALL PRIVILEGES ON DRIVER TO BUS_ADMIN_ROLE;
GRANT ALL PRIVILEGES ON BUS_LINE TO BUS_ADMIN_ROLE;
GRANT ALL PRIVILEGES ON STATION TO BUS_ADMIN_ROLE;
GRANT ALL PRIVILEGES ON LINE_STATION TO BUS_ADMIN_ROLE;
GRANT ALL PRIVILEGES ON SCHEDULE TO BUS_ADMIN_ROLE;
GRANT ALL PRIVILEGES ON SCHEDULE_STOP TO BUS_ADMIN_ROLE;
GRANT ALL PRIVILEGES ON TRIP TO BUS_ADMIN_ROLE;
GRANT ALL PRIVILEGES ON MAINTENANCE TO BUS_ADMIN_ROLE;
GRANT ALL PRIVILEGES ON INCIDENT TO BUS_ADMIN_ROLE;
GRANT ALL PRIVILEGES ON TICKET TO BUS_ADMIN_ROLE;
GRANT ALL PRIVILEGES ON SUBSCRIPTION TO BUS_ADMIN_ROLE;

-- Privilèges sur les séquences
GRANT SELECT, ALTER ON SEQ_CITY TO BUS_ADMIN_ROLE;
GRANT SELECT, ALTER ON SEQ_BUS TO BUS_ADMIN_ROLE;
GRANT SELECT, ALTER ON SEQ_DRIVER TO BUS_ADMIN_ROLE;
GRANT SELECT, ALTER ON SEQ_BUS_LINE TO BUS_ADMIN_ROLE;
GRANT SELECT, ALTER ON SEQ_STATION TO BUS_ADMIN_ROLE;
GRANT SELECT, ALTER ON SEQ_SCHEDULE TO BUS_ADMIN_ROLE;
GRANT SELECT, ALTER ON SEQ_TRIP TO BUS_ADMIN_ROLE;
GRANT SELECT, ALTER ON SEQ_MAINTENANCE TO BUS_ADMIN_ROLE;
GRANT SELECT, ALTER ON SEQ_INCIDENT TO BUS_ADMIN_ROLE;
GRANT SELECT, ALTER ON SEQ_TICKET TO BUS_ADMIN_ROLE;
GRANT SELECT, ALTER ON SEQ_SUBSCRIPTION TO BUS_ADMIN_ROLE;

-- ================================
-- RÔLE MANAGER - Gestion opérationnelle
-- ================================
GRANT CONNECT TO BUS_MANAGER_ROLE;
GRANT CREATE SESSION TO BUS_MANAGER_ROLE;

-- Gestion complète (SELECT, INSERT, UPDATE, DELETE)
GRANT SELECT, INSERT, UPDATE, DELETE ON BUS_LINE TO BUS_MANAGER_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON TRIP TO BUS_MANAGER_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON DRIVER TO BUS_MANAGER_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON INCIDENT TO BUS_MANAGER_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON STATION TO BUS_MANAGER_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON MAINTENANCE TO BUS_MANAGER_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEDULE TO BUS_MANAGER_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEDULE_STOP TO BUS_MANAGER_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON LINE_STATION TO BUS_MANAGER_ROLE;

-- Lecture seule
GRANT SELECT ON CITY TO BUS_MANAGER_ROLE;
GRANT SELECT ON TICKET TO BUS_MANAGER_ROLE;
GRANT SELECT ON SUBSCRIPTION TO BUS_MANAGER_ROLE;

-- Modification limitée sur BUS (statut uniquement)
GRANT SELECT ON BUS TO BUS_MANAGER_ROLE;
GRANT UPDATE(status) ON BUS TO BUS_MANAGER_ROLE;

-- Accès aux séquences nécessaires
GRANT SELECT ON SEQ_BUS_LINE TO BUS_MANAGER_ROLE;
GRANT SELECT ON SEQ_TRIP TO BUS_MANAGER_ROLE;
GRANT SELECT ON SEQ_DRIVER TO BUS_MANAGER_ROLE;
GRANT SELECT ON SEQ_STATION TO BUS_MANAGER_ROLE;
GRANT SELECT ON SEQ_SCHEDULE TO BUS_MANAGER_ROLE;
GRANT SELECT ON SEQ_MAINTENANCE TO BUS_MANAGER_ROLE;
GRANT SELECT ON SEQ_INCIDENT TO BUS_MANAGER_ROLE;

-- ================================
-- RÔLE CHAUFFEUR - Consultation et signalement
-- ================================
GRANT CONNECT TO BUS_CHAUFFEUR_ROLE;
GRANT CREATE SESSION TO BUS_CHAUFFEUR_ROLE;

-- Consultation infrastructure
GRANT SELECT ON BUS_LINE TO BUS_CHAUFFEUR_ROLE;
GRANT SELECT ON STATION TO BUS_CHAUFFEUR_ROLE;
GRANT SELECT ON SCHEDULE TO BUS_CHAUFFEUR_ROLE;
GRANT SELECT ON SCHEDULE_STOP TO BUS_CHAUFFEUR_ROLE;
GRANT SELECT ON LINE_STATION TO BUS_CHAUFFEUR_ROLE;

-- Ses propres trajets (nécessitera une politique VPD/RLS)
GRANT SELECT ON TRIP TO BUS_CHAUFFEUR_ROLE;
GRANT UPDATE(status) ON TRIP TO BUS_CHAUFFEUR_ROLE;

-- Signalement d'incidents
GRANT INSERT ON INCIDENT TO BUS_CHAUFFEUR_ROLE;
GRANT SELECT ON INCIDENT TO BUS_CHAUFFEUR_ROLE;
GRANT SELECT ON SEQ_INCIDENT TO BUS_CHAUFFEUR_ROLE;

-- ================================
-- RÔLE MAINTENANCE - Gestion de la flotte
-- ================================
GRANT CONNECT TO BUS_MAINTENANCE_ROLE;
GRANT CREATE SESSION TO BUS_MAINTENANCE_ROLE;

-- Gestion complète de la flotte
GRANT SELECT, INSERT, UPDATE, DELETE ON BUS TO BUS_MAINTENANCE_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON MAINTENANCE TO BUS_MAINTENANCE_ROLE;

-- Gestion des incidents (UPDATE, DELETE)
GRANT SELECT, UPDATE, DELETE ON INCIDENT TO BUS_MAINTENANCE_ROLE;

-- Consultation des trajets
GRANT SELECT ON TRIP TO BUS_MAINTENANCE_ROLE;

-- Accès aux séquences
GRANT SELECT ON SEQ_BUS TO BUS_MAINTENANCE_ROLE;
GRANT SELECT ON SEQ_MAINTENANCE TO BUS_MAINTENANCE_ROLE;

-- ================================
-- RÔLE COMMERCIAL - Billetterie et abonnements
-- ================================
GRANT CONNECT TO BUS_COMMERCIAL_ROLE;
GRANT CREATE SESSION TO BUS_COMMERCIAL_ROLE;

-- Gestion billetterie complète
GRANT SELECT, INSERT, UPDATE, DELETE ON TICKET TO BUS_COMMERCIAL_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON SUBSCRIPTION TO BUS_COMMERCIAL_ROLE;

-- Modification des tarifs de voyage
GRANT SELECT ON TRIP TO BUS_COMMERCIAL_ROLE;
GRANT UPDATE(price) ON TRIP TO BUS_COMMERCIAL_ROLE;

-- Consultation infrastructure
GRANT SELECT ON CITY TO BUS_COMMERCIAL_ROLE;
GRANT SELECT ON STATION TO BUS_COMMERCIAL_ROLE;
GRANT SELECT ON BUS_LINE TO BUS_COMMERCIAL_ROLE;
GRANT SELECT ON LINE_STATION TO BUS_COMMERCIAL_ROLE;
GRANT SELECT ON SCHEDULE TO BUS_COMMERCIAL_ROLE;
GRANT SELECT ON SCHEDULE_STOP TO BUS_COMMERCIAL_ROLE;

-- Accès aux séquences
GRANT SELECT ON SEQ_TICKET TO BUS_COMMERCIAL_ROLE;
GRANT SELECT ON SEQ_SUBSCRIPTION TO BUS_COMMERCIAL_ROLE;

-- ================================
-- RÔLE ANALYSTE - Lecture seule (Read-only)
-- ================================
GRANT CONNECT TO BUS_ANALYSTE_ROLE;
GRANT CREATE SESSION TO BUS_ANALYSTE_ROLE;

-- Consultation de toutes les tables (SELECT uniquement)
GRANT SELECT ON CITY TO BUS_ANALYSTE_ROLE;
GRANT SELECT ON BUS TO BUS_ANALYSTE_ROLE;
GRANT SELECT ON DRIVER TO BUS_ANALYSTE_ROLE;
GRANT SELECT ON BUS_LINE TO BUS_ANALYSTE_ROLE;
GRANT SELECT ON STATION TO BUS_ANALYSTE_ROLE;
GRANT SELECT ON LINE_STATION TO BUS_ANALYSTE_ROLE;
GRANT SELECT ON SCHEDULE TO BUS_ANALYSTE_ROLE;
GRANT SELECT ON SCHEDULE_STOP TO BUS_ANALYSTE_ROLE;
GRANT SELECT ON TRIP TO BUS_ANALYSTE_ROLE;
GRANT SELECT ON MAINTENANCE TO BUS_ANALYSTE_ROLE;
GRANT SELECT ON INCIDENT TO BUS_ANALYSTE_ROLE;
GRANT SELECT ON TICKET TO BUS_ANALYSTE_ROLE;
GRANT SELECT ON SUBSCRIPTION TO BUS_ANALYSTE_ROLE;

-- ============================================================================
-- SECTION 7 : CRÉATION DES UTILISATEURS AVEC QUOTAS
-- ============================================================================

-- ================================
-- Utilisateur ADMIN - Quota illimité
-- ================================
CREATE USER bus_admin IDENTIFIED BY Admin2025!
DEFAULT TABLESPACE BUS_DATA
TEMPORARY TABLESPACE BUS_TEMP
QUOTA UNLIMITED ON BUS_DATA;

GRANT BUS_ADMIN_ROLE TO bus_admin;
ALTER USER bus_admin ACCOUNT UNLOCK;

-- ================================
-- Utilisateur MANAGER - Quota 500M
-- ================================
CREATE USER bus_manager1 IDENTIFIED BY Manager2025!
DEFAULT TABLESPACE BUS_DATA
TEMPORARY TABLESPACE BUS_TEMP
QUOTA 500M ON BUS_DATA;

GRANT BUS_MANAGER_ROLE TO bus_manager1;
ALTER USER bus_manager1 ACCOUNT UNLOCK;

-- ================================
-- Utilisateurs CHAUFFEUR - Quota 50M
-- ================================
CREATE USER chauffeur1 IDENTIFIED BY Chauffeur2025!
DEFAULT TABLESPACE BUS_DATA
TEMPORARY TABLESPACE BUS_TEMP
QUOTA 50M ON BUS_DATA;

GRANT BUS_CHAUFFEUR_ROLE TO chauffeur1;
ALTER USER chauffeur1 ACCOUNT UNLOCK;

CREATE USER chauffeur2 IDENTIFIED BY Chauffeur2025!
DEFAULT TABLESPACE BUS_DATA
TEMPORARY TABLESPACE BUS_TEMP
QUOTA 50M ON BUS_DATA;

GRANT BUS_CHAUFFEUR_ROLE TO chauffeur2;
ALTER USER chauffeur2 ACCOUNT UNLOCK;

-- ================================
-- Utilisateur MAINTENANCE - Quota 200M
-- ================================
CREATE USER bus_maintenance IDENTIFIED BY Maintenance2025!
DEFAULT TABLESPACE BUS_DATA
TEMPORARY TABLESPACE BUS_TEMP
QUOTA 200M ON BUS_DATA;

GRANT BUS_MAINTENANCE_ROLE TO bus_maintenance;
ALTER USER bus_maintenance ACCOUNT UNLOCK;

-- ================================
-- Utilisateur COMMERCIAL - Quota 300M
-- ================================
CREATE USER bus_commercial IDENTIFIED BY Commercial2025!
DEFAULT TABLESPACE BUS_DATA
TEMPORARY TABLESPACE BUS_TEMP
QUOTA 300M ON BUS_DATA;

GRANT BUS_COMMERCIAL_ROLE TO bus_commercial;
ALTER USER bus_commercial ACCOUNT UNLOCK;

-- ================================
-- Utilisateur ANALYSTE - Quota 100M
-- ================================
CREATE USER bus_analyste IDENTIFIED BY Analyste2025!
DEFAULT TABLESPACE BUS_DATA
TEMPORARY TABLESPACE BUS_TEMP
QUOTA 100M ON BUS_DATA;

GRANT BUS_ANALYSTE_ROLE TO bus_analyste;
ALTER USER bus_analyste ACCOUNT UNLOCK;

-- ============================================================================
-- SECTION 8 : MESURES DE SÉCURITÉ (CONFORME PRÉSENTATION)
-- ============================================================================

-- ================================
-- Audit des connexions
-- ================================
AUDIT SESSION BY bus_admin;
AUDIT SESSION BY bus_manager1;
AUDIT SESSION BY bus_maintenance;
AUDIT SESSION BY bus_commercial;
