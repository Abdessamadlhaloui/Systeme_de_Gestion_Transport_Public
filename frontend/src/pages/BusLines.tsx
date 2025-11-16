import { useState } from 'react';
import { PageLayout } from '../components/PageLayout';
import { Table, StatusBadge } from '../components/Table';
import { Button } from '../components/Button';
import { Modal } from '../components/Modal';
import { FormInput, FormSelect } from '../components/FormInput';
import { useToast } from '../components/Toast';
import { useApp } from '../context/AppContext';
import { Plus } from 'lucide-react';
import { supabase } from '../utils/supabase';
import { BusLine } from '../types';

export function BusLines() {
  const { busLines, stations, fetchData } = useApp();
  const { showToast } = useToast();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBusLine, setEditingBusLine] = useState<BusLine | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    code: '',
    origin_station_id: '',
    destination_station_id: '',
    distance_km: '',
    duration_minutes: '',
    status: 'active',
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const payload = {
        ...formData,
        distance_km: parseFloat(formData.distance_km),
        duration_minutes: parseInt(formData.duration_minutes),
      };

      if (editingBusLine) {
        const { error } = await supabase
          .from('bus_lines')
          .update(payload)
          .eq('id', editingBusLine.id);
        if (error) throw error;
        showToast('Bus line updated successfully', 'success');
      } else {
        const { error } = await supabase.from('bus_lines').insert([payload]);
        if (error) throw error;
        showToast('Bus line created successfully', 'success');
      }
      await fetchData('busLines');
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
      name: '',
      code: '',
      origin_station_id: '',
      destination_station_id: '',
      distance_km: '',
      duration_minutes: '',
      status: 'active',
    });
    setEditingBusLine(null);
  };

  const handleEdit = (busLine: BusLine) => {
    setEditingBusLine(busLine);
    setFormData({
      name: busLine.name,
      code: busLine.code,
      origin_station_id: busLine.origin_station_id,
      destination_station_id: busLine.destination_station_id,
      distance_km: busLine.distance_km.toString(),
      duration_minutes: busLine.duration_minutes.toString(),
      status: busLine.status,
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (busLine: BusLine) => {
    if (!confirm('Are you sure you want to delete this bus line?')) return;

    try {
      const { error } = await supabase.from('bus_lines').delete().eq('id', busLine.id);
      if (error) throw error;
      showToast('Bus line deleted successfully', 'success');
      await fetchData('busLines');
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    }
  };

  const columns = [
    { key: 'code', label: 'Code', sortable: true },
    { key: 'name', label: 'Name', sortable: true },
    {
      key: 'origin',
      label: 'Origin',
      render: (line: BusLine) => line.origin_station?.name || '-',
    },
    {
      key: 'destination',
      label: 'Destination',
      render: (line: BusLine) => line.destination_station?.name || '-',
    },
    {
      key: 'distance_km',
      label: 'Distance (km)',
      sortable: true,
      render: (line: BusLine) => `${line.distance_km} km`,
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (line: BusLine) => <StatusBadge status={line.status} />,
    },
  ];

  const stationOptions = [
    { value: '', label: 'Select a station' },
    ...stations.map((station) => ({
      value: station.id,
      label: `${station.name} (${station.city?.name})`,
    })),
  ];

  const statusOptions = [
    { value: 'active', label: 'Active' },
    { value: 'inactive', label: 'Inactive' },
    { value: 'maintenance', label: 'Maintenance' },
  ];

  return (
    <PageLayout
      title="Bus Lines"
      description="Manage routes and bus lines"
      actions={
        <Button
          variant="primary"
          onClick={() => {
            resetForm();
            setIsModalOpen(true);
          }}
        >
          <Plus className="w-5 h-5" />
          Add Bus Line
        </Button>
      }
    >
      <Table
        data={busLines}
        columns={columns}
        onEdit={handleEdit}
        onDelete={handleDelete}
        searchPlaceholder="Search bus lines..."
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          resetForm();
        }}
        title={editingBusLine ? 'Edit Bus Line' : 'Add New Bus Line'}
        size="lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <FormInput
              label="Line Code"
              value={formData.code}
              onChange={(e) => setFormData({ ...formData, code: e.target.value })}
              placeholder="e.g., L101"
              required
            />
            <FormInput
              label="Line Name"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              required
            />
          </div>
          <FormSelect
            label="Origin Station"
            value={formData.origin_station_id}
            onChange={(e) => setFormData({ ...formData, origin_station_id: e.target.value })}
            options={stationOptions}
            required
          />
          <FormSelect
            label="Destination Station"
            value={formData.destination_station_id}
            onChange={(e) =>
              setFormData({ ...formData, destination_station_id: e.target.value })
            }
            options={stationOptions}
            required
          />
          <div className="grid grid-cols-2 gap-4">
            <FormInput
              label="Distance (km)"
              type="number"
              step="0.1"
              value={formData.distance_km}
              onChange={(e) => setFormData({ ...formData, distance_km: e.target.value })}
              required
            />
            <FormInput
              label="Duration (minutes)"
              type="number"
              value={formData.duration_minutes}
              onChange={(e) => setFormData({ ...formData, duration_minutes: e.target.value })}
              required
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
              {editingBusLine ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>
    </PageLayout>
  );
}
