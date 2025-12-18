-- Create LINE_STATION table
CREATE TABLE LINE_STATION (
    id_line                    NUMBER(10)     NOT NULL,
    id_station                 NUMBER(10)     NOT NULL,
    stop_order                 NUMBER(5)      NOT NULL,
    distance_from_start_km     DECIMAL(6, 2),
    CONSTRAINT pk_line_station PRIMARY KEY (id_line, id_station),
    CONSTRAINT uk_line_station_order UNIQUE (id_line, stop_order),
    CONSTRAINT fk_ls_line FOREIGN KEY (id_line) REFERENCES BUS_LINE (id_line),
    CONSTRAINT fk_ls_station FOREIGN KEY (id_station) REFERENCES STATION (id_station)
);

-- Verify table creation
SELECT table_name FROM user_tables WHERE table_name = 'LINE_STATION';
