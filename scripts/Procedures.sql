-- ============================================================================
-- SECTION 1 : PROCÉDURES CRUD (39 procédures au total)
-- ============================================================================

-- ============================================
-- PROCÉDURES CRUD - TABLE CITY
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_CITY(
    p_name IN VARCHAR2,
    p_region IN VARCHAR2,
    p_postal_code IN VARCHAR2,
    p_country IN VARCHAR2
) AS
BEGIN
    INSERT INTO CITY (id_city, name, region, postal_code, country)
    VALUES (SEQ_CITY.NEXTVAL, p_name, p_region, p_postal_code, p_country);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Erreur insertion ville: ' || SQLERRM);
END INSERT_CITY;
/

CREATE OR REPLACE PROCEDURE UPDATE_CITY(
    p_id_city IN NUMBER,
    p_name IN VARCHAR2,
    p_region IN VARCHAR2,
    p_postal_code IN VARCHAR2,
    p_country IN VARCHAR2
) AS
BEGIN
    UPDATE CITY
    SET name = p_name,
        region = p_region,
        postal_code = p_postal_code,
        country = p_country
    WHERE id_city = p_id_city;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Erreur mise à jour ville: ' || SQLERRM);
END UPDATE_CITY;
/

CREATE OR REPLACE PROCEDURE DELETE_CITY(
    p_id_city IN NUMBER
) AS
BEGIN
    DELETE FROM CITY WHERE id_city = p_id_city;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Erreur suppression ville: ' || SQLERRM);
END DELETE_CITY;
/

-- ============================================
-- PROCÉDURES CRUD - TABLE BUS
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_BUS(
    p_plate_number IN VARCHAR2,
    p_model IN VARCHAR2,
    p_capacity IN NUMBER,
    p_year IN NUMBER
) AS
BEGIN
    INSERT INTO BUS (id_bus, plate_number, model, capacity, year, status)
    VALUES (SEQ_BUS.NEXTVAL, p_plate_number, p_model, p_capacity, p_year, 'AVAILABLE');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, 'Erreur insertion bus: ' || SQLERRM);
END INSERT_BUS;
/

CREATE OR REPLACE PROCEDURE UPDATE_BUS(
    p_id_bus IN NUMBER,
    p_plate_number IN VARCHAR2,
    p_model IN VARCHAR2,
    p_capacity IN NUMBER,
    p_year IN NUMBER,
    p_status IN VARCHAR2
) AS
BEGIN
    UPDATE BUS
    SET plate_number = p_plate_number,
        model = p_model,
        capacity = p_capacity,
        year = p_year,
        status = p_status
    WHERE id_bus = p_id_bus;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20005, 'Erreur mise à jour bus: ' || SQLERRM);
END UPDATE_BUS;
/

CREATE OR REPLACE PROCEDURE DELETE_BUS(
    p_id_bus IN NUMBER
) AS
BEGIN
    DELETE FROM BUS WHERE id_bus = p_id_bus;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20006, 'Erreur suppression bus: ' || SQLERRM);
END DELETE_BUS;
/

-- ============================================
-- PROCÉDURES CRUD - TABLE DRIVER
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_DRIVER(
    p_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_phone IN VARCHAR2,
    p_license_number IN VARCHAR2,
    p_license_expiry IN DATE
) AS
BEGIN
    INSERT INTO DRIVER (id_driver, name, email, phone, license_number, license_expiry, status)
    VALUES (SEQ_DRIVER.NEXTVAL, p_name, p_email, p_phone, p_license_number, p_license_expiry, 'ACTIVE');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20007, 'Erreur insertion chauffeur: ' || SQLERRM);
END INSERT_DRIVER;
/

CREATE OR REPLACE PROCEDURE UPDATE_DRIVER(
    p_id_driver IN NUMBER,
    p_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_phone IN VARCHAR2,
    p_license_number IN VARCHAR2,
    p_license_expiry IN DATE,
    p_status IN VARCHAR2
) AS
BEGIN
    UPDATE DRIVER
    SET name = p_name,
        email = p_email,
        phone = p_phone,
        license_number = p_license_number,
        license_expiry = p_license_expiry,
        status = p_status
    WHERE id_driver = p_id_driver;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20008, 'Erreur mise à jour chauffeur: ' || SQLERRM);
END UPDATE_DRIVER;
/

CREATE OR REPLACE PROCEDURE DELETE_DRIVER(
    p_id_driver IN NUMBER
) AS
BEGIN
    DELETE FROM DRIVER WHERE id_driver = p_id_driver;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20009, 'Erreur suppression chauffeur: ' || SQLERRM);
END DELETE_DRIVER;
/

-- ============================================
-- PROCÉDURES CRUD - TABLE BUS_LINE
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_BUS_LINE(
    p_name IN VARCHAR2,
    p_code IN VARCHAR2,
    p_duration_minutes IN NUMBER
) AS
BEGIN
    INSERT INTO BUS_LINE (id_line, name, code, duration_minutes, status)
    VALUES (SEQ_BUS_LINE.NEXTVAL, p_name, p_code, p_duration_minutes, 'ACTIVE');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20010, 'Erreur insertion ligne: ' || SQLERRM);
END INSERT_BUS_LINE;
/

CREATE OR REPLACE PROCEDURE UPDATE_BUS_LINE(
    p_id_line IN NUMBER,
    p_name IN VARCHAR2,
    p_code IN VARCHAR2,
    p_duration_minutes IN NUMBER,
    p_status IN VARCHAR2
) AS
BEGIN
    UPDATE BUS_LINE
    SET name = p_name,
        code = p_code,
        duration_minutes = p_duration_minutes,
        status = p_status
    WHERE id_line = p_id_line;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'Erreur mise à jour ligne: ' || SQLERRM);
END UPDATE_BUS_LINE;
/

CREATE OR REPLACE PROCEDURE DELETE_BUS_LINE(
    p_id_line IN NUMBER
) AS
BEGIN
    DELETE FROM BUS_LINE WHERE id_line = p_id_line;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20012, 'Erreur suppression ligne: ' || SQLERRM);
END DELETE_BUS_LINE;
/

-- ============================================
-- PROCÉDURES CRUD - TABLE STATION
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_STATION(
    p_name IN VARCHAR2,
    p_address IN VARCHAR2,
    p_latitude IN DECIMAL,
    p_longitude IN DECIMAL,
    p_id_city IN NUMBER
) AS
BEGIN
    INSERT INTO STATION (id_station, name, address, latitude, longitude, id_city)
    VALUES (SEQ_STATION.NEXTVAL, p_name, p_address, p_latitude, p_longitude, p_id_city);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20013, 'Erreur insertion station: ' || SQLERRM);
END INSERT_STATION;
/

CREATE OR REPLACE PROCEDURE UPDATE_STATION(
    p_id_station IN NUMBER,
    p_name IN VARCHAR2,
    p_address IN VARCHAR2,
    p_latitude IN DECIMAL,
    p_longitude IN DECIMAL,
    p_id_city IN NUMBER
) AS
BEGIN
    UPDATE STATION
    SET name = p_name,
        address = p_address,
        latitude = p_latitude,
        longitude = p_longitude,
        id_city = p_id_city
    WHERE id_station = p_id_station;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20014, 'Erreur mise à jour station: ' || SQLERRM);
END UPDATE_STATION;
/

CREATE OR REPLACE PROCEDURE DELETE_STATION(
    p_id_station IN NUMBER
) AS
BEGIN
    DELETE FROM STATION WHERE id_station = p_id_station;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20015, 'Erreur suppression station: ' || SQLERRM);
END DELETE_STATION;
/

-- ============================================
-- PROCÉDURES CRUD - TABLE LINE_STATION
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_LINE_STATION(
    p_id_line IN NUMBER,
    p_id_station IN NUMBER,
    p_stop_order IN NUMBER,
    p_distance_from_start_km IN DECIMAL
) AS
BEGIN
    INSERT INTO LINE_STATION (id_line, id_station, stop_order, distance_from_start_km)
    VALUES (p_id_line, p_id_station, p_stop_order, p_distance_from_start_km);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20016, 'Erreur insertion line_station: ' || SQLERRM);
END INSERT_LINE_STATION;
/

CREATE OR REPLACE PROCEDURE UPDATE_LINE_STATION(
    p_id_line IN NUMBER,
    p_id_station IN NUMBER,
    p_stop_order IN NUMBER,
    p_distance_from_start_km IN DECIMAL
) AS
BEGIN
    UPDATE LINE_STATION
    SET stop_order = p_stop_order,
        distance_from_start_km = p_distance_from_start_km
    WHERE id_line = p_id_line AND id_station = p_id_station;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20017, 'Erreur mise à jour line_station: ' || SQLERRM);
END UPDATE_LINE_STATION;
/

CREATE OR REPLACE PROCEDURE DELETE_LINE_STATION(
    p_id_line IN NUMBER,
    p_id_station IN NUMBER
) AS
BEGIN
    DELETE FROM LINE_STATION WHERE id_line = p_id_line AND id_station = p_id_station;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20018, 'Erreur suppression line_station: ' || SQLERRM);
END DELETE_LINE_STATION;
/

-- ============================================
-- PROCÉDURES CRUD - TABLE SCHEDULE
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_SCHEDULE(
    p_service_type IN VARCHAR2,
    p_day_of_week IN VARCHAR2,
    p_frequency_min IN NUMBER,
    p_id_line IN NUMBER
) AS
BEGIN
    INSERT INTO SCHEDULE (id_schedule, service_type, day_of_week, frequency_min, id_line)
    VALUES (SEQ_SCHEDULE.NEXTVAL, p_service_type, p_day_of_week, p_frequency_min, p_id_line);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20019, 'Erreur insertion schedule: ' || SQLERRM);
END INSERT_SCHEDULE;
/

CREATE OR REPLACE PROCEDURE UPDATE_SCHEDULE(
    p_id_schedule IN NUMBER,
    p_service_type IN VARCHAR2,
    p_day_of_week IN VARCHAR2,
    p_frequency_min IN NUMBER,
    p_id_line IN NUMBER
) AS
BEGIN
    UPDATE SCHEDULE
    SET service_type = p_service_type,
        day_of_week = p_day_of_week,
        frequency_min = p_frequency_min,
        id_line = p_id_line
    WHERE id_schedule = p_id_schedule;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20020, 'Erreur mise à jour schedule: ' || SQLERRM);
END UPDATE_SCHEDULE;
/

CREATE OR REPLACE PROCEDURE DELETE_SCHEDULE(
    p_id_schedule IN NUMBER
) AS
BEGIN
    DELETE FROM SCHEDULE WHERE id_schedule = p_id_schedule;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20021, 'Erreur suppression schedule: ' || SQLERRM);
END DELETE_SCHEDULE;
/

-- ============================================
-- PROCÉDURES CRUD - TABLE SCHEDULE_STOP
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_SCHEDULE_STOP(
    p_id_schedule IN NUMBER,
    p_id_station IN NUMBER,
    p_scheduled_stop_time IN VARCHAR2
) AS
BEGIN
    INSERT INTO SCHEDULE_STOP (id_schedule, id_station, scheduled_stop_time)
    VALUES (p_id_schedule, p_id_station, p_scheduled_stop_time);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20022, 'Erreur insertion schedule_stop: ' || SQLERRM);
END INSERT_SCHEDULE_STOP;
/

CREATE OR REPLACE PROCEDURE UPDATE_SCHEDULE_STOP(
    p_id_schedule IN NUMBER,
    p_id_station IN NUMBER,
    p_scheduled_stop_time IN VARCHAR2
) AS
BEGIN
    UPDATE SCHEDULE_STOP
    SET scheduled_stop_time = p_scheduled_stop_time
    WHERE id_schedule = p_id_schedule AND id_station = p_id_station;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20023, 'Erreur mise à jour schedule_stop: ' || SQLERRM);
END UPDATE_SCHEDULE_STOP;
/

CREATE OR REPLACE PROCEDURE DELETE_SCHEDULE_STOP(
    p_id_schedule IN NUMBER,
    p_id_station IN NUMBER
) AS
BEGIN
    DELETE FROM SCHEDULE_STOP WHERE id_schedule = p_id_schedule AND id_station = p_id_station;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20024, 'Erreur suppression schedule_stop: ' || SQLERRM);
END DELETE_SCHEDULE_STOP;
/

-- ============================================
-- PROCÉDURES CRUD - TABLE TRIP
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_TRIP(
    p_departure_time IN TIMESTAMP,
    p_arrival_time IN TIMESTAMP,
    p_available_seats IN NUMBER,
    p_price IN DECIMAL,
    p_id_line IN NUMBER,
    p_id_bus IN NUMBER,
    p_id_driver IN NUMBER,
    p_id_schedule IN NUMBER
) AS
BEGIN
    INSERT INTO TRIP (id_trip, departure_time, arrival_time, status, available_seats, price, id_line, id_bus, id_driver, id_schedule)
    VALUES (SEQ_TRIP.NEXTVAL, p_departure_time, p_arrival_time, 'SCHEDULED', p_available_seats, p_price, p_id_line, p_id_bus, p_id_driver, p_id_schedule);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20025, 'Erreur insertion trip: ' || SQLERRM);
END INSERT_TRIP;
/

CREATE OR REPLACE PROCEDURE UPDATE_TRIP(
    p_id_trip IN NUMBER,
    p_departure_time IN TIMESTAMP,
    p_arrival_time IN TIMESTAMP,
    p_status IN VARCHAR2,
    p_available_seats IN NUMBER,
    p_price IN DECIMAL
) AS
BEGIN
    UPDATE TRIP
    SET departure_time = p_departure_time,
        arrival_time = p_arrival_time,
        status = p_status,
        available_seats = p_available_seats,
        price = p_price
    WHERE id_trip = p_id_trip;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20026, 'Erreur mise à jour trip: ' || SQLERRM);
END UPDATE_TRIP;
/

CREATE OR REPLACE PROCEDURE DELETE_TRIP(
    p_id_trip IN NUMBER
) AS
BEGIN
    DELETE FROM TRIP WHERE id_trip = p_id_trip;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20027, 'Erreur suppression trip: ' || SQLERRM);
END DELETE_TRIP;
/

-- ============================================
-- PROCÉDURES CRUD - TABLE MAINTENANCE
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_MAINTENANCE(
    p_type IN VARCHAR2,
    p_description IN VARCHAR2,
    p_scheduled_date IN DATE,
    p_cost IN DECIMAL,
    p_id_bus IN NUMBER
) AS
BEGIN
    INSERT INTO MAINTENANCE (id_maintenance, type, description, scheduled_date, cost, status, id_bus)
    VALUES (SEQ_MAINTENANCE.NEXTVAL, p_type, p_description, p_scheduled_date, p_cost, 'SCHEDULED', p_id_bus);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20028, 'Erreur insertion maintenance: ' || SQLERRM);
END INSERT_MAINTENANCE;
/

CREATE OR REPLACE PROCEDURE UPDATE_MAINTENANCE(
    p_id_maintenance IN NUMBER,
    p_type IN VARCHAR2,
    p_description IN VARCHAR2,
    p_scheduled_date IN DATE,
    p_completed_date IN DATE,
    p_cost IN DECIMAL,
    p_status IN VARCHAR2
) AS
BEGIN
    UPDATE MAINTENANCE
    SET type = p_type,
        description = p_description,
        scheduled_date = p_scheduled_date,
        completed_date = p_completed_date,
        cost = p_cost,
        status = p_status
    WHERE id_maintenance = p_id_maintenance;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20029, 'Erreur mise à jour maintenance: ' || SQLERRM);
END UPDATE_MAINTENANCE;
/

CREATE OR REPLACE PROCEDURE DELETE_MAINTENANCE(
    p_id_maintenance IN NUMBER
) AS
BEGIN
    DELETE FROM MAINTENANCE WHERE id_maintenance = p_id_maintenance;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20030, 'Erreur suppression maintenance: ' || SQLERRM);
END DELETE_MAINTENANCE;
/

-- ============================================
-- PROCÉDURES CRUD - TABLE INCIDENT
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_INCIDENT(
    p_type IN VARCHAR2,
    p_description IN VARCHAR2,
    p_severity IN VARCHAR2,
    p_id_trip IN NUMBER,
    p_id_bus IN NUMBER,
    p_id_driver IN NUMBER
) AS
BEGIN
    INSERT INTO INCIDENT (id_incident, type, description, severity, status, id_trip, id_bus, id_driver)
    VALUES (SEQ_INCIDENT.NEXTVAL, p_type, p_description, p_severity, 'OPEN', p_id_trip, p_id_bus, p_id_driver);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20031, 'Erreur insertion incident: ' || SQLERRM);
END INSERT_INCIDENT;
/

CREATE OR REPLACE PROCEDURE UPDATE_INCIDENT(
    p_id_incident IN NUMBER,
    p_type IN VARCHAR2,
    p_description IN VARCHAR2,
    p_severity IN VARCHAR2,
    p_status IN VARCHAR2,
    p_resolved_date IN TIMESTAMP
) AS
BEGIN
    UPDATE INCIDENT
    SET type = p_type,
        description = p_description,
        severity = p_severity,
        status = p_status,
        resolved_date = p_resolved_date
    WHERE id_incident = p_id_incident;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20032, 'Erreur mise à jour incident: ' || SQLERRM);
END UPDATE_INCIDENT;
/

CREATE OR REPLACE PROCEDURE DELETE_INCIDENT(
    p_id_incident IN NUMBER
) AS
BEGIN
    DELETE FROM INCIDENT WHERE id_incident = p_id_incident;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20033, 'Erreur suppression incident: ' || SQLERRM);
END DELETE_INCIDENT;
/

-- ============================================
-- PROCÉDURES CRUD - TABLE TICKET
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_TICKET(
    p_ticket_number IN VARCHAR2,
    p_ticket_type IN VARCHAR2,
    p_price IN DECIMAL,
    p_id_trip IN NUMBER,
    p_id_boarding_station IN NUMBER,
    p_id_alighting_station IN NUMBER
) AS
BEGIN
    INSERT INTO TICKET (id_ticket, ticket_number, ticket_type, price, issue_date, ticket_status, id_trip, id_boarding_station, id_alighting_station)
    VALUES (SEQ_TICKET.NEXTVAL, p_ticket_number, p_ticket_type, p_price, SYSTIMESTAMP, 'VALID', p_id_trip, p_id_boarding_station, p_id_alighting_station);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20034, 'Erreur insertion ticket: ' || SQLERRM);
END INSERT_TICKET;
/

CREATE OR REPLACE PROCEDURE UPDATE_TICKET(
    p_id_ticket IN NUMBER,
    p_ticket_type IN VARCHAR2,
    p_price IN DECIMAL,
    p_ticket_status IN VARCHAR2
) AS
BEGIN
    UPDATE TICKET
    SET ticket_type = p_ticket_type,
        price = p_price,
        ticket_status = p_ticket_status
    WHERE id_ticket = p_id_ticket;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20035, 'Erreur mise à jour ticket: ' || SQLERRM);
END UPDATE_TICKET;
/

CREATE OR REPLACE PROCEDURE DELETE_TICKET(
    p_id_ticket IN NUMBER
) AS
BEGIN
    DELETE FROM TICKET WHERE id_ticket = p_id_ticket;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20036, 'Erreur suppression ticket: ' || SQLERRM);
END DELETE_TICKET;
/

-- ============================================
-- PROCÉDURES CRUD - TABLE SUBSCRIPTION
-- ============================================

CREATE OR REPLACE PROCEDURE INSERT_SUBSCRIPTION(
    p_user_name IN VARCHAR2,
    p_user_email IN VARCHAR2,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_price IN DECIMAL,
    p_id_line IN NUMBER
) AS
BEGIN
    INSERT INTO SUBSCRIPTION (id_subscription, user_name, user_email, start_date, end_date, price, status, id_line)
    VALUES (SEQ_SUBSCRIPTION.NEXTVAL, p_user_name, p_user_email, p_start_date, p_end_date, p_price, 'ACTIVE', p_id_line);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20037, 'Erreur insertion subscription: ' || SQLERRM);
END INSERT_SUBSCRIPTION;
/

CREATE OR REPLACE PROCEDURE UPDATE_SUBSCRIPTION(
    p_id_subscription IN NUMBER,
    p_user_name IN VARCHAR2,
    p_user_email IN VARCHAR2,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_price IN DECIMAL,
    p_status IN VARCHAR2
) AS
BEGIN
    UPDATE SUBSCRIPTION
    SET user_name = p_user_name,
        user_email = p_user_email,
        start_date = p_start_date,
        end_date = p_end_date,
        price = p_price,
        status = p_status
    WHERE id_subscription = p_id_subscription;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20038, 'Erreur mise à jour subscription: ' || SQLERRM);
END UPDATE_SUBSCRIPTION;
/

CREATE OR REPLACE PROCEDURE DELETE_SUBSCRIPTION(
    p_id_subscription IN NUMBER
) AS
BEGIN
    DELETE FROM SUBSCRIPTION WHERE id_subscription = p_id_subscription;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20039, 'Erreur suppression subscription: ' || SQLERRM);
END DELETE_SUBSCRIPTION;
/

-- ============================================================================
-- SECTION 2 : PROCÉDURES MÉTIER AVANCÉES
-- ============================================================================

-- ============================================
-- GESTION DES VOYAGES
-- ============================================

CREATE OR REPLACE PROCEDURE CREATE_TRIP(
    p_id_line IN NUMBER,
    p_id_bus IN NUMBER,
    p_id_driver IN NUMBER,
    p_departure_time IN TIMESTAMP,
    p_price IN NUMBER,
    p_trip_id OUT NUMBER
) AS
    v_bus_status VARCHAR2(20);
    v_bus_capacity NUMBER;
    v_driver_status VARCHAR2(20);
    v_license_expiry DATE;
BEGIN
    SAVEPOINT before_trip_creation;
    
    -- Vérification disponibilité bus
    SELECT status, capacity INTO v_bus_status, v_bus_capacity
    FROM BUS WHERE id_bus = p_id_bus;
    
    IF v_bus_status != 'AVAILABLE' THEN
        RAISE_APPLICATION_ERROR(-20101, 'Bus non disponible. Statut: ' || v_bus_status);
    END IF;
    
    -- Vérification statut et permis chauffeur
    SELECT status, license_expiry INTO v_driver_status, v_license_expiry
    FROM DRIVER WHERE id_driver = p_id_driver;
    
    IF v_driver_status != 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20102, 'Chauffeur non actif');
    END IF;
    
    IF v_license_expiry < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20103, 'Permis expiré');
    END IF;
    
    -- Création du voyage
    INSERT INTO TRIP (id_trip, departure_time, status, available_seats, price, id_line, id_bus, id_driver)
    VALUES (SEQ_TRIP.NEXTVAL, p_departure_time, 'SCHEDULED', v_bus_capacity, p_price, p_id_line, p_id_bus, p_id_driver)
    RETURNING id_trip INTO p_trip_id;
    
    -- Mise à jour statut ressources
    UPDATE BUS SET status = 'IN_SERVICE' WHERE id_bus = p_id_bus;
    UPDATE DRIVER SET status = 'IN_SERVICE' WHERE id_driver = p_id_driver;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO before_trip_creation;
        RAISE_APPLICATION_ERROR(-20104, 'Ressource introuvable');
    WHEN OTHERS THEN
        ROLLBACK TO before_trip_creation;
        RAISE;
END CREATE_TRIP;
/

CREATE OR REPLACE PROCEDURE UPDATE_TRIP_STATUS(
    p_id_trip IN NUMBER,
    p_new_status IN VARCHAR2
) AS
    v_id_bus NUMBER;
    v_id_driver NUMBER;
BEGIN
    -- Récupération ressources
    SELECT id_bus, id_driver INTO v_id_bus, v_id_driver
    FROM TRIP WHERE id_trip = p_id_trip;
    
    -- Mise à jour statut voyage
    UPDATE TRIP SET status = p_new_status WHERE id_trip = p_id_trip;
    
    -- Si voyage terminé ou annulé, libérer ressources
    IF p_new_status IN ('COMPLETED', 'CANCELLED') THEN
        UPDATE BUS SET status = 'AVAILABLE' WHERE id_bus = v_id_bus;
        UPDATE DRIVER SET status = 'ACTIVE' WHERE id_driver = v_id_driver;
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20105, 'Erreur mise à jour statut: ' || SQLERRM);
END UPDATE_TRIP_STATUS;
/



CREATE OR REPLACE PROCEDURE CANCEL_TRIP(
    p_id_trip IN NUMBER,
    p_reason IN VARCHAR2
) AS
    v_id_bus NUMBER;
    v_id_driver NUMBER;
    v_ticket_count NUMBER;
BEGIN
    SAVEPOINT before_cancel;
    
    -- Récupération ressources
    SELECT id_bus, id_driver INTO v_id_bus, v_id_driver
    FROM TRIP WHERE id_trip = p_id_trip;
    
    -- Compter les tickets émis
    SELECT COUNT(*) INTO v_ticket_count
    FROM TICKET WHERE id_trip = p_id_trip AND ticket_status = 'VALID';
    
    -- Remboursement automatique de tous les tickets
    UPDATE TICKET 
    SET ticket_status = 'REFUNDED'
    WHERE id_trip = p_id_trip AND ticket_status = 'VALID';
    
    -- Mise à jour statut voyage
    UPDATE TRIP 
    SET status = 'CANCELLED'
    WHERE id_trip = p_id_trip;
    
    -- Libération des ressources
    UPDATE BUS SET status = 'AVAILABLE' WHERE id_bus = v_id_bus;
    UPDATE DRIVER SET status = 'ACTIVE' WHERE id_driver = v_id_driver;
    
    -- Log de l'annulation
    DBMS_OUTPUT.PUT_LINE('Voyage ' || p_id_trip || ' annulé. Raison: ' || p_reason);
    DBMS_OUTPUT.PUT_LINE(v_ticket_count || ' tickets remboursés.');
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO before_cancel;
        RAISE_APPLICATION_ERROR(-20106, 'Voyage introuvable');
    WHEN OTHERS THEN
        ROLLBACK TO before_cancel;
        RAISE_APPLICATION_ERROR(-20107, 'Erreur annulation voyage: ' || SQLERRM);
END CANCEL_TRIP;
/

-- ============================================
-- GESTION DE LA BILLETTERIE
-- ============================================

CREATE OR REPLACE PROCEDURE BOOK_TICKET(
    p_ticket_number IN VARCHAR2,
    p_ticket_type IN VARCHAR2,
    p_id_trip IN NUMBER,
    p_id_boarding_station IN NUMBER,
    p_id_alighting_station IN NUMBER,
    p_ticket_id OUT NUMBER
) AS
    v_available_seats NUMBER;
    v_price DECIMAL(10,2);
    v_base_price DECIMAL(10,2);
    v_discount_rate DECIMAL(3,2) := 0;
BEGIN
    SAVEPOINT before_booking;
    
    -- Vérification places disponibles
    SELECT available_seats, price INTO v_available_seats, v_base_price
    FROM TRIP WHERE id_trip = p_id_trip;
    
    IF v_available_seats <= 0 THEN
        RAISE_APPLICATION_ERROR(-20201, 'Plus de places disponibles');
    END IF;
    
    -- Application des réductions selon type de ticket
    CASE p_ticket_type
        WHEN 'STUDENT' THEN v_discount_rate := 0.20;
        WHEN 'SENIOR' THEN v_discount_rate := 0.25;
        WHEN 'CHILD' THEN v_discount_rate := 0.50;
        ELSE v_discount_rate := 0;
    END CASE;
    
    v_price := v_base_price * (1 - v_discount_rate);
    
    -- Création du ticket
    INSERT INTO TICKET (
        id_ticket, ticket_number, ticket_type, price, 
        issue_date, ticket_status, id_trip, 
        id_boarding_station, id_alighting_station
    )
    VALUES (
        SEQ_TICKET.NEXTVAL, p_ticket_number, p_ticket_type, v_price,
        SYSTIMESTAMP, 'VALID', p_id_trip,
        p_id_boarding_station, p_id_alighting_station
    )
    RETURNING id_ticket INTO p_ticket_id;
    
    -- Décrémenter les places disponibles
    UPDATE TRIP 
    SET available_seats = available_seats - 1
    WHERE id_trip = p_id_trip;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO before_booking;
        RAISE_APPLICATION_ERROR(-20202, 'Voyage introuvable');
    WHEN OTHERS THEN
        ROLLBACK TO before_booking;
        RAISE_APPLICATION_ERROR(-20203, 'Erreur réservation: ' || SQLERRM);
END BOOK_TICKET;
/

CREATE OR REPLACE PROCEDURE CANCEL_TICKET_REFUND(
    p_id_ticket IN NUMBER
) AS
    v_id_trip NUMBER;
    v_ticket_status VARCHAR2(20);
    v_departure_time TIMESTAMP;
    v_hours_before NUMBER;
BEGIN
    SAVEPOINT before_cancellation;
    
    -- Récupération informations ticket et voyage
    SELECT t.id_trip, t.ticket_status, tr.departure_time
    INTO v_id_trip, v_ticket_status, v_departure_time
    FROM TICKET t
    JOIN TRIP tr ON t.id_trip = tr.id_trip
    WHERE t.id_ticket = p_id_ticket;
    
    -- Vérification statut ticket
    IF v_ticket_status != 'VALID' THEN
        RAISE_APPLICATION_ERROR(-20204, 'Ticket déjà annulé ou utilisé');
    END IF;
    
    -- Calcul heures avant départ
    v_hours_before := (v_departure_time - SYSTIMESTAMP) * 24;
    
    IF v_hours_before < 2 THEN
        RAISE_APPLICATION_ERROR(-20205, 'Annulation impossible moins de 2h avant départ');
    END IF;
    
    -- Mise à jour statut ticket
    UPDATE TICKET 
    SET ticket_status = 'REFUNDED'
    WHERE id_ticket = p_id_ticket;
    
    -- Libération de la place
    UPDATE TRIP 
    SET available_seats = available_seats + 1
    WHERE id_trip = v_id_trip;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO before_cancellation;
        RAISE_APPLICATION_ERROR(-20206, 'Ticket introuvable');
    WHEN OTHERS THEN
        ROLLBACK TO before_cancellation;
        RAISE_APPLICATION_ERROR(-20207, 'Erreur annulation ticket: ' || SQLERRM);
END CANCEL_TICKET_REFUND;
/

CREATE OR REPLACE PROCEDURE VALIDATE_TICKET(
    p_id_ticket IN NUMBER,
    p_id_station IN NUMBER
) AS
    v_ticket_status VARCHAR2(20);
    v_id_boarding_station NUMBER;
    v_id_trip NUMBER;
    v_trip_status VARCHAR2(20);
BEGIN
    -- Récupération informations ticket
    SELECT ticket_status, id_boarding_station, id_trip
    INTO v_ticket_status, v_id_boarding_station, v_id_trip
    FROM TICKET WHERE id_ticket = p_id_ticket;
    
    -- Vérification statut ticket
    IF v_ticket_status != 'VALID' THEN
        RAISE_APPLICATION_ERROR(-20208, 'Ticket invalide');
    END IF;
    
    -- Vérification station d'embarquement
    IF v_id_boarding_station != p_id_station THEN
        RAISE_APPLICATION_ERROR(-20209, 'Station d''embarquement incorrecte');
    END IF;
    
    -- Vérification statut voyage
    SELECT status INTO v_trip_status
    FROM TRIP WHERE id_trip = v_id_trip;
    
    IF v_trip_status NOT IN ('SCHEDULED', 'IN_PROGRESS') THEN
        RAISE_APPLICATION_ERROR(-20210, 'Voyage non disponible');
    END IF;
    
    -- Validation du ticket
    UPDATE TICKET 
    SET ticket_status = 'USED'
    WHERE id_ticket = p_id_ticket;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20211, 'Ticket ou voyage introuvable');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20212, 'Erreur validation ticket: ' || SQLERRM);
END VALIDATE_TICKET;
/

-- ============================================
-- GESTION DES INCIDENTS
-- ============================================

CREATE OR REPLACE PROCEDURE REPORT_INCIDENT(
    p_type IN VARCHAR2,
    p_description IN VARCHAR2,
    p_severity IN VARCHAR2,
    p_id_trip IN NUMBER,
    p_id_bus IN NUMBER,
    p_id_driver IN NUMBER,
    p_incident_id OUT NUMBER
) AS
BEGIN
    SAVEPOINT before_report;
    
    -- Création incident
    INSERT INTO INCIDENT (
        id_incident, type, description, severity, 
        status, reported_date, id_trip, id_bus, id_driver
    )
    VALUES (
        SEQ_INCIDENT.NEXTVAL, p_type, p_description, p_severity,
        'OPEN', SYSTIMESTAMP, p_id_trip, p_id_bus, p_id_driver
    )
    RETURNING id_incident INTO p_incident_id;
    
    -- Si incident critique, mise à jour statut voyage
    IF p_severity = 'CRITICAL' THEN
        UPDATE TRIP 
        SET status = 'DELAYED'
        WHERE id_trip = p_id_trip;
        
        -- Notification automatique (simulation)
        DBMS_OUTPUT.PUT_LINE('ALERTE: Incident critique signalé sur voyage ' || p_id_trip);
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO before_report;
        RAISE_APPLICATION_ERROR(-20301, 'Erreur signalement incident: ' || SQLERRM);
END REPORT_INCIDENT;
/

CREATE OR REPLACE PROCEDURE RESOLVE_INCIDENT(
    p_id_incident IN NUMBER,
    p_resolution_notes IN VARCHAR2
) AS
    v_severity VARCHAR2(20);
    v_id_bus NUMBER;
BEGIN
    SAVEPOINT before_resolution;
    
    -- Récupération informations incident
    SELECT severity, id_bus INTO v_severity, v_id_bus
    FROM INCIDENT WHERE id_incident = p_id_incident;
    
    -- Mise à jour incident
    UPDATE INCIDENT
    SET status = 'RESOLVED',
        resolved_date = SYSTIMESTAMP,
        description = description || CHR(10) || 'Résolution: ' || p_resolution_notes
    WHERE id_incident = p_id_incident;
    
    -- Si incident majeur résolu, remettre bus disponible
    IF v_severity IN ('MAJOR', 'CRITICAL') THEN
        UPDATE BUS 
        SET status = 'AVAILABLE'
        WHERE id_bus = v_id_bus;
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO before_resolution;
        RAISE_APPLICATION_ERROR(-20302, 'Incident introuvable');
    WHEN OTHERS THEN
        ROLLBACK TO before_resolution;
        RAISE_APPLICATION_ERROR(-20303, 'Erreur résolution incident: ' || SQLERRM);
END RESOLVE_INCIDENT;
/

CREATE OR REPLACE PROCEDURE ESCALATE_INCIDENT(
    p_id_incident IN NUMBER,
    p_new_severity IN VARCHAR2
) AS
    v_old_severity VARCHAR2(20);
    v_id_bus NUMBER;
BEGIN
    -- Récupération gravité actuelle
    SELECT severity, id_bus INTO v_old_severity, v_id_bus
    FROM INCIDENT WHERE id_incident = p_id_incident;
    
    -- Vérification escalade valide
    IF v_old_severity = 'CRITICAL' THEN
        RAISE_APPLICATION_ERROR(-20304, 'Incident déjà au niveau critique');
    END IF;
    
    -- Mise à jour gravité
    UPDATE INCIDENT
    SET severity = p_new_severity,
        description = description || CHR(10) || 
                     'Escaladé de ' || v_old_severity || ' à ' || p_new_severity
    WHERE id_incident = p_id_incident;
    
    -- Actions selon nouvelle gravité
    IF p_new_severity = 'CRITICAL' THEN
        UPDATE BUS 
        SET status = 'OUT_OF_SERVICE'
        WHERE id_bus = v_id_bus;
        
        DBMS_OUTPUT.PUT_LINE('Bus ' || v_id_bus || ' mis hors service');
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20305, 'Incident introuvable');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20306, 'Erreur escalade: ' || SQLERRM);
END ESCALATE_INCIDENT;
/

-- ============================================
-- GESTION DE LA MAINTENANCE
-- ============================================

CREATE OR REPLACE PROCEDURE SCHEDULE_MAINTENANCE(
    p_type IN VARCHAR2,
    p_description IN VARCHAR2,
    p_scheduled_date IN DATE,
    p_cost IN DECIMAL,
    p_id_bus IN NUMBER,
    p_maintenance_id OUT NUMBER
) AS
    v_bus_status VARCHAR2(20);
BEGIN
    SAVEPOINT before_schedule;
    
    -- Vérification statut bus
    SELECT status INTO v_bus_status
    FROM BUS WHERE id_bus = p_id_bus;
    
    IF v_bus_status = 'IN_SERVICE' THEN
        RAISE_APPLICATION_ERROR(-20401, 'Bus actuellement en service');
    END IF;
    
    -- Création maintenance
    INSERT INTO MAINTENANCE (
        id_maintenance, type, description, scheduled_date,
        cost, status, id_bus
    )
    VALUES (
        SEQ_MAINTENANCE.NEXTVAL, p_type, p_description, p_scheduled_date,
        p_cost, 'SCHEDULED', p_id_bus
    )
    RETURNING id_maintenance INTO p_maintenance_id;
    
    -- Mise à jour statut bus
    UPDATE BUS 
    SET status = 'MAINTENANCE'
    WHERE id_bus = p_id_bus;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO before_schedule;
        RAISE_APPLICATION_ERROR(-20402, 'Bus introuvable');
    WHEN OTHERS THEN
        ROLLBACK TO before_schedule;
        RAISE_APPLICATION_ERROR(-20403, 'Erreur planification maintenance: ' || SQLERRM);
END SCHEDULE_MAINTENANCE;
/

CREATE OR REPLACE PROCEDURE COMPLETE_MAINTENANCE(
    p_id_maintenance IN NUMBER,
    p_actual_cost IN DECIMAL,
    p_notes IN VARCHAR2
) AS
    v_id_bus NUMBER;
    v_scheduled_date DATE;
BEGIN
    SAVEPOINT before_completion;
    
    -- Récupération informations
    SELECT id_bus, scheduled_date INTO v_id_bus, v_scheduled_date
    FROM MAINTENANCE WHERE id_maintenance = p_id_maintenance;
    
    -- Mise à jour maintenance
    UPDATE MAINTENANCE
    SET status = 'COMPLETED',
        completed_date = SYSDATE,
        cost = NVL(p_actual_cost, cost),
        description = description || CHR(10) || 'Notes: ' || p_notes
    WHERE id_maintenance = p_id_maintenance;
    
    -- Remise en service du bus
    UPDATE BUS 
    SET status = 'AVAILABLE'
    WHERE id_bus = v_id_bus;
    
    DBMS_OUTPUT.PUT_LINE('Maintenance terminée. Bus ' || v_id_bus || ' remis en service.');
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO before_completion;
        RAISE_APPLICATION_ERROR(-20404, 'Maintenance introuvable');
    WHEN OTHERS THEN
        ROLLBACK TO before_completion;
        RAISE_APPLICATION_ERROR(-20405, 'Erreur finalisation maintenance: ' || SQLERRM);
END COMPLETE_MAINTENANCE;
/

CREATE OR REPLACE PROCEDURE UPDATE_BUS_STATUS(
    p_id_bus IN NUMBER,
    p_new_status IN VARCHAR2,
    p_reason IN VARCHAR2
) AS
    v_old_status VARCHAR2(20);
    v_active_trips NUMBER;
BEGIN
    -- Vérification statut actuel
    SELECT status INTO v_old_status
    FROM BUS WHERE id_bus = p_id_bus;
    
    -- Si passage à hors service, vérifier voyages actifs
    IF p_new_status = 'OUT_OF_SERVICE' THEN
        SELECT COUNT(*) INTO v_active_trips
        FROM TRIP 
        WHERE id_bus = p_id_bus 
        AND status IN ('SCHEDULED', 'IN_PROGRESS');
        
        IF v_active_trips > 0 THEN
            RAISE_APPLICATION_ERROR(-20406, 
                'Impossible: ' || v_active_trips || ' voyages actifs');
        END IF;
    END IF;
    
    -- Mise à jour statut
    UPDATE BUS 
    SET status = p_new_status
    WHERE id_bus = p_id_bus;
    
    DBMS_OUTPUT.PUT_LINE('Bus ' || p_id_bus || 
                        ': ' || v_old_status || ' -> ' || p_new_status ||
                        '. Raison: ' || p_reason);
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20407, 'Bus introuvable');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20408, 'Erreur MAJ statut: ' || SQLERRM);
END UPDATE_BUS_STATUS;
/

-- ============================================
-- GESTION DES ABONNEMENTS
-- ============================================

CREATE OR REPLACE PROCEDURE CREATE_SUBSCRIPTION(
    p_user_name IN VARCHAR2,
    p_user_email IN VARCHAR2,
    p_id_line IN NUMBER,
    p_duration_months IN NUMBER,
    p_subscription_id OUT NUMBER
) AS
    v_start_date DATE := SYSDATE;
    v_end_date DATE;
    v_base_price DECIMAL(10,2) := 50.00;
    v_total_price DECIMAL(10,2);
    v_discount_rate DECIMAL(3,2);
BEGIN
    SAVEPOINT before_subscription;
    
    -- Calcul date fin
    v_end_date := ADD_MONTHS(v_start_date, p_duration_months);
    
    -- Calcul prix avec réduction progressive
    CASE 
        WHEN p_duration_months >= 12 THEN v_discount_rate := 0.30;
        WHEN p_duration_months >= 6 THEN v_discount_rate := 0.20;
        WHEN p_duration_months >= 3 THEN v_discount_rate := 0.10;
        ELSE v_discount_rate := 0;
    END CASE;
    
    v_total_price := v_base_price * p_duration_months * (1 - v_discount_rate);
    
    -- Création abonnement
    INSERT INTO SUBSCRIPTION (
        id_subscription, user_name, user_email, 
        start_date, end_date, price, status, id_line
    )
    VALUES (
        SEQ_SUBSCRIPTION.NEXTVAL, p_user_name, p_user_email,
        v_start_date, v_end_date, v_total_price, 'ACTIVE', p_id_line
    )
    RETURNING id_subscription INTO p_subscription_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO before_subscription;
        RAISE_APPLICATION_ERROR(-20501, 'Erreur création abonnement: ' || SQLERRM);
END CREATE_SUBSCRIPTION;
/

CREATE OR REPLACE PROCEDURE RENEW_SUBSCRIPTION(
    p_id_subscription IN NUMBER,
    p_additional_months IN NUMBER
) AS
    v_current_end_date DATE;
    v_new_end_date DATE;
    v_status VARCHAR2(20);
BEGIN
    -- Récupération informations
    SELECT end_date, status INTO v_current_end_date, v_status
    FROM SUBSCRIPTION WHERE id_subscription = p_id_subscription;
    
    IF v_status = 'EXPIRED' THEN
        RAISE_APPLICATION_ERROR(-20502, 'Abonnement expiré - créer un nouvel abonnement');
    END IF;
    
    -- Calcul nouvelle date fin
    v_new_end_date := ADD_MONTHS(v_current_end_date, p_additional_months);
    
    -- Mise à jour
    UPDATE SUBSCRIPTION
    SET end_date = v_new_end_date,
        status = 'ACTIVE'
    WHERE id_subscription = p_id_subscription;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20503, 'Abonnement introuvable');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20504, 'Erreur renouvellement: ' || SQLERRM);
END RENEW_SUBSCRIPTION;
/

-- ============================================================================
-- FIN DES PROCÉDURES MÉTIER AVANCÉES
-- ============================================================================