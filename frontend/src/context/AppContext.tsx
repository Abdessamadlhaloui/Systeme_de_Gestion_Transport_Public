import { createContext, useContext, useState, ReactNode, useEffect } from 'react';
import { api } from '../utils/api';
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

  // ✅ Fetch Cities
  const fetchCities = async () => {
    try {
      const response = await api.from('cities').select('*');
      if (response.data && Array.isArray(response.data)) {
        const sorted = [...response.data].sort((a, b) => 
          (a.name || '').localeCompare(b.name || '')
        );
        setCities(sorted);
      }
    } catch (error) {
      console.error('Error fetching cities:', error);
    }
  };

  // ✅ Fetch Stations - ENRICHI AVEC LES DONNÉES DES VILLES
  const fetchStations = async () => {
    try {
      const response = await api.from('stations').select('*');
      if (response.data && Array.isArray(response.data)) {
        // Enrichir chaque station avec les données de sa ville
        const enrichedStations = response.data.map(station => {
          const cityId = station.city_id || station.CITY_ID;
          const city = cities.find(c => 
            (c.id_city || c.ID_CITY || c.id) === cityId
          );
          
          return {
            ...station,
            city: city || null
          };
        });
        
        const sorted = enrichedStations.sort((a, b) => 
          (a.name || '').localeCompare(b.name || '')
        );
        setStations(sorted);
      }
    } catch (error) {
      console.error('Error fetching stations:', error);
    }
  };

  // ✅ Fetch Bus Lines - ENRICHI AVEC LES DONNÉES DES STATIONS
  const fetchBusLines = async () => {
    try {
      const response = await api.from('bus_lines').select('*');
      if (response.data && Array.isArray(response.data)) {
        // Enrichir chaque ligne avec les données des stations
        const enrichedLines = response.data.map(line => {
          const originId = line.origin_station_id || line.ORIGIN_STATION_ID;
          const destId = line.destination_station_id || line.DESTINATION_STATION_ID;
          
          const originStation = stations.find(s => 
            (s.id_station || s.ID_STATION || s.id) === originId
          );
          const destStation = stations.find(s => 
            (s.id_station || s.ID_STATION || s.id) === destId
          );
          
          return {
            ...line,
            origin_station: originStation || null,
            destination_station: destStation || null
          };
        });
        
        const sorted = enrichedLines.sort((a, b) => 
          (a.name || '').localeCompare(b.name || '')
        );
        setBusLines(sorted);
      }
    } catch (error) {
      console.error('Error fetching bus lines:', error);
    }
  };

  // ✅ Fetch Buses
  const fetchBuses = async () => {
    try {
      const response = await api.from('buses').select('*');
      if (response.data && Array.isArray(response.data)) {
        const sorted = [...response.data].sort((a, b) => 
          (a.plate_number || '').localeCompare(b.plate_number || '')
        );
        setBuses(sorted);
      }
    } catch (error) {
      console.error('Error fetching buses:', error);
    }
  };

  // ✅ Fetch Drivers
  const fetchDrivers = async () => {
    try {
      const response = await api.from('drivers').select('*');
      if (response.data && Array.isArray(response.data)) {
        const sorted = [...response.data].sort((a, b) => 
          (a.name || '').localeCompare(b.name || '')
        );
        setDrivers(sorted);
      }
    } catch (error) {
      console.error('Error fetching drivers:', error);
    }
  };

  // ✅ Fetch Trips
  const fetchTrips = async () => {
    try {
      const response = await api.from('trips').select('*');
      if (response.data && Array.isArray(response.data)) {
        const sorted = [...response.data].sort((a, b) => 
          new Date(b.departure_time).getTime() - new Date(a.departure_time).getTime()
        );
        setTrips(sorted);
      }
    } catch (error) {
      console.error('Error fetching trips:', error);
    }
  };

  // ✅ Fetch Tickets
  const fetchTickets = async () => {
    try {
      const response = await api.from('tickets').select('*');
      if (response.data && Array.isArray(response.data)) {
        const sorted = [...response.data].sort((a, b) => 
          new Date(b.booking_date).getTime() - new Date(a.booking_date).getTime()
        );
        setTickets(sorted);
      }
    } catch (error) {
      console.error('Error fetching tickets:', error);
    }
  };

  // ✅ Fetch Subscriptions
  const fetchSubscriptions = async () => {
    try {
      const response = await api.from('subscriptions').select('*');
      if (response.data && Array.isArray(response.data)) {
        const sorted = [...response.data].sort((a, b) => 
          new Date(b.start_date).getTime() - new Date(a.start_date).getTime()
        );
        setSubscriptions(sorted);
      }
    } catch (error) {
      console.error('Error fetching subscriptions:', error);
    }
  };

  // ✅ Fetch Maintenance
  const fetchMaintenance = async () => {
    try {
      const response = await api.from('maintenance').select('*');
      if (response.data && Array.isArray(response.data)) {
        const sorted = [...response.data].sort((a, b) => 
          new Date(b.scheduled_date).getTime() - new Date(a.scheduled_date).getTime()
        );
        setMaintenance(sorted);
      }
    } catch (error) {
      console.error('Error fetching maintenance:', error);
    }
  };

  // ✅ Fetch Incidents
  const fetchIncidents = async () => {
    try {
      const response = await api.from('incidents').select('*');
      if (response.data && Array.isArray(response.data)) {
        const sorted = [...response.data].sort((a, b) => 
          new Date(b.incident_date).getTime() - new Date(a.incident_date).getTime()
        );
        setIncidents(sorted);
      }
    } catch (error) {
      console.error('Error fetching incidents:', error);
    }
  };

  // ✅ Fetch Dashboard Stats
  const fetchDashboardStats = async () => {
    try {
      const [busesData, tripsData, ticketsData, incidentsData, maintenanceData] =
        await Promise.all([
          api.from('buses').select('*'),
          api.from('trips').select('*'),
          api.from('tickets').select('*'),
          api.from('incidents').select('*'),
          api.from('maintenance').select('*'),
        ]);

      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const todayStart = today.getTime();
      const todayEnd = todayStart + 24 * 60 * 60 * 1000 - 1;

      // Helper function to parse date from various formats
      const parseDate = (dateStr: string | null | undefined): Date | null => {
        if (!dateStr) return null;
        try {
          // Handle Oracle format DD/MM/YYYY
          if (/^\d{2}\/\d{2}\/\d{4}$/.test(dateStr)) {
            const [day, month, year] = dateStr.split('/');
            return new Date(parseInt(year), parseInt(month) - 1, parseInt(day));
          }
          // Handle ISO format YYYY-MM-DD
          if (/^\d{4}-\d{2}-\d{2}/.test(dateStr)) {
            return new Date(dateStr.split('T')[0]);
          }
          // Try standard Date parsing
          const parsed = new Date(dateStr);
          if (!Number.isNaN(parsed.getTime())) {
            return parsed;
          }
        } catch (error) {
          console.error('Error parsing date:', dateStr, error);
        }
        return null;
      };

      // Helper function to check if date is today
      const isToday = (dateStr: string | null | undefined): boolean => {
        const date = parseDate(dateStr);
        if (!date) return false;
        date.setHours(0, 0, 0, 0);
        const dateTime = date.getTime();
        return dateTime >= todayStart && dateTime < todayEnd;
      };

      const activeBuses =
        busesData.data?.filter((b) => (b.status || b.STATUS) === 'available' || (b.status || b.STATUS) === 'in_service')
          .length || 0;

      const openIncidents =
        incidentsData.data?.filter((i) => (i.status || i.STATUS) === 'open' || (i.status || i.STATUS) === 'investigating')
          .length || 0;

      const maintenancePending =
        maintenanceData.data?.filter((m) => (m.status || m.STATUS) === 'scheduled').length || 0;

      const todayTrips = tripsData.data?.filter((t) => {
        const depTime = t.departure_time || t.DEPARTURE_TIME;
        if (!depTime) return false;
        const depDate = parseDate(depTime);
        if (!depDate) return false;
        depDate.setHours(0, 0, 0, 0);
        return depDate.getTime() >= todayStart;
      }).length || 0;

      // Filter tickets booked today and calculate revenue
      const todayTickets = (ticketsData.data || []).filter((t) => {
        const bookingDate = t.booking_date || t.BOOKING_DATE;
        return isToday(bookingDate);
      });

      const todayRevenue = todayTickets.reduce((sum, ticket) => {
        const price = ticket.price || ticket.PRICE || 0;
        const priceNum = typeof price === 'number' ? price : Number(price);
        return sum + (Number.isNaN(priceNum) ? 0 : priceNum);
      }, 0);

      setDashboardStats({
        totalBuses: busesData.data?.length || 0,
        activeBuses,
        totalTrips: tripsData.data?.length || 0,
        todayTrips,
        totalTickets: ticketsData.data?.length || 0,
        todayRevenue,
        openIncidents,
        maintenancePending,
      });
    } catch (error) {
      console.error('Error fetching dashboard stats:', error);
    }
  };

  // ✅ Generic fetch function
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
    if (fetchFn) {
      await fetchFn();
      // Auto-refresh dashboard stats when tickets are updated
      if (entity === 'tickets') {
        await fetchDashboardStats();
      }
    }
  };

  // ✅ Refresh all data
  const refreshAll = async () => {
    setLoading(true);
    try {
      // Charger les villes d'abord
      await fetchCities();
      
      // Attendre un peu pour s'assurer que les villes sont dans le state
      await new Promise(resolve => setTimeout(resolve, 100));
      
      // Ensuite charger tout le reste
      await Promise.all([
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
    } catch (error) {
      console.error('Error refreshing data:', error);
    } finally {
      setLoading(false);
    }
  };

  // ✅ Load data on mount
  useEffect(() => {
    refreshAll();
  }, []);

  // ✅ Re-enrichir les stations quand les villes changent
  useEffect(() => {
    if (cities.length > 0 && stations.length > 0) {
      const enrichedStations = stations.map(station => {
        const cityId = station.city_id || station.CITY_ID;
        const city = cities.find(c => 
          (c.id_city || c.ID_CITY || c.id) === cityId
        );
        
        return {
          ...station,
          city: city || station.city
        };
      });
      
      setStations(enrichedStations);
    }
  }, [cities]);

  // ✅ Re-enrichir les bus lines quand les stations changent
  useEffect(() => {
    if (stations.length > 0 && busLines.length > 0) {
      const enrichedLines = busLines.map(line => {
        const originId = line.origin_station_id || line.ORIGIN_STATION_ID;
        const destId = line.destination_station_id || line.DESTINATION_STATION_ID;
        
        const originStation = stations.find(s => 
          (s.id_station || s.ID_STATION || s.id) === originId
        );
        const destStation = stations.find(s => 
          (s.id_station || s.ID_STATION || s.id) === destId
        );
        
        return {
          ...line,
          origin_station: originStation || line.origin_station,
          destination_station: destStation || line.destination_station
        };
      });
      
      setBusLines(enrichedLines);
    }
  }, [stations]);

  // ✅ Re-enrichir les maintenance records avec les bus
  useEffect(() => {
    if (buses.length > 0 && maintenance.length > 0) {
      // Check if enrichment is needed (if any item doesn't have bus populated)
      const needsEnrichment = maintenance.some(item => {
        const busId = item.bus_id || item.BUS_ID;
        return busId && !item.bus;
      });
      
      if (!needsEnrichment) return;
      
      const enrichedMaintenance = maintenance.map(item => {
        // Skip if already enriched
        if (item.bus) return item;
        
        const busId = item.bus_id || item.BUS_ID;
        if (!busId) return item;
        
        const bus = buses.find(b => {
          const bId = b.id_bus || b.ID_BUS || b.id || b.ID;
          return String(bId) === String(busId);
        });
        
        return {
          ...item,
          bus: bus || item.bus
        };
      });
      
      // Only update if there are actual changes to avoid infinite loops
      const hasChanges = enrichedMaintenance.some((item, index) => 
        item.bus !== maintenance[index]?.bus
      );
      
      if (hasChanges) {
        setMaintenance(enrichedMaintenance);
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [buses]);

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