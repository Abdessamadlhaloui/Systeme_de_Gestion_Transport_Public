-- ============================================================================
-- SECTION 1 : FONCTIONS - DISPONIBILITÉ ET CAPACITÉ
-- ============================================================================

-- ============================================
-- Fonction : GET_AVAILABLE_SEATS
-- Description : Calcule le nombre de sièges disponibles pour un voyage
-- Paramètre : id_trip - Identifiant du voyage
-- Retour : NUMBER - Nombre de sièges libres
-- ============================================
CREATE OR REPLACE FUNCTION GET_AVAILABLE_SEATS(
    p_id_trip IN NUMBER
) RETURN NUMBER
IS
    v_available_seats NUMBER;
BEGIN
    SELECT available_seats 
    INTO v_available_seats
    FROM TRIP
    WHERE id_trip = p_id_trip;
    
    RETURN v_available_seats;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1; -- Voyage introuvable
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20601, 'Erreur récupération places: ' || SQLERRM);
END GET_AVAILABLE_SEATS;
/

-- ============================================
-- Fonction : GET_BUS_STATUS
-- Description : Récupère le statut actuel d'un bus
-- Paramètre : id_bus - Identifiant du bus
-- Retour : VARCHAR2 - Statut (AVAILABLE, IN_SERVICE, MAINTENANCE, OUT_OF_SERVICE)
-- ============================================
CREATE OR REPLACE FUNCTION GET_BUS_STATUS(
    p_id_bus IN NUMBER
) RETURN VARCHAR2
IS
    v_status VARCHAR2(20);
BEGIN
    SELECT status 
    INTO v_status
    FROM BUS
    WHERE id_bus = p_id_bus;
    
    RETURN v_status;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'NOT_FOUND';
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20602, 'Erreur récupération statut bus: ' || SQLERRM);
END GET_BUS_STATUS;
/

-- ============================================
-- Fonction : GET_DRIVER_STATUS
-- Description : Récupère le statut actuel d'un chauffeur
-- Paramètre : id_driver - Identifiant du chauffeur
-- Retour : VARCHAR2 - Statut (ACTIVE, IN_SERVICE, INACTIVE, ON_LEAVE)
-- ============================================
CREATE OR REPLACE FUNCTION GET_DRIVER_STATUS(
    p_id_driver IN NUMBER
) RETURN VARCHAR2
IS
    v_status VARCHAR2(20);
BEGIN
    SELECT status 
    INTO v_status
    FROM DRIVER
    WHERE id_driver = p_id_driver;
    
    RETURN v_status;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'NOT_FOUND';
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20603, 'Erreur récupération statut chauffeur: ' || SQLERRM);
END GET_DRIVER_STATUS;
/

-- ============================================
-- Fonction : CHECK_BUS_AVAILABILITY
-- Description : Vérifie si un bus est disponible à une date donnée
-- Paramètres : id_bus - Identifiant du bus
--              p_date - Date de vérification
-- Retour : BOOLEAN - TRUE si disponible, FALSE sinon
-- ============================================
CREATE OR REPLACE FUNCTION CHECK_BUS_AVAILABILITY(
    p_id_bus IN NUMBER,
    p_date IN TIMESTAMP
) RETURN BOOLEAN
IS
    v_conflict_count NUMBER;
    v_status VARCHAR2(20);
BEGIN
    -- Vérifier statut du bus
    SELECT status INTO v_status
    FROM BUS WHERE id_bus = p_id_bus;
    
    IF v_status != 'AVAILABLE' THEN
        RETURN FALSE;
    END IF;
    
    -- Vérifier conflits horaires
    SELECT COUNT(*) INTO v_conflict_count
    FROM TRIP
    WHERE id_bus = p_id_bus
      AND status IN ('SCHEDULED', 'IN_PROGRESS')
      AND p_date BETWEEN departure_time AND arrival_time;
    
    RETURN (v_conflict_count = 0);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20604, 'Erreur vérification disponibilité: ' || SQLERRM);
END CHECK_BUS_AVAILABILITY;
/

-- ============================================================================
-- SECTION 2 : FONCTIONS - CALCULS TARIFAIRES
-- ============================================================================

-- ============================================
-- Fonction : CALCULATE_TRIP_PRICE
-- Description : Calcule le prix d'un trajet selon la distance
-- Paramètres : id_boarding_station - Station d'embarquement
--              id_alighting_station - Station de débarquement
-- Retour : DECIMAL - Prix calculé
-- ============================================
CREATE OR REPLACE FUNCTION CALCULATE_TRIP_PRICE(
    p_id_boarding_station IN NUMBER,
    p_id_alighting_station IN NUMBER
) RETURN DECIMAL
IS
    v_distance_boarding DECIMAL(10,2);
    v_distance_alighting DECIMAL(10,2);
    v_total_distance DECIMAL(10,2);
    v_price DECIMAL(10,2);
    v_base_rate CONSTANT DECIMAL(5,2) := 2.50; -- Prix de base par km
BEGIN
    -- Récupérer distance depuis le début pour chaque station
    SELECT distance_from_start_km INTO v_distance_boarding
    FROM LINE_STATION
    WHERE id_station = p_id_boarding_station;
    
    SELECT distance_from_start_km INTO v_distance_alighting
    FROM LINE_STATION
    WHERE id_station = p_id_alighting_station;
    
    -- Calculer distance totale
    v_total_distance := ABS(v_distance_alighting - v_distance_boarding);
    
    -- Calculer prix
    v_price := v_total_distance * v_base_rate;
    
    -- Prix minimum de 5.00
    IF v_price < 5.00 THEN
        v_price := 5.00;
    END IF;
    
    RETURN ROUND(v_price, 2);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20605, 'Station introuvable');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20606, 'Erreur calcul prix: ' || SQLERRM);
END CALCULATE_TRIP_PRICE;
/

-- ============================================
-- Fonction : CALCULATE_SUBSCRIPTION_PRICE
-- Description : Calcule le prix d'un abonnement avec réductions progressives
-- Paramètres : id_line - Identifiant de la ligne
--              duration_months - Durée en mois
-- Retour : DECIMAL - Prix total avec réduction
-- ============================================
CREATE OR REPLACE FUNCTION CALCULATE_SUBSCRIPTION_PRICE(
    p_id_line IN NUMBER,
    p_duration_months IN NUMBER
) RETURN DECIMAL
IS
    v_base_price CONSTANT DECIMAL(10,2) := 50.00; -- Prix mensuel de base
    v_total_price DECIMAL(10,2);
    v_discount_rate DECIMAL(3,2);
BEGIN
    -- Vérifier que la ligne existe
    DECLARE
        v_line_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_line_exists
        FROM BUS_LINE WHERE id_line = p_id_line;
        
        IF v_line_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20607, 'Ligne introuvable');
        END IF;
    END;
    
    -- Appliquer réductions progressives
    CASE 
        WHEN p_duration_months >= 12 THEN 
            v_discount_rate := 0.30; -- 30% de réduction
        WHEN p_duration_months >= 6 THEN 
            v_discount_rate := 0.20; -- 20% de réduction
        WHEN p_duration_months >= 3 THEN 
            v_discount_rate := 0.10; -- 10% de réduction
        ELSE 
            v_discount_rate := 0;    -- Pas de réduction
    END CASE;
    
    v_total_price := v_base_price * p_duration_months * (1 - v_discount_rate);
    
    RETURN ROUND(v_total_price, 2);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20608, 'Erreur calcul abonnement: ' || SQLERRM);
END CALCULATE_SUBSCRIPTION_PRICE;
/

-- ============================================
-- Fonction : APPLY_DISCOUNT
-- Description : Applique une réduction selon le type de ticket
-- Paramètres : base_price - Prix de base
--              ticket_type - Type (STANDARD, STUDENT, SENIOR, CHILD)
-- Retour : DECIMAL - Prix après réduction
-- ============================================
CREATE OR REPLACE FUNCTION APPLY_DISCOUNT(
    p_base_price IN DECIMAL,
    p_ticket_type IN VARCHAR2
) RETURN DECIMAL
IS
    v_discount_rate DECIMAL(3,2);
    v_final_price DECIMAL(10,2);
BEGIN
    -- Déterminer taux de réduction
    CASE p_ticket_type
        WHEN 'STUDENT' THEN 
            v_discount_rate := 0.20; -- 20% étudiant
        WHEN 'SENIOR' THEN 
            v_discount_rate := 0.25; -- 25% senior
        WHEN 'CHILD' THEN 
            v_discount_rate := 0.50; -- 50% enfant
        WHEN 'STANDARD' THEN 
            v_discount_rate := 0;    -- Pas de réduction
        ELSE 
            v_discount_rate := 0;    -- Type inconnu = pas de réduction
    END CASE;
    
    v_final_price := p_base_price * (1 - v_discount_rate);
    
    RETURN ROUND(v_final_price, 2);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20609, 'Erreur application réduction: ' || SQLERRM);
END APPLY_DISCOUNT;
/

-- ============================================================================
-- SECTION 3 : FONCTIONS - VALIDATION ET CONTRÔLE
-- ============================================================================

-- ============================================
-- Fonction : VALIDATE_LICENSE_EXPIRY
-- Description : Vérifie si le permis d'un chauffeur est valide
-- Paramètre : id_driver - Identifiant du chauffeur
-- Retour : BOOLEAN - TRUE si valide, FALSE si expiré
-- ============================================
CREATE OR REPLACE FUNCTION VALIDATE_LICENSE_EXPIRY(
    p_id_driver IN NUMBER
) RETURN BOOLEAN
IS
    v_license_expiry DATE;
    v_is_valid BOOLEAN;
BEGIN
    SELECT license_expiry 
    INTO v_license_expiry
    FROM DRIVER
    WHERE id_driver = p_id_driver;
    
    -- Vérifier si le permis est valide (non expiré)
    IF v_license_expiry >= SYSDATE THEN
        v_is_valid := TRUE;
    ELSE
        v_is_valid := FALSE;
        
        -- Mettre à jour le statut du chauffeur
        UPDATE DRIVER 
        SET status = 'INACTIVE'
        WHERE id_driver = p_id_driver;
        
        COMMIT;
    END IF;
    
    RETURN v_is_valid;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20610, 'Erreur validation permis: ' || SQLERRM);
END VALIDATE_LICENSE_EXPIRY;
/

-- ============================================
-- Fonction : CHECK_TRIP_CONFLICTS
-- Description : Détecte les chevauchements horaires pour un bus et chauffeur
-- Paramètres : id_bus - Identifiant du bus
--              id_driver - Identifiant du chauffeur
--              p_departure - Heure de départ
--              p_arrival - Heure d'arrivée
-- Retour : BOOLEAN - TRUE si conflit détecté, FALSE sinon
-- ============================================
CREATE OR REPLACE FUNCTION CHECK_TRIP_CONFLICTS(
    p_id_bus IN NUMBER,
    p_id_driver IN NUMBER,
    p_departure IN TIMESTAMP,
    p_arrival IN TIMESTAMP
) RETURN BOOLEAN
IS
    v_bus_conflicts NUMBER;
    v_driver_conflicts NUMBER;
BEGIN
    -- Vérifier conflits pour le bus
    SELECT COUNT(*) INTO v_bus_conflicts
    FROM TRIP
    WHERE id_bus = p_id_bus
      AND status IN ('SCHEDULED', 'IN_PROGRESS')
      AND (
          (p_departure BETWEEN departure_time AND arrival_time)
          OR (p_arrival BETWEEN departure_time AND arrival_time)
          OR (departure_time BETWEEN p_departure AND p_arrival)
      );
    
    -- Vérifier conflits pour le chauffeur
    SELECT COUNT(*) INTO v_driver_conflicts
    FROM TRIP
    WHERE id_driver = p_id_driver
      AND status IN ('SCHEDULED', 'IN_PROGRESS')
      AND (
          (p_departure BETWEEN departure_time AND arrival_time)
          OR (p_arrival BETWEEN departure_time AND arrival_time)
          OR (departure_time BETWEEN p_departure AND p_arrival)
      );
    
    RETURN (v_bus_conflicts > 0 OR v_driver_conflicts > 0);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20611, 'Erreur détection conflits: ' || SQLERRM);
END CHECK_TRIP_CONFLICTS;
/

-- ============================================
-- Fonction : VALIDATE_STATION_ORDER
-- Description : Vérifie la cohérence de l'ordre des arrêts sur une ligne
-- Paramètres : id_line - Identifiant de la ligne
--              stop_order - Ordre de l'arrêt à valider
-- Retour : BOOLEAN - TRUE si ordre cohérent, FALSE sinon
-- ============================================
CREATE OR REPLACE FUNCTION VALIDATE_STATION_ORDER(
    p_id_line IN NUMBER,
    p_stop_order IN NUMBER
) RETURN BOOLEAN
IS
    v_max_order NUMBER;
    v_station_exists NUMBER;
BEGIN
    -- Vérifier que l'ordre n'est pas négatif ou nul
    IF p_stop_order <= 0 THEN
        RETURN FALSE;
    END IF;
    
    -- Récupérer l'ordre maximum existant
    SELECT NVL(MAX(stop_order), 0) 
    INTO v_max_order
    FROM LINE_STATION
    WHERE id_line = p_id_line;
    
    -- Vérifier que le nouvel ordre est séquentiel
    IF p_stop_order > v_max_order + 1 THEN
        RETURN FALSE; -- Saut dans la numérotation
    END IF;
    
    -- Vérifier qu'il n'y a pas de doublon
    SELECT COUNT(*) INTO v_station_exists
    FROM LINE_STATION
    WHERE id_line = p_id_line 
      AND stop_order = p_stop_order;
    
    IF v_station_exists > 0 THEN
        RETURN FALSE; -- Ordre déjà utilisé
    END IF;
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20612, 'Erreur validation ordre: ' || SQLERRM);
END VALIDATE_STATION_ORDER;
/

-- ============================================================================
-- SECTION 4 : FONCTIONS - STATISTIQUES ET RAPPORTS
-- ============================================================================

-- ============================================
-- Fonction : GET_LINE_STATIONS
-- Description : Récupère la liste complète des stations d'une ligne
-- Paramètre : id_line - Identifiant de la ligne
-- Retour : SYS_REFCURSOR - Curseur contenant les stations
-- ============================================
CREATE OR REPLACE FUNCTION GET_LINE_STATIONS(
    p_id_line IN NUMBER
) RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT 
            s.id_station,
            s.name,
            s.address,
            ls.stop_order,
            ls.distance_from_start_km
        FROM STATION s
        JOIN LINE_STATION ls ON s.id_station = ls.id_station
        WHERE ls.id_line = p_id_line
        ORDER BY ls.stop_order;
    
    RETURN v_cursor;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20613, 'Erreur récupération stations: ' || SQLERRM);
END GET_LINE_STATIONS;
/

-- ============================================
-- Fonction : GET_TRIP_REVENUE
-- Description : Calcule les revenus totaux d'un voyage
-- Paramètre : id_trip - Identifiant du voyage
-- Retour : DECIMAL - Revenus totaux
-- ============================================
CREATE OR REPLACE FUNCTION GET_TRIP_REVENUE(
    p_id_trip IN NUMBER
) RETURN DECIMAL
IS
    v_total_revenue DECIMAL(10,2);
BEGIN
    SELECT NVL(SUM(price), 0)
    INTO v_total_revenue
    FROM TICKET
    WHERE id_trip = p_id_trip
      AND ticket_status IN ('VALID', 'USED');
    
    RETURN v_total_revenue;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20614, 'Erreur calcul revenus: ' || SQLERRM);
END GET_TRIP_REVENUE;
/

-- ============================================
-- Fonction : GET_BUS_UTILIZATION_RATE
-- Description : Calcule le taux d'utilisation d'un bus en pourcentage
-- Paramètre : id_bus - Identifiant du bus
-- Retour : DECIMAL - Taux d'utilisation (0-100)
-- ============================================
CREATE OR REPLACE FUNCTION GET_BUS_UTILIZATION_RATE(
    p_id_bus IN NUMBER
) RETURN DECIMAL
IS
    v_total_trips NUMBER;
    v_completed_trips NUMBER;
    v_utilization_rate DECIMAL(5,2);
BEGIN
    -- Compter le nombre total de voyages assignés
    SELECT COUNT(*) INTO v_total_trips
    FROM TRIP
    WHERE id_bus = p_id_bus;
    
    IF v_total_trips = 0 THEN
        RETURN 0;
    END IF;
    
    -- Compter les voyages terminés
    SELECT COUNT(*) INTO v_completed_trips
    FROM TRIP
    WHERE id_bus = p_id_bus
      AND status = 'COMPLETED';
    
    -- Calculer le taux
    v_utilization_rate := (v_completed_trips / v_total_trips) * 100;
    
    RETURN ROUND(v_utilization_rate, 2);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20615, 'Erreur calcul utilisation: ' || SQLERRM);
END GET_BUS_UTILIZATION_RATE;
/

-- ============================================
-- Fonction : GET_DRIVER_TRIP_COUNT
-- Description : Compte le nombre de voyages effectués par un chauffeur
-- Paramètres : id_driver - Identifiant du chauffeur
--              date_start - Date de début
--              date_end - Date de fin
-- Retour : NUMBER - Nombre de voyages
-- ============================================
CREATE OR REPLACE FUNCTION GET_DRIVER_TRIP_COUNT(
    p_id_driver IN NUMBER,
    p_date_start IN DATE,
    p_date_end IN DATE
) RETURN NUMBER
IS
    v_trip_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_trip_count
    FROM TRIP
    WHERE id_driver = p_id_driver
      AND status = 'COMPLETED'
      AND TRUNC(departure_time) BETWEEN p_date_start AND p_date_end;
    
    RETURN v_trip_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20616, 'Erreur comptage voyages: ' || SQLERRM);
END GET_DRIVER_TRIP_COUNT;
/

-- ============================================================================
-- FIN DES FONCTIONS MÉTIER
-- ============================================================================