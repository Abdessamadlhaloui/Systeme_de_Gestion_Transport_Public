import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AppProvider } from './context/AppContext';
import { ThemeProvider } from './context/ThemeContext';
import { ToastProvider } from './components/Toast';
import { Sidebar } from './components/Sidebar';
import HomePage from './pages/HomePage';
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

// Layout avec Sidebar pour les pages du dashboard
function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen bg-gray-50 dark:bg-gray-900">
      <Sidebar />
      <main className="flex-1 overflow-auto">
        {children}
      </main>
    </div>
  );
}

function App() {
  return (
    <Router>
      <ThemeProvider>
        <ToastProvider>
          <AppProvider>
          <Routes>
            {/* HomePage sans sidebar */}
            <Route path="/" element={<HomePage />} />
            
            {/* Routes du dashboard avec sidebar */}
            <Route path="/dashboard" element={
              <DashboardLayout>
                <Dashboard />
              </DashboardLayout>
            } />
            <Route path="/cities" element={
              <DashboardLayout>
                <Cities />
              </DashboardLayout>
            } />
            <Route path="/stations" element={
              <DashboardLayout>
                <Stations />
              </DashboardLayout>
            } />
            <Route path="/bus-lines" element={
              <DashboardLayout>
                <BusLines />
              </DashboardLayout>
            } />
            <Route path="/buses" element={
              <DashboardLayout>
                <Buses />
              </DashboardLayout>
            } />
            <Route path="/drivers" element={
              <DashboardLayout>
                <Drivers />
              </DashboardLayout>
            } />
            <Route path="/trips" element={
              <DashboardLayout>
                <Trips />
              </DashboardLayout>
            } />
            <Route path="/tickets" element={
              <DashboardLayout>
                <Tickets />
              </DashboardLayout>
            } />
            <Route path="/subscriptions" element={
              <DashboardLayout>
                <Subscriptions />
              </DashboardLayout>
            } />
            <Route path="/maintenance" element={
              <DashboardLayout>
                <MaintenancePage />
              </DashboardLayout>
            } />
            <Route path="/incidents" element={
              <DashboardLayout>
                <Incidents />
              </DashboardLayout>
            } />
          </Routes>
          </AppProvider>
        </ToastProvider>
      </ThemeProvider>
    </Router>
  );
}

export default App;