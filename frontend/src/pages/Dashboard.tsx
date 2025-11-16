import { PageLayout } from '../components/PageLayout';
import { StatCard } from '../components/StatCard';
import { useApp } from '../context/AppContext';
import { Bus, Calendar, Ticket, DollarSign, AlertTriangle, Wrench } from 'lucide-react';
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, LineChart, Line, Legend } from 'recharts';
import { motion } from 'framer-motion';

export function Dashboard() {
  const { dashboardStats, buses, trips, incidents, loading } = useApp();

  if (loading) {
    return (
      <PageLayout title="Dashboard" description="Overview of your bus management system">
        <div className="animate-pulse space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="h-32 bg-gray-200 rounded-xl" />
            ))}
          </div>
        </div>
      </PageLayout>
    );
  }

  const busStatusData = [
    { name: 'Available', value: buses.filter((b) => b.status === 'available').length, color: '#10b981' },
    { name: 'In Service', value: buses.filter((b) => b.status === 'in_service').length, color: '#3b82f6' },
    { name: 'Maintenance', value: buses.filter((b) => b.status === 'maintenance').length, color: '#f59e0b' },
    { name: 'Retired', value: buses.filter((b) => b.status === 'retired').length, color: '#6b7280' },
  ];

  const tripStatusData = [
    { name: 'Scheduled', value: trips.filter((t) => t.status === 'scheduled').length },
    { name: 'In Progress', value: trips.filter((t) => t.status === 'in_progress').length },
    { name: 'Completed', value: trips.filter((t) => t.status === 'completed').length },
    { name: 'Cancelled', value: trips.filter((t) => t.status === 'cancelled').length },
  ];

  const incidentSeverityData = [
    { name: 'Low', value: incidents.filter((i) => i.severity === 'low').length, color: '#3b82f6' },
    { name: 'Medium', value: incidents.filter((i) => i.severity === 'medium').length, color: '#f59e0b' },
    { name: 'High', value: incidents.filter((i) => i.severity === 'high').length, color: '#ef4444' },
    { name: 'Critical', value: incidents.filter((i) => i.severity === 'critical').length, color: '#991b1b' },
  ];

  const recentIncidents = incidents.slice(0, 5);

  return (
    <PageLayout title="Dashboard" description="Overview of your bus management system">
      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <StatCard
            title="Total Buses"
            value={dashboardStats?.totalBuses || 0}
            icon={Bus}
            color="blue"
          />
          <StatCard
            title="Active Buses"
            value={dashboardStats?.activeBuses || 0}
            icon={Bus}
            color="green"
          />
          <StatCard
            title="Today's Trips"
            value={dashboardStats?.todayTrips || 0}
            icon={Calendar}
            color="blue"
          />
          <StatCard
            title="Total Tickets"
            value={dashboardStats?.totalTickets || 0}
            icon={Ticket}
            color="purple"
          />
          <StatCard
            title="Today's Revenue"
            value={`$${dashboardStats?.todayRevenue.toFixed(2) || '0.00'}`}
            icon={DollarSign}
            color="green"
          />
          <StatCard
            title="Open Incidents"
            value={dashboardStats?.openIncidents || 0}
            icon={AlertTriangle}
            color="red"
          />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="bg-white p-6 rounded-xl shadow-sm border border-gray-200"
          >
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Bus Status Distribution</h3>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={busStatusData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {busStatusData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="bg-white p-6 rounded-xl shadow-sm border border-gray-200"
          >
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Trip Status Overview</h3>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={tripStatusData}>
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="value" fill="#3b82f6" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="bg-white p-6 rounded-xl shadow-sm border border-gray-200"
          >
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Incident Severity</h3>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={incidentSeverityData.filter((d) => d.value > 0)}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {incidentSeverityData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="bg-white p-6 rounded-xl shadow-sm border border-gray-200"
          >
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Incidents</h3>
            <div className="space-y-3">
              {recentIncidents.length === 0 ? (
                <p className="text-gray-500 text-center py-8">No recent incidents</p>
              ) : (
                recentIncidents.map((incident) => (
                  <div
                    key={incident.id}
                    className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
                  >
                    <AlertTriangle className={`w-5 h-5 flex-shrink-0 ${
                      incident.severity === 'critical' ? 'text-red-600' :
                      incident.severity === 'high' ? 'text-orange-600' :
                      incident.severity === 'medium' ? 'text-yellow-600' : 'text-blue-600'
                    }`} />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">{incident.type}</p>
                      <p className="text-xs text-gray-500 truncate">{incident.description}</p>
                    </div>
                    <span className={`text-xs px-2 py-1 rounded-full ${
                      incident.severity === 'critical' ? 'bg-red-100 text-red-800' :
                      incident.severity === 'high' ? 'bg-orange-100 text-orange-800' :
                      incident.severity === 'medium' ? 'bg-yellow-100 text-yellow-800' : 'bg-blue-100 text-blue-800'
                    }`}>
                      {incident.severity}
                    </span>
                  </div>
                ))
              )}
            </div>
          </motion.div>
        </div>
      </div>
    </PageLayout>
  );
}
