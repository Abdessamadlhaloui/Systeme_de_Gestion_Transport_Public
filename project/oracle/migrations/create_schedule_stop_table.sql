-- Create SCHEDULE_STOP table
CREATE TABLE SCHEDULE_STOP (
    id_schedule            NUMBER(10)     NOT NULL,
    id_station             NUMBER(10)     NOT NULL,
    scheduled_stop_time    VARCHAR2(10)   NOT NULL,
    CONSTRAINT pk_schedule_stop PRIMARY KEY (id_schedule, id_station),
    CONSTRAINT fk_ss_schedule FOREIGN KEY (id_schedule) REFERENCES SCHEDULE (id_schedule),
    CONSTRAINT fk_ss_station FOREIGN KEY (id_station) REFERENCES STATION (id_station)
);

-- Verify table creation
SELECT table_name FROM user_tables WHERE table_name = 'SCHEDULE_STOP';
