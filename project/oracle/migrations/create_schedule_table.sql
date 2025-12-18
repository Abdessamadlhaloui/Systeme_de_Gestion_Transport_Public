-- Create SCHEDULE table
CREATE TABLE SCHEDULE (
    id_schedule      NUMBER(10)    NOT NULL,
    service_type     VARCHAR2(20)  NOT NULL,
    day_of_week      VARCHAR2(20),
    frequency_min    NUMBER(3),
    id_line          NUMBER(10)    NOT NULL,
    CONSTRAINT pk_schedule PRIMARY KEY (id_schedule),
    CONSTRAINT fk_schedule_bus_line FOREIGN KEY (id_line) REFERENCES BUS_LINE (id_line)
);

-- Create sequence for auto-increment
CREATE SEQUENCE seq_schedule
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Create trigger for auto-increment
CREATE OR REPLACE TRIGGER trg_schedule_id
BEFORE INSERT ON SCHEDULE
FOR EACH ROW
BEGIN
    IF :NEW.id_schedule IS NULL THEN
        SELECT seq_schedule.NEXTVAL INTO :NEW.id_schedule FROM DUAL;
    END IF;
END;
/

-- Verify table creation
SELECT table_name FROM user_tables WHERE table_name = 'SCHEDULE';
SELECT sequence_name FROM user_sequences WHERE sequence_name = 'SEQ_SCHEDULE';
