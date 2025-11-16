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
import { Ticket } from '../types';

export function Tickets() {
  const { tickets, trips, fetchData } = useApp();
  const { showToast } = useToast();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingTicket, setEditingTicket] = useState<Ticket | null>(null);
  const [formData, setFormData] = useState({
    trip_id: '',
    passenger_name: '',
    passenger_email: '',
    passenger_phone: '',
    seat_number: '',
    price: '',
    status: 'booked',
    booking_date: new Date().toISOString().split('T')[0],
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const payload = {
        ...formData,
        price: parseFloat(formData.price),
      };

      if (editingTicket) {
        const { error } = await supabase
          .from('tickets')
          .update(payload)
          .eq('id', editingTicket.id);
        if (error) throw error;
        showToast('Ticket updated successfully', 'success');
      } else {
        const { error } = await supabase.from('tickets').insert([payload]);
        if (error) throw error;
        showToast('Ticket booked successfully', 'success');
      }
      await fetchData('tickets');
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
      passenger_name: '',
      passenger_email: '',
      passenger_phone: '',
      seat_number: '',
      price: '',
      status: 'booked',
      booking_date: new Date().toISOString().split('T')[0],
    });
    setEditingTicket(null);
  };

  const handleEdit = (ticket: Ticket) => {
    setEditingTicket(ticket);
    setFormData({
      trip_id: ticket.trip_id,
      passenger_name: ticket.passenger_name,
      passenger_email: ticket.passenger_email,
      passenger_phone: ticket.passenger_phone,
      seat_number: ticket.seat_number,
      price: ticket.price.toString(),
      status: ticket.status,
      booking_date: ticket.booking_date,
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (ticket: Ticket) => {
    if (!confirm('Are you sure you want to delete this ticket?')) return;

    try {
      const { error } = await supabase.from('tickets').delete().eq('id', ticket.id);
      if (error) throw error;
      showToast('Ticket deleted successfully', 'success');
      await fetchData('tickets');
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    }
  };

  const columns = [
    { key: 'passenger_name', label: 'Passenger', sortable: true },
    {
      key: 'trip',
      label: 'Trip',
      render: (ticket: Ticket) =>
        ticket.trip?.bus_line
          ? `${ticket.trip.bus_line.code} - ${new Date(ticket.trip.departure_time).toLocaleDateString()}`
          : '-',
    },
    { key: 'seat_number', label: 'Seat', sortable: true },
    {
      key: 'price',
      label: 'Price',
      sortable: true,
      render: (ticket: Ticket) => `$${ticket.price.toFixed(2)}`,
    },
    {
      key: 'booking_date',
      label: 'Booking Date',
      sortable: true,
      render: (ticket: Ticket) => new Date(ticket.booking_date).toLocaleDateString(),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (ticket: Ticket) => <StatusBadge status={ticket.status} />,
    },
  ];

  const tripOptions = [
    { value: '', label: 'Select a trip' },
    ...trips
      .filter((trip) => trip.status === 'scheduled' || trip.status === 'in_progress')
      .map((trip) => ({
        value: trip.id,
        label: `${trip.bus_line?.code} - ${new Date(trip.departure_time).toLocaleString()}`,
      })),
  ];

  const statusOptions = [
    { value: 'booked', label: 'Booked' },
    { value: 'confirmed', label: 'Confirmed' },
    { value: 'cancelled', label: 'Cancelled' },
    { value: 'used', label: 'Used' },
  ];

  return (
    <PageLayout
      title="Tickets"
      description="Manage ticket bookings"
      actions={
        <Button
          variant="primary"
          onClick={() => {
            resetForm();
            setIsModalOpen(true);
          }}
        >
          <Plus className="w-5 h-5" />
          Book Ticket
        </Button>
      }
    >
      <Table
        data={tickets}
        columns={columns}
        onEdit={handleEdit}
        onDelete={handleDelete}
        searchPlaceholder="Search tickets..."
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          resetForm();
        }}
        title={editingTicket ? 'Edit Ticket' : 'Book New Ticket'}
        size="lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <FormSelect
            label="Trip"
            value={formData.trip_id}
            onChange={(e) => setFormData({ ...formData, trip_id: e.target.value })}
            options={tripOptions}
            required
          />
          <FormInput
            label="Passenger Name"
            value={formData.passenger_name}
            onChange={(e) => setFormData({ ...formData, passenger_name: e.target.value })}
            required
          />
          <div className="grid grid-cols-2 gap-4">
            <FormInput
              label="Email"
              type="email"
              value={formData.passenger_email}
              onChange={(e) => setFormData({ ...formData, passenger_email: e.target.value })}
              required
            />
            <FormInput
              label="Phone"
              type="tel"
              value={formData.passenger_phone}
              onChange={(e) => setFormData({ ...formData, passenger_phone: e.target.value })}
              required
            />
          </div>
          <div className="grid grid-cols-3 gap-4">
            <FormInput
              label="Seat Number"
              value={formData.seat_number}
              onChange={(e) => setFormData({ ...formData, seat_number: e.target.value })}
              placeholder="e.g., A1"
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
              {editingTicket ? 'Update' : 'Book'}
            </Button>
          </div>
        </form>
      </Modal>
    </PageLayout>
  );
}
