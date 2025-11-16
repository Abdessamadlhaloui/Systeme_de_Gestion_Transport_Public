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
import { Trip } from '../types';

export function Trips() {
  const { trips, busLines, buses, drivers, fetchData } = useApp();
  const { showToast } = useToast();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingTrip, setEditingTrip] = useState<Trip | null>(null);
  const [formData, setFormData] = useState({
    bus_line_id: '',
    bus_id: '',
    driver_id: '',
    departure_time: '',
    arrival_time: '',
    status: 'scheduled',
    available_seats: '',
    price: '',
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const payload = {
        ...formData,
        available_seats: parseInt(formData.available_seats),
        price: parseFloat(formData.price),
      };

      if (editingTrip) {
        const { error } = await supabase
          .from('trips')
          .update(payload)
          .eq('id', editingTrip.id);
        if (error) throw error;
        showToast('Trip updated successfully', 'success');
      } else {
        const { error } = await supabase.from('trips').insert([payload]);
        if (error) throw error;
        showToast('Trip created successfully', 'success');
      }
      await fetchData('trips');
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
      bus_line_id: '',
      bus_id: '',
      driver_id: '',
      departure_time: '',
      arrival_time: '',
      status: 'scheduled',
      available_seats: '',
      price: '',
    });
    setEditingTrip(null);
  };

  const handleEdit = (trip: Trip) => {
    setEditingTrip(trip);
    setFormData({
      bus_line_id: trip.bus_line_id,
      bus_id: trip.bus_id,
      driver_id: trip.driver_id,
      departure_time: trip.departure_time,
      arrival_time: trip.arrival_time,
      status: trip.status,
      available_seats: trip.available_seats.toString(),
      price: trip.price.toString(),
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (trip: Trip) => {
    if (!confirm('Are you sure you want to delete this trip?')) return;

    try {
      const { error } = await supabase.from('trips').delete().eq('id', trip.id);
      if (error) throw error;
      showToast('Trip deleted successfully', 'success');
      await fetchData('trips');
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    }
  };

  const columns = [
    {
      key: 'bus_line',
      label: 'Line',
      render: (trip: Trip) => trip.bus_line?.code || '-',
    },
    {
      key: 'bus',
      label: 'Bus',
      render: (trip: Trip) => trip.bus?.plate_number || '-',
    },
    {
      key: 'driver',
      label: 'Driver',
      render: (trip: Trip) => trip.driver?.name || '-',
    },
    {
      key: 'departure_time',
      label: 'Departure',
      sortable: true,
      render: (trip: Trip) => new Date(trip.departure_time).toLocaleString(),
    },
    {
      key: 'available_seats',
      label: 'Seats',
      sortable: true,
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (trip: Trip) => <StatusBadge status={trip.status} type="trip" />,
    },
  ];

  const busLineOptions = [
    { value: '', label: 'Select a bus line' },
    ...busLines.map((line) => ({ value: line.id, label: `${line.code} - ${line.name}` })),
  ];

  const busOptions = [
    { value: '', label: 'Select a bus' },
    ...buses
      .filter((bus) => bus.status === 'available' || bus.status === 'in_service')
      .map((bus) => ({ value: bus.id, label: `${bus.plate_number} (${bus.model})` })),
  ];

  const driverOptions = [
    { value: '', label: 'Select a driver' },
    ...drivers
      .filter((driver) => driver.status === 'active')
      .map((driver) => ({ value: driver.id, label: driver.name })),
  ];

  const statusOptions = [
    { value: 'scheduled', label: 'Scheduled' },
    { value: 'in_progress', label: 'In Progress' },
    { value: 'completed', label: 'Completed' },
    { value: 'cancelled', label: 'Cancelled' },
  ];

  return (
    <PageLayout
      title="Trips"
      description="Manage scheduled trips"
      actions={
        <Button
          variant="primary"
          onClick={() => {
            resetForm();
            setIsModalOpen(true);
          }}
        >
          <Plus className="w-5 h-5" />
          Add Trip
        </Button>
      }
    >
      <Table
        data={trips}
        columns={columns}
        onEdit={handleEdit}
        onDelete={handleDelete}
        searchPlaceholder="Search trips..."
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          resetForm();
        }}
        title={editingTrip ? 'Edit Trip' : 'Add New Trip'}
        size="lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <FormSelect
            label="Bus Line"
            value={formData.bus_line_id}
            onChange={(e) => setFormData({ ...formData, bus_line_id: e.target.value })}
            options={busLineOptions}
            required
          />
          <div className="grid grid-cols-2 gap-4">
            <FormSelect
              label="Bus"
              value={formData.bus_id}
              onChange={(e) => setFormData({ ...formData, bus_id: e.target.value })}
              options={busOptions}
              required
            />
            <FormSelect
              label="Driver"
              value={formData.driver_id}
              onChange={(e) => setFormData({ ...formData, driver_id: e.target.value })}
              options={driverOptions}
              required
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <FormInput
              label="Departure Time"
              type="datetime-local"
              value={formData.departure_time}
              onChange={(e) => setFormData({ ...formData, departure_time: e.target.value })}
              required
            />
            <FormInput
              label="Arrival Time"
              type="datetime-local"
              value={formData.arrival_time}
              onChange={(e) => setFormData({ ...formData, arrival_time: e.target.value })}
              required
            />
          </div>
          <div className="grid grid-cols-3 gap-4">
            <FormInput
              label="Available Seats"
              type="number"
              value={formData.available_seats}
              onChange={(e) => setFormData({ ...formData, available_seats: e.target.value })}
              required
            />
            <FormInput
              label="Price ($)"
              type="number"
              step="0.01"
              value={formData.price}
              onChange={(e) => setFormData({ ...formData, price: e.target.value })}
              required
            />
            <FormSelect
              label="Status"
              value={formData.status}
              onChange={(e) => setFormData({ ...formData, status: e.target.value })}
              options={statusOptions}
              required
            />
          </div>
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
              {editingTrip ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>
    </PageLayout>
  );
}
