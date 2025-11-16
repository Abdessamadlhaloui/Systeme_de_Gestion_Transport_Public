import { useState } from 'react';
import { PageLayout } from '../components/PageLayout';
import { Table, StatusBadge } from '../components/Table';
import { Button } from '../components/Button';
import { Modal } from '../components/Modal';
import { FormInput, FormSelect, FormTextarea } from '../components/FormInput';
import { useToast } from '../components/Toast';
import { useApp } from '../context/AppContext';
import { Plus } from 'lucide-react';
import { supabase } from '../utils/supabase';
import { Incident } from '../types';

export function Incidents() {
  const { incidents, trips, buses, drivers, fetchData } = useApp();
  const { showToast } = useToast();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingIncident, setEditingIncident] = useState<Incident | null>(null);
  const [formData, setFormData] = useState({
    trip_id: '',
    bus_id: '',
    driver_id: '',
    type: 'delay',
    description: '',
    severity: 'low',
    incident_date: '',
    resolved_date: '',
    status: 'open',
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const payload = {
        ...formData,
        trip_id: formData.trip_id || null,
        driver_id: formData.driver_id || null,
        resolved_date: formData.resolved_date || null,
      };

      if (editingIncident) {
        const { error } = await supabase
          .from('incidents')
          .update(payload)
          .eq('id', editingIncident.id);
        if (error) throw error;
        showToast('Incident updated successfully', 'success');
      } else {
        const { error } = await supabase.from('incidents').insert([payload]);
        if (error) throw error;
        showToast('Incident reported successfully', 'success');
      }
      await fetchData('incidents');
      setIsModalOpen(false);
      resetForm();
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    } finally {
      setLoading(false);
    }
  };

  const resetForm = () => {
    setFormData({
      trip_id: '',
      bus_id: '',
      driver_id: '',
      type: 'delay',
      description: '',
      severity: 'low',
      incident_date: '',
      resolved_date: '',
      status: 'open',
    });
    setEditingIncident(null);
  };

  const handleEdit = (incident: Incident) => {
    setEditingIncident(incident);
    setFormData({
      trip_id: incident.trip_id || '',
      bus_id: incident.bus_id,
      driver_id: incident.driver_id || '',
      type: incident.type,
      description: incident.description,
      severity: incident.severity,
      incident_date: incident.incident_date,
      resolved_date: incident.resolved_date || '',
      status: incident.status,
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (incident: Incident) => {
    if (!confirm('Are you sure you want to delete this incident?')) return;

    try {
      const { error } = await supabase.from('incidents').delete().eq('id', incident.id);
      if (error) throw error;
      showToast('Incident deleted successfully', 'success');
      await fetchData('incidents');
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    }
  };

  const columns = [
    { key: 'type', label: 'Type', sortable: true },
    {
      key: 'bus',
      label: 'Bus',
      render: (incident: Incident) => incident.bus?.plate_number || '-',
    },
    { key: 'description', label: 'Description' },
    {
      key: 'severity',
      label: 'Severity',
      sortable: true,
      render: (incident: Incident) => <StatusBadge status={incident.severity} type="severity" />,
    },
    {
      key: 'incident_date',
      label: 'Date',
      sortable: true,
      render: (incident: Incident) => new Date(incident.incident_date).toLocaleDateString(),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (incident: Incident) => <StatusBadge status={incident.status} />,
    },
  ];

  const tripOptions = [
    { value: '', label: 'None (Optional)' },
    ...trips.map((trip) => ({
      value: trip.id,
      label: `${trip.bus_line?.code} - ${new Date(trip.departure_time).toLocaleDateString()}`,
    })),
  ];

  const busOptions = [
    { value: '', label: 'Select a bus' },
    ...buses.map((bus) => ({ value: bus.id, label: `${bus.plate_number} (${bus.model})` })),
  ];

  const driverOptions = [
    { value: '', label: 'None (Optional)' },
    ...drivers.map((driver) => ({ value: driver.id, label: driver.name })),
  ];

  const typeOptions = [
    { value: 'accident', label: 'Accident' },
    { value: 'breakdown', label: 'Breakdown' },
    { value: 'delay', label: 'Delay' },
    { value: 'other', label: 'Other' },
  ];

  const severityOptions = [
    { value: 'low', label: 'Low' },
    { value: 'medium', label: 'Medium' },
    { value: 'high', label: 'High' },
    { value: 'critical', label: 'Critical' },
  ];

  const statusOptions = [
    { value: 'open', label: 'Open' },
    { value: 'investigating', label: 'Investigating' },
    { value: 'resolved', label: 'Resolved' },
  ];

  return (
    <PageLayout
      title="Incidents"
      description="Manage and track incidents"
      actions={
        <Button
          variant="primary"
          onClick={() => {
            resetForm();
            setIsModalOpen(true);
          }}
        >
          <Plus className="w-5 h-5" />
          Report Incident
        </Button>
      }
    >
      <Table
        data={incidents}
        columns={columns}
        onEdit={handleEdit}
        onDelete={handleDelete}
        searchPlaceholder="Search incidents..."
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          resetForm();
        }}
        title={editingIncident ? 'Edit Incident' : 'Report New Incident'}
        size="lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <FormSelect
              label="Type"
              value={formData.type}
              onChange={(e) => setFormData({ ...formData, type: e.target.value })}
              options={typeOptions}
              required
            />
            <FormSelect
              label="Severity"
              value={formData.severity}
              onChange={(e) => setFormData({ ...formData, severity: e.target.value })}
              options={severityOptions}
              required
            />
          </div>
          <FormSelect
            label="Bus"
            value={formData.bus_id}
            onChange={(e) => setFormData({ ...formData, bus_id: e.target.value })}
            options={busOptions}
            required
          />
          <div className="grid grid-cols-2 gap-4">
            <FormSelect
              label="Trip"
              value={formData.trip_id}
              onChange={(e) => setFormData({ ...formData, trip_id: e.target.value })}
              options={tripOptions}
            />
            <FormSelect
              label="Driver"
              value={formData.driver_id}
              onChange={(e) => setFormData({ ...formData, driver_id: e.target.value })}
              options={driverOptions}
            />
          </div>
          <FormTextarea
            label="Description"
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            required
          />
          <div className="grid grid-cols-2 gap-4">
            <FormInput
              label="Incident Date"
              type="date"
              value={formData.incident_date}
              onChange={(e) => setFormData({ ...formData, incident_date: e.target.value })}
              required
            />
            <FormInput
              label="Resolved Date"
              type="date"
              value={formData.resolved_date}
              onChange={(e) => setFormData({ ...formData, resolved_date: e.target.value })}
            />
          </div>
          <FormSelect
            label="Status"
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value })}
            options={statusOptions}
            required
          />
          <div className="flex gap-3 justify-end pt-4">
            <Button
              variant="secondary"
              type="button"
              onClick={() => {
                setIsModalOpen(false);
                resetForm();
              }}
            >
              Cancel
            </Button>
            <Button variant="primary" type="submit" loading={loading}>
              {editingIncident ? 'Update' : 'Report'}
            </Button>
          </div>
        </form>
      </Modal>
    </PageLayout>
  );
}
