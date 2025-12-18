-- ============================================================================
-- SECTION 1 : TRIGGERS DE VALIDATION CRITIQUE
-- ============================================================================

-- ============================================
-- Trigger : TRG_CHECK_BUS_AVAILABILITY
-- Description : Empêche l'affectation d'un bus non disponible
--               Vérifie les conflits horaires du bus
--               Valide que le statut est AVAILABLE
-- Tables : TRIP (BEFORE INSERT OR UPDATE)
-- ============================================
CREATE OR REPLACE TRIGGER TRG_CHECK_BUS_AVAILABILITY
BEFORE INSERT OR UPDATE ON TRIP
FOR EACH ROW
DECLARE
    v_bus_status VARCHAR2(20);
    v_conflict_count NUMBER;
BEGIN
    -- Vérifier le statut du bus
    SELECT status 
    INTO v_bus_status
    FROM BUS
    WHERE id_bus = :NEW.id_bus;
    
    -- Empêcher affectation si bus en maintenance ou hors service
    IF v_bus_status NOT IN ('AVAILABLE', 'IN_SERVICE') THEN
        RAISE_APPLICATION_ERROR(-20701, 
            'Bus ' || :NEW.id_bus || ' non disponible. Statut: ' || v_bus_status);
    END IF;
    
    -- Vérifier les conflits horaires (chevauchement de voyages)
    SELECT COUNT(*)
    INTO v_conflict_count
    FROM TRIP
    WHERE id_bus = :NEW.id_bus
      AND id_trip != NVL(:NEW.id_trip, -1)
      AND status IN ('SCHEDULED', 'IN_PROGRESS')
      AND (
          -- Nouveau voyage commence pendant un voyage existant
          (:NEW.departure_time BETWEEN departure_time AND arrival_time)
          OR
          -- Nouveau voyage se termine pendant un voyage existant
          (:NEW.arrival_time BETWEEN departure_time AND arrival_time)
          OR
          -- Nouveau voyage englobe un voyage existant
          (departure_time BETWEEN :NEW.departure_time AND :NEW.arrival_time)
      );
    
    IF v_conflict_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20702,
            'Conflit horaire: Bus ' || :NEW.id_bus || 
            ' déjà assigné à un autre voyage dans ce créneau');
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20703, 
            'Bus ID ' || :NEW.id_bus || ' introuvable');
END TRG_CHECK_BUS_AVAILABILITY;
/

-- ============================================
-- Trigger : TRG_VALIDATE_LICENSE
-- Description : Vérifie la validité du permis du chauffeur
--               Bloque l'affectation si permis expiré
--               Vérifie les conflits horaires du chauffeur
-- Tables : TRIP (BEFORE INSERT OR UPDATE)
-- ============================================
CREATE OR REPLACE TRIGGER TRG_VALIDATE_LICENSE
BEFORE INSERT OR UPDATE ON TRIP
FOR EACH ROW
DECLARE
    v_license_expiry DATE;
    v_driver_status VARCHAR2(20);
    v_driver_name VARCHAR2(100);
    v_conflict_count NUMBER;
BEGIN
    -- Récupérer les informations du chauffeur
    SELECT license_expiry, status, name
    INTO v_license_expiry, v_driver_status, v_driver_name
    FROM DRIVER
    WHERE id_driver = :NEW.id_driver;
    
    -- Vérifier si le permis est valide
    IF v_license_expiry < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20704,
            'Permis de conduite expiré pour le chauffeur ' || v_driver_name ||
            ' (expiré le ' || TO_CHAR(v_license_expiry, 'DD/MM/YYYY') || ')');
    END IF;
    
    -- Vérifier le statut du chauffeur
    IF v_driver_status NOT IN ('ACTIVE', 'IN_SERVICE') THEN
        RAISE_APPLICATION_ERROR(-20705,
            'Chauffeur ' || v_driver_name || ' non actif. Statut: ' || v_driver_status);
    END IF;
    
    -- Vérifier les conflits horaires du chauffeur
    SELECT COUNT(*)
    INTO v_conflict_count
    FROM TRIP
    WHERE id_driver = :NEW.id_driver
      AND id_trip != NVL(:NEW.id_trip, -1)
      AND status IN ('SCHEDULED', 'IN_PROGRESS')
      AND (
          (:NEW.departure_time BETWEEN departure_time AND arrival_time)
          OR (:NEW.arrival_time BETWEEN departure_time AND arrival_time)
          OR (departure_time BETWEEN :NEW.departure_time AND :NEW.arrival_time)
      );
    
    IF v_conflict_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20706,
            'Conflit horaire: Chauffeur ' || v_driver_name || 
            ' déjà assigné à un autre voyage');
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20707, 
            'Chauffeur ID ' || :NEW.id_driver || ' introuvable');
END TRG_VALIDATE_LICENSE;
/

-- ============================================
-- Trigger : TRG_MANAGE_SEATS
-- Description : Gère automatiquement le nombre de places disponibles
--               Décrémente lors d'une réservation
--               Incrémente lors d'une annulation
--               Empêche la surréservation
-- Tables : TICKET (AFTER INSERT OR UPDATE OR DELETE)
-- ============================================
CREATE OR REPLACE TRIGGER TRG_MANAGE_SEATS
AFTER INSERT OR UPDATE OR DELETE ON TICKET
FOR EACH ROW
DECLARE
    v_available_seats NUMBER;
BEGIN
    -- Lors d'une insertion (nouvelle réservation)
    IF INSERTING AND :NEW.ticket_status = 'VALID' THEN
        -- Vérifier places disponibles
        SELECT available_seats INTO v_available_seats
        FROM TRIP WHERE id_trip = :NEW.id_trip;
        
        IF v_available_seats <= 0 THEN
            RAISE_APPLICATION_ERROR(-20708, 
                'Plus de places disponibles pour ce voyage');
        END IF;
        
        -- Décrémenter les places
        UPDATE TRIP 
        SET available_seats = available_seats - 1
        WHERE id_trip = :NEW.id_trip;
    END IF;
    
    -- Lors d'une mise à jour (changement de statut)
    IF UPDATING THEN
        -- Ticket annulé ou remboursé : libérer la place
        IF :OLD.ticket_status = 'VALID' AND 
           :NEW.ticket_status IN ('CANCELLED', 'REFUNDED') THEN
            UPDATE TRIP 
            SET available_seats = available_seats + 1
            WHERE id_trip = :NEW.id_trip;
        END IF;
        
        -- Ticket réactivé : reprendre la place
        IF :OLD.ticket_status IN ('CANCELLED', 'REFUNDED') AND 
           :NEW.ticket_status = 'VALID' THEN
            UPDATE TRIP 
            SET available_seats = available_seats - 1
            WHERE id_trip = :NEW.id_trip;
        END IF;
    END IF;
    
    -- Lors d'une suppression
    IF DELETING AND :OLD.ticket_status = 'VALID' THEN
        -- Libérer la place
        UPDATE TRIP 
        SET available_seats = available_seats + 1
        WHERE id_trip = :OLD.id_trip;
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20709, 'Voyage introuvable');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20710, 'Erreur gestion places: ' || SQLERRM);
END TRG_MANAGE_SEATS;
/

-- ============================================================================
-- SECTION 2 : TRIGGERS D'AUTOMATISATION
-- ============================================================================

-- ============================================
-- Trigger : TRG_AUTO_TICKET_NUMBER
-- Description : Génération automatique d'un numéro de ticket unique
--               Format : TKT-YYYYMMDD-XXXXX
--               Garantit l'unicité du numéro
-- Tables : TICKET (BEFORE INSERT)
-- ============================================
CREATE OR REPLACE TRIGGER TRG_AUTO_TICKET_NUMBER
BEFORE INSERT ON TICKET
FOR EACH ROW
DECLARE
    v_date_part VARCHAR2(8);
    v_sequence_part VARCHAR2(5);
    v_ticket_count NUMBER;
BEGIN
    -- Si le numéro de ticket n'est pas fourni, le générer automatiquement
    IF :NEW.ticket_number IS NULL THEN
        -- Partie date : YYYYMMDD
        v_date_part := TO_CHAR(SYSDATE, 'YYYYMMDD');
        
        -- Compter les tickets du jour pour le numéro de séquence
        SELECT COUNT(*) + 1
        INTO v_ticket_count
        FROM TICKET
        WHERE TO_CHAR(issue_date, 'YYYYMMDD') = v_date_part;
        
        -- Formater le numéro de séquence sur 5 chiffres
        v_sequence_part := LPAD(v_ticket_count, 5, '0');
        
        -- Construire le numéro complet
        :NEW.ticket_number := 'TKT-' || v_date_part || '-' || v_sequence_part;
    END IF;
    
    -- Vérifier l'unicité (au cas où le numéro est fourni manuellement)
    SELECT COUNT(*)
    INTO v_ticket_count
    FROM TICKET
    WHERE ticket_number = :NEW.ticket_number;
    
    IF v_ticket_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20711, 
            'Numéro de ticket ' || :NEW.ticket_number || ' déjà existant');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20712, 
            'Erreur génération numéro ticket: ' || SQLERRM);
END TRG_AUTO_TICKET_NUMBER;
/

-- ============================================
-- Trigger : TRG_VALIDATE_TICKET_STATIONS
-- Description : Vérifie que les stations sont bien sur la ligne du voyage
--               Valide l'ordre boarding/alighting
--               Empêche les itinéraires invalides
-- Tables : TICKET (BEFORE INSERT OR UPDATE)
-- ============================================
CREATE OR REPLACE TRIGGER TRG_VALIDATE_TICKET_STATIONS
BEFORE INSERT OR UPDATE ON TICKET
FOR EACH ROW
DECLARE
    v_id_line NUMBER;
    v_boarding_exists NUMBER;
    v_alighting_exists NUMBER;
    v_boarding_order NUMBER;
    v_alighting_order NUMBER;
BEGIN
    -- Récupérer la ligne du voyage
    SELECT id_line INTO v_id_line
    FROM TRIP WHERE id_trip = :NEW.id_trip;
    
    -- Vérifier que la station d'embarquement est sur la ligne
    SELECT COUNT(*), MAX(stop_order)
    INTO v_boarding_exists, v_boarding_order
    FROM LINE_STATION
    WHERE id_line = v_id_line 
      AND id_station = :NEW.id_boarding_station;
    
    IF v_boarding_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20713,
            'Station d''embarquement non présente sur cette ligne');
    END IF;
    
    -- Vérifier que la station de débarquement est sur la ligne
    SELECT COUNT(*), MAX(stop_order)
    INTO v_alighting_exists, v_alighting_order
    FROM LINE_STATION
    WHERE id_line = v_id_line 
      AND id_station = :NEW.id_alighting_station;
    
    IF v_alighting_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20714,
            'Station de débarquement non présente sur cette ligne');
    END IF;
    
    -- Vérifier que l'ordre est cohérent (boarding avant alighting)
    IF v_boarding_order >= v_alighting_order THEN
        RAISE_APPLICATION_ERROR(-20715,
            'Station d''embarquement doit être avant la station de débarquement');
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20716, 'Voyage ou ligne introuvable');
    WHEN OTHERS THEN
        IF SQLCODE NOT BETWEEN -20716 AND -20713 THEN
            RAISE_APPLICATION_ERROR(-20717, 
                'Erreur validation stations: ' || SQLERRM);
        ELSE
            RAISE;
        END IF;
END TRG_VALIDATE_TICKET_STATIONS;
/

-- ============================================
-- Trigger : TRG_UPDATE_ENTITIES_STATUS
-- Description : Met à jour automatiquement le statut du bus et chauffeur
--               Libère les ressources après un voyage
--               Synchronise les états entre tables
-- Tables : TRIP (AFTER UPDATE)
-- ============================================
CREATE OR REPLACE TRIGGER TRG_UPDATE_ENTITIES_STATUS
AFTER UPDATE OF status ON TRIP
FOR EACH ROW
BEGIN
    -- Si le voyage passe à COMPLETED ou CANCELLED
    IF :NEW.status IN ('COMPLETED', 'CANCELLED') AND 
       :OLD.status NOT IN ('COMPLETED', 'CANCELLED') THEN
        
        -- Libérer le bus (le remettre AVAILABLE)
        UPDATE BUS
        SET status = 'AVAILABLE'
        WHERE id_bus = :NEW.id_bus
          AND status = 'IN_SERVICE';
        
        -- Libérer le chauffeur (le remettre ACTIVE)
        UPDATE DRIVER
        SET status = 'ACTIVE'
        WHERE id_driver = :NEW.id_driver
          AND status = 'IN_SERVICE';
          
    -- Si le voyage passe à IN_PROGRESS
    ELSIF :NEW.status = 'IN_PROGRESS' AND :OLD.status = 'SCHEDULED' THEN
        
        -- Confirmer que le bus et le chauffeur sont en service
        UPDATE BUS
        SET status = 'IN_SERVICE'
        WHERE id_bus = :NEW.id_bus;
        
        UPDATE DRIVER
        SET status = 'IN_SERVICE'
        WHERE id_driver = :NEW.id_driver;
        
    -- Si le voyage passe à DELAYED
    ELSIF :NEW.status = 'DELAYED' AND :OLD.status != 'DELAYED' THEN
        
        -- Notifier le retard (simulation via log)
        DBMS_OUTPUT.PUT_LINE('ALERTE: Voyage ' || :NEW.id_trip || ' en retard');
        
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20718, 
            'Erreur mise à jour statuts: ' || SQLERRM);
END TRG_UPDATE_ENTITIES_STATUS;
/

-- ============================================================================
-- FIN DES TRIGGERS
-- ============================================================================