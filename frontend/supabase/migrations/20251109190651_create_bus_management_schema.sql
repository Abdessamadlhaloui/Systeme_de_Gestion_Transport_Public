/*
  # Bus Management System Database Schema

  1. New Tables
    - `cities`
      - `id` (uuid, primary key)
      - `name` (text, city name)
      - `country` (text, country name)
      - `created_at` (timestamptz, creation timestamp)
    
    - `stations`
      - `id` (uuid, primary key)
      - `name` (text, station name)
      - `city_id` (uuid, foreign key to cities)
      - `address` (text, station address)
      - `latitude` (numeric, optional GPS coordinate)
      - `longitude` (numeric, optional GPS coordinate)
      - `created_at` (timestamptz)
    
    - `bus_lines`
      - `id` (uuid, primary key)
      - `name` (text, line name)
      - `code` (text, unique line code)
      - `origin_station_id` (uuid, foreign key to stations)
      - `destination_station_id` (uuid, foreign key to stations)
      - `distance_km` (numeric, route distance)
      - `duration_minutes` (integer, estimated duration)
      - `status` (text, active/inactive/maintenance)
      - `created_at` (timestamptz)
    
    - `buses`
      - `id` (uuid, primary key)
      - `plate_number` (text, unique plate number)
      - `model` (text, bus model)
      - `capacity` (integer, seating capacity)
      - `year` (integer, manufacturing year)
      - `status` (text, available/in_service/maintenance/retired)
      - `last_maintenance_date` (date, optional)
      - `created_at` (timestamptz)
    
    - `drivers`
      - `id` (uuid, primary key)
      - `name` (text, driver name)
      - `email` (text, unique email)
      - `phone` (text, contact number)
      - `license_number` (text, unique license)
      - `license_expiry` (date, license expiration)
      - `status` (text, active/inactive/on_leave)
      - `created_at` (timestamptz)
    
    - `trips`
      - `id` (uuid, primary key)
      - `bus_line_id` (uuid, foreign key to bus_lines)
      - `bus_id` (uuid, foreign key to buses)
      - `driver_id` (uuid, foreign key to drivers)
      - `departure_time` (timestamptz, scheduled departure)
      - `arrival_time` (timestamptz, scheduled arrival)
      - `status` (text, scheduled/in_progress/completed/cancelled)
      - `available_seats` (integer, remaining seats)
      - `price` (numeric, ticket price)
      - `created_at` (timestamptz)
    
    - `tickets`
      - `id` (uuid, primary key)
      - `trip_id` (uuid, foreign key to trips)
      - `passenger_name` (text, passenger name)
      - `passenger_email` (text, passenger email)
      - `passenger_phone` (text, passenger phone)
      - `seat_number` (text, assigned seat)
      - `price` (numeric, ticket price)
      - `status` (text, booked/confirmed/cancelled/used)
      - `booking_date` (date, booking date)
      - `created_at` (timestamptz)
    
    - `subscriptions`
      - `id` (uuid, primary key)
      - `user_name` (text, subscriber name)
      - `user_email` (text, subscriber email)
      - `bus_line_id` (uuid, foreign key to bus_lines)
      - `type` (text, weekly/monthly/yearly)
      - `start_date` (date, subscription start)
      - `end_date` (date, subscription end)
      - `price` (numeric, subscription price)
      - `status` (text, active/expired/cancelled)
      - `created_at` (timestamptz)
    
    - `maintenance`
      - `id` (uuid, primary key)
      - `bus_id` (uuid, foreign key to buses)
      - `type` (text, routine/repair/inspection)
      - `description` (text, maintenance details)
      - `scheduled_date` (date, scheduled date)
      - `completed_date` (date, optional completion date)
      - `cost` (numeric, maintenance cost)
      - `status` (text, scheduled/in_progress/completed)
      - `created_at` (timestamptz)
    
    - `incidents`
      - `id` (uuid, primary key)
      - `trip_id` (uuid, optional foreign key to trips)
      - `bus_id` (uuid, foreign key to buses)
      - `driver_id` (uuid, optional foreign key to drivers)
      - `type` (text, accident/breakdown/delay/other)
      - `description` (text, incident details)
      - `severity` (text, low/medium/high/critical)
      - `incident_date` (date, incident date)
      - `resolved_date` (date, optional resolution date)
      - `status` (text, open/investigating/resolved)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Add policies for public access (no authentication required for demo)
    - In production, these policies should be restricted to authenticated users

  3. Important Notes
    - All tables use UUID primary keys with automatic generation
    - Foreign key constraints ensure referential integrity
    - Default timestamps for record creation tracking
    - Status fields use text for flexibility
    - Indexes on foreign keys for query performance
*/

-- Create cities table
CREATE TABLE IF NOT EXISTS cities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  country text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create stations table
CREATE TABLE IF NOT EXISTS stations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  city_id uuid NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
  address text NOT NULL,
  latitude numeric,
  longitude numeric,
  created_at timestamptz DEFAULT now()
);

-- Create bus_lines table
CREATE TABLE IF NOT EXISTS bus_lines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  code text UNIQUE NOT NULL,
  origin_station_id uuid NOT NULL REFERENCES stations(id) ON DELETE RESTRICT,
  destination_station_id uuid NOT NULL REFERENCES stations(id) ON DELETE RESTRICT,
  distance_km numeric NOT NULL,
  duration_minutes integer NOT NULL,
  status text DEFAULT 'active' NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create buses table
CREATE TABLE IF NOT EXISTS buses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plate_number text UNIQUE NOT NULL,
  model text NOT NULL,
  capacity integer NOT NULL,
  year integer NOT NULL,
  status text DEFAULT 'available' NOT NULL,
  last_maintenance_date date,
  created_at timestamptz DEFAULT now()
);

-- Create drivers table
CREATE TABLE IF NOT EXISTS drivers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text UNIQUE NOT NULL,
  phone text NOT NULL,
  license_number text UNIQUE NOT NULL,
  license_expiry date NOT NULL,
  status text DEFAULT 'active' NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create trips table
CREATE TABLE IF NOT EXISTS trips (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bus_line_id uuid NOT NULL REFERENCES bus_lines(id) ON DELETE CASCADE,
  bus_id uuid NOT NULL REFERENCES buses(id) ON DELETE RESTRICT,
  driver_id uuid NOT NULL REFERENCES drivers(id) ON DELETE RESTRICT,
  departure_time timestamptz NOT NULL,
  arrival_time timestamptz NOT NULL,
  status text DEFAULT 'scheduled' NOT NULL,
  available_seats integer NOT NULL,
  price numeric NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create tickets table
CREATE TABLE IF NOT EXISTS tickets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id uuid NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  passenger_name text NOT NULL,
  passenger_email text NOT NULL,
  passenger_phone text NOT NULL,
  seat_number text NOT NULL,
  price numeric NOT NULL,
  status text DEFAULT 'booked' NOT NULL,
  booking_date date NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create subscriptions table
CREATE TABLE IF NOT EXISTS subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_name text NOT NULL,
  user_email text NOT NULL,
  bus_line_id uuid NOT NULL REFERENCES bus_lines(id) ON DELETE CASCADE,
  type text NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  price numeric NOT NULL,
  status text DEFAULT 'active' NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create maintenance table
CREATE TABLE IF NOT EXISTS maintenance (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bus_id uuid NOT NULL REFERENCES buses(id) ON DELETE CASCADE,
  type text NOT NULL,
  description text NOT NULL,
  scheduled_date date NOT NULL,
  completed_date date,
  cost numeric NOT NULL,
  status text DEFAULT 'scheduled' NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create incidents table
CREATE TABLE IF NOT EXISTS incidents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id uuid REFERENCES trips(id) ON DELETE SET NULL,
  bus_id uuid NOT NULL REFERENCES buses(id) ON DELETE CASCADE,
  driver_id uuid REFERENCES drivers(id) ON DELETE SET NULL,
  type text NOT NULL,
  description text NOT NULL,
  severity text NOT NULL,
  incident_date date NOT NULL,
  resolved_date date,
  status text DEFAULT 'open' NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for foreign keys
CREATE INDEX IF NOT EXISTS idx_stations_city_id ON stations(city_id);
CREATE INDEX IF NOT EXISTS idx_bus_lines_origin ON bus_lines(origin_station_id);
CREATE INDEX IF NOT EXISTS idx_bus_lines_destination ON bus_lines(destination_station_id);
CREATE INDEX IF NOT EXISTS idx_trips_bus_line ON trips(bus_line_id);
CREATE INDEX IF NOT EXISTS idx_trips_bus ON trips(bus_id);
CREATE INDEX IF NOT EXISTS idx_trips_driver ON trips(driver_id);
CREATE INDEX IF NOT EXISTS idx_tickets_trip ON tickets(trip_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_bus_line ON subscriptions(bus_line_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_bus ON maintenance(bus_id);
CREATE INDEX IF NOT EXISTS idx_incidents_trip ON incidents(trip_id);
CREATE INDEX IF NOT EXISTS idx_incidents_bus ON incidents(bus_id);
CREATE INDEX IF NOT EXISTS idx_incidents_driver ON incidents(driver_id);

-- Enable Row Level Security
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE stations ENABLE ROW LEVEL SECURITY;
ALTER TABLE bus_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE buses ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance ENABLE ROW LEVEL SECURITY;
ALTER TABLE incidents ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (demo purposes)
-- In production, restrict these to authenticated users

CREATE POLICY "Public can view cities" ON cities FOR SELECT USING (true);
CREATE POLICY "Public can insert cities" ON cities FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can update cities" ON cities FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Public can delete cities" ON cities FOR DELETE USING (true);

CREATE POLICY "Public can view stations" ON stations FOR SELECT USING (true);
CREATE POLICY "Public can insert stations" ON stations FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can update stations" ON stations FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Public can delete stations" ON stations FOR DELETE USING (true);

CREATE POLICY "Public can view bus_lines" ON bus_lines FOR SELECT USING (true);
CREATE POLICY "Public can insert bus_lines" ON bus_lines FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can update bus_lines" ON bus_lines FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Public can delete bus_lines" ON bus_lines FOR DELETE USING (true);

CREATE POLICY "Public can view buses" ON buses FOR SELECT USING (true);
CREATE POLICY "Public can insert buses" ON buses FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can update buses" ON buses FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Public can delete buses" ON buses FOR DELETE USING (true);

CREATE POLICY "Public can view drivers" ON drivers FOR SELECT USING (true);
CREATE POLICY "Public can insert drivers" ON drivers FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can update drivers" ON drivers FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Public can delete drivers" ON drivers FOR DELETE USING (true);

CREATE POLICY "Public can view trips" ON trips FOR SELECT USING (true);
CREATE POLICY "Public can insert trips" ON trips FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can update trips" ON trips FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Public can delete trips" ON trips FOR DELETE USING (true);

CREATE POLICY "Public can view tickets" ON tickets FOR SELECT USING (true);
CREATE POLICY "Public can insert tickets" ON tickets FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can update tickets" ON tickets FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Public can delete tickets" ON tickets FOR DELETE USING (true);

CREATE POLICY "Public can view subscriptions" ON subscriptions FOR SELECT USING (true);
CREATE POLICY "Public can insert subscriptions" ON subscriptions FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can update subscriptions" ON subscriptions FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Public can delete subscriptions" ON subscriptions FOR DELETE USING (true);

CREATE POLICY "Public can view maintenance" ON maintenance FOR SELECT USING (true);
CREATE POLICY "Public can insert maintenance" ON maintenance FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can update maintenance" ON maintenance FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Public can delete maintenance" ON maintenance FOR DELETE USING (true);

CREATE POLICY "Public can view incidents" ON incidents FOR SELECT USING (true);
CREATE POLICY "Public can insert incidents" ON incidents FOR INSERT WITH CHECK (true);
CREATE POLICY "Public can update incidents" ON incidents FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Public can delete incidents" ON incidents FOR DELETE USING (true);
