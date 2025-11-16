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
import { Subscription } from '../types';

export function Subscriptions() {
  const { subscriptions, busLines, fetchData } = useApp();
  const { showToast } = useToast();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingSub, setEditingSub] = useState<Subscription | null>(null);
  const [formData, setFormData] = useState({
    user_name: '',
    user_email: '',
    bus_line_id: '',
    type: 'monthly',
    start_date: '',
    end_date: '',
    price: '',
    status: 'active',
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

      if (editingSub) {
        const { error } = await supabase
          .from('subscriptions')
          .update(payload)
          .eq('id', editingSub.id);
        if (error) throw error;
        showToast('Subscription updated successfully', 'success');
      } else {
        const { error } = await supabase.from('subscriptions').insert([payload]);
        if (error) throw error;
        showToast('Subscription created successfully', 'success');
      }
      await fetchData('subscriptions');
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
      user_name: '',
      user_email: '',
      bus_line_id: '',
      type: 'monthly',
      start_date: '',
      end_date: '',
      price: '',
      status: 'active',
    });
    setEditingSub(null);
  };

  const handleEdit = (sub: Subscription) => {
    setEditingSub(sub);
    setFormData({
      user_name: sub.user_name,
      user_email: sub.user_email,
      bus_line_id: sub.bus_line_id,
      type: sub.type,
      start_date: sub.start_date,
      end_date: sub.end_date,
      price: sub.price.toString(),
      status: sub.status,
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (sub: Subscription) => {
    if (!confirm('Are you sure you want to delete this subscription?')) return;

    try {
      const { error } = await supabase.from('subscriptions').delete().eq('id', sub.id);
      if (error) throw error;
      showToast('Subscription deleted successfully', 'success');
      await fetchData('subscriptions');
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    }
  };

  const columns = [
    { key: 'user_name', label: 'User', sortable: true },
    {
      key: 'bus_line',
      label: 'Bus Line',
      render: (sub: Subscription) =>
        sub.bus_line ? `${sub.bus_line.code} - ${sub.bus_line.name}` : '-',
    },
    { key: 'type', label: 'Type', sortable: true },
    {
      key: 'start_date',
      label: 'Start Date',
      sortable: true,
      render: (sub: Subscription) => new Date(sub.start_date).toLocaleDateString(),
    },
    {
      key: 'end_date',
      label: 'End Date',
      sortable: true,
      render: (sub: Subscription) => new Date(sub.end_date).toLocaleDateString(),
    },
    {
      key: 'price',
      label: 'Price',
      sortable: true,
      render: (sub: Subscription) => `$${sub.price.toFixed(2)}`,
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (sub: Subscription) => <StatusBadge status={sub.status} />,
    },
  ];

  const busLineOptions = [
    { value: '', label: 'Select a bus line' },
    ...busLines.map((line) => ({ value: line.id, label: `${line.code} - ${line.name}` })),
  ];

  const typeOptions = [
    { value: 'weekly', label: 'Weekly' },
    { value: 'monthly', label: 'Monthly' },
    { value: 'yearly', label: 'Yearly' },
  ];

  const statusOptions = [
    { value: 'active', label: 'Active' },
    { value: 'expired', label: 'Expired' },
    { value: 'cancelled', label: 'Cancelled' },
  ];

  return (
    <PageLayout
      title="Subscriptions"
      description="Manage recurring subscriptions"
      actions={
        <Button
          variant="primary"
          onClick={() => {
            resetForm();
            setIsModalOpen(true);
          }}
        >
          <Plus className="w-5 h-5" />
          Add Subscription
        </Button>
      }
    >
      <Table
        data={subscriptions}
        columns={columns}
        onEdit={handleEdit}
        onDelete={handleDelete}
        searchPlaceholder="Search subscriptions..."
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          resetForm();
        }}
        title={editingSub ? 'Edit Subscription' : 'Add New Subscription'}
        size="lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <FormInput
            label="User Name"
            value={formData.user_name}
            onChange={(e) => setFormData({ ...formData, user_name: e.target.value })}
            required
          />
          <FormInput
            label="User Email"
            type="email"
            value={formData.user_email}
            onChange={(e) => setFormData({ ...formData, user_email: e.target.value })}
            required
          />
          <FormSelect
            label="Bus Line"
            value={formData.bus_line_id}
            onChange={(e) => setFormData({ ...formData, bus_line_id: e.target.value })}
            options={busLineOptions}
            required
          />
          <div className="grid grid-cols-2 gap-4">
            <FormSelect
              label="Type"
              value={formData.type}
              onChange={(e) => setFormData({ ...formData, type: e.target.value })}
              options={typeOptions}
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
          </div>
          <div className="grid grid-cols-2 gap-4">
            <FormInput
              label="Start Date"
              type="date"
              value={formData.start_date}
              onChange={(e) => setFormData({ ...formData, start_date: e.target.value })}
              required
            />
            <FormInput
              label="End Date"
              type="date"
              value={formData.end_date}
              onChange={(e) => setFormData({ ...formData, end_date: e.target.value })}
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
              {editingSub ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>
    </PageLayout>
  );
}
