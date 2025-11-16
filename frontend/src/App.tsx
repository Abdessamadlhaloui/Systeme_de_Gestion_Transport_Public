import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AppProvider } from './context/AppContext';
import { ToastProvider } from './components/Toast';
import { Sidebar } from './components/Sidebar';
import { Dashboard } from './pages/Dashboard';
import { Cities } from './pages/Cities';
import { Stations } from './pages/Stations';
import { BusLines } from './pages/BusLines';
import { Buses } from './pages/Buses';
import { Drivers } from './pages/Drivers';
import { Trips } from './pages/Trips';
import { Tickets } from './pages/Tickets';
import { Subscriptions } from './pages/Subscriptions';
import { MaintenancePage } from './pages/Maintenance';
import { Incidents } from './pages/Incidents';

function App() {
  return (
    <Router>
      <ToastProvider>
        <AppProvider>
          <div className="flex min-h-screen bg-gray-50">
            <Sidebar />
            <main className="flex-1 overflow-auto">
              <Routes>
                <Route path="/" element={<Dashboard />} />
                <Route path="/cities" element={<Cities />} />
                <Route path="/stations" element={<Stations />} />
                <Route path="/bus-lines" element={<BusLines />} />
                <Route path="/buses" element={<Buses />} />
                <Route path="/drivers" element={<Drivers />} />
                <Route path="/trips" element={<Trips />} />
                <Route path="/tickets" element={<Tickets />} />
                <Route path="/subscriptions" element={<Subscriptions />} />
                <Route path="/maintenance" element={<MaintenancePage />} />
                <Route path="/incidents" element={<Incidents />} />
              </Routes>
            </main>
          </div>
        </AppProvider>
      </ToastProvider>
    </Router>
  );
}

export default App;
