import { createContext, useContext, useState, ReactNode, useEffect } from 'react';
import { supabase } from '../utils/supabase';
import {
  City,
  Station,
  BusLine,
  Bus,
  Driver,
  Trip,
  Ticket,
  Subscription,
  Maintenance,
  Incident,
  DashboardStats,
} from '../types';

interface AppContextType {
  cities: City[];
  stations: Station[];
  busLines: BusLine[];
  buses: Bus[];
  drivers: Driver[];
  trips: Trip[];
  tickets: Ticket[];
  subscriptions: Subscription[];
  maintenance: Maintenance[];
  incidents: Incident[];
  dashboardStats: DashboardStats | null;
  loading: boolean;
  fetchData: (entity: string) => Promise<void>;
  refreshAll: () => Promise<void>;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export function AppProvider({ children }: { children: ReactNode }) {
  const [cities, setCities] = useState<City[]>([]);
  const [stations, setStations] = useState<Station[]>([]);
  const [busLines, setBusLines] = useState<BusLine[]>([]);
  const [buses, setBuses] = useState<Bus[]>([]);
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [trips, setTrips] = useState<Trip[]>([]);
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [subscriptions, setSubscriptions] = useState<Subscription[]>([]);
  const [maintenance, setMaintenance] = useState<Maintenance[]>([]);
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [dashboardStats, setDashboardStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchCities = async () => {
    const { data } = await supabase.from('cities').select('*').order('name');
    if (data) setCities(data);
  };

  const fetchStations = async () => {
    const { data } = await supabase
      .from('stations')
      .select('*, city:cities(*)')
      .order('name');
    if (data) setStations(data);
  };

  const fetchBusLines = async () => {
    const { data } = await supabase
      .from('bus_lines')
      .select('*, origin_station:stations!origin_station_id(*), destination_station:stations!destination_station_id(*)')
      .order('name');
    if (data) setBusLines(data);
  };

  const fetchBuses = async () => {
    const { data } = await supabase.from('buses').select('*').order('plate_number');
    if (data) setBuses(data);
  };

  const fetchDrivers = async () => {
    const { data } = await supabase.from('drivers').select('*').order('name');
    if (data) setDrivers(data);
  };

  const fetchTrips = async () => {
    const { data } = await supabase
      .from('trips')
      .select('*, bus_line:bus_lines(*), bus:buses(*), driver:drivers(*)')
      .order('departure_time', { ascending: false });
    if (data) setTrips(data);
  };

  const fetchTickets = async () => {
    const { data } = await supabase
      .from('tickets')
      .select('*, trip:trips(*, bus_line:bus_lines(*))')
      .order('booking_date', { ascending: false });
    if (data) setTickets(data);
  };

  const fetchSubscriptions = async () => {
    const { data } = await supabase
      .from('subscriptions')
      .select('*, bus_line:bus_lines(*)')
      .order('start_date', { ascending: false });
    if (data) setSubscriptions(data);
  };

  const fetchMaintenance = async () => {
    const { data } = await supabase
      .from('maintenance')
      .select('*, bus:buses(*)')
      .order('scheduled_date', { ascending: false });
    if (data) setMaintenance(data);
  };

  const fetchIncidents = async () => {
    const { data } = await supabase
      .from('incidents')
      .select('*, trip:trips(*), bus:buses(*), driver:drivers(*)')
      .order('incident_date', { ascending: false });
    if (data) setIncidents(data);
  };

  const fetchDashboardStats = async () => {
    const [busesCount, tripsCount, ticketsCount, incidentsCount, maintenanceCount] =
      await Promise.all([
        supabase.from('buses').select('status', { count: 'exact' }),
        supabase.from('trips').select('*', { count: 'exact' }),
        supabase.from('tickets').select('price', { count: 'exact' }),
        supabase.from('incidents').select('status', { count: 'exact' }),
        supabase.from('maintenance').select('status', { count: 'exact' }),
      ]);

    const today = new Date().toISOString().split('T')[0];
    const [todayTrips, todayTickets] = await Promise.all([
      supabase
        .from('trips')
        .select('*', { count: 'exact' })
        .gte('departure_time', today),
      supabase.from('tickets').select('price').gte('booking_date', today),
    ]);

    const activeBuses =
      busesCount.data?.filter((b) => b.status === 'available' || b.status === 'in_service')
        .length || 0;

    const openIncidents =
      incidentsCount.data?.filter((i) => i.status === 'open' || i.status === 'investigating')
        .length || 0;

    const maintenancePending =
      maintenanceCount.data?.filter((m) => m.status === 'scheduled').length || 0;

    const todayRevenue =
      todayTickets.data?.reduce((sum, ticket) => sum + (ticket.price || 0), 0) || 0;

    setDashboardStats({
      totalBuses: busesCount.count || 0,
      activeBuses,
      totalTrips: tripsCount.count || 0,
      todayTrips: todayTrips.count || 0,
      totalTickets: ticketsCount.count || 0,
      todayRevenue,
      openIncidents,
      maintenancePending,
    });
  };

  const fetchData = async (entity: string) => {
    const fetchMap: Record<string, () => Promise<void>> = {
      cities: fetchCities,
      stations: fetchStations,
      busLines: fetchBusLines,
      buses: fetchBuses,
      drivers: fetchDrivers,
      trips: fetchTrips,
      tickets: fetchTickets,
      subscriptions: fetchSubscriptions,
      maintenance: fetchMaintenance,
      incidents: fetchIncidents,
      dashboard: fetchDashboardStats,
    };

    const fetchFn = fetchMap[entity];
    if (fetchFn) await fetchFn();
  };

  const refreshAll = async () => {
    setLoading(true);
    await Promise.all([
      fetchCities(),
      fetchStations(),
      fetchBusLines(),
      fetchBuses(),
      fetchDrivers(),
      fetchTrips(),
      fetchTickets(),
      fetchSubscriptions(),
      fetchMaintenance(),
      fetchIncidents(),
      fetchDashboardStats(),
    ]);
    setLoading(false);
  };

  useEffect(() => {
    refreshAll();
  }, []);

  return (
    <AppContext.Provider
      value={{
        cities,
        stations,
        busLines,
        buses,
        drivers,
        trips,
        tickets,
        subscriptions,
        maintenance,
        incidents,
        dashboardStats,
        loading,
        fetchData,
        refreshAll,
      }}
    >
      {children}
    </AppContext.Provider>
  );
}

export function useApp() {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within AppProvider');
  }
  return context;
}
