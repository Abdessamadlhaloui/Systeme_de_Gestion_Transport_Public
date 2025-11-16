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
import { Maintenance } from '../types';

export function MaintenancePage() {
  const { maintenance, buses, fetchData } = useApp();
  const { showToast } = useToast();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingMaintenance, setEditingMaintenance] = useState<Maintenance | null>(null);
  const [formData, setFormData] = useState({
    bus_id: '',
    type: 'routine',
    description: '',
    scheduled_date: '',
    completed_date: '',
    cost: '',
    status: 'scheduled',
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const payload = {
        ...formData,
        cost: parseFloat(formData.cost),
        completed_date: formData.completed_date || null,
      };

      if (editingMaintenance) {
        const { error } = await supabase
          .from('maintenance')
          .update(payload)
          .eq('id', editingMaintenance.id);
        if (error) throw error;
        showToast('Maintenance record updated successfully', 'success');
      } else {
        const { error } = await supabase.from('maintenance').insert([payload]);
        if (error) throw error;
        showToast('Maintenance record created successfully', 'success');
      }
      await fetchData('maintenance');
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
      bus_id: '',
      type: 'routine',
      description: '',
      scheduled_date: '',
      completed_date: '',
      cost: '',
      status: 'scheduled',
    });
    setEditingMaintenance(null);
  };

  const handleEdit = (item: Maintenance) => {
    setEditingMaintenance(item);
    setFormData({
      bus_id: item.bus_id,
      type: item.type,
      description: item.description,
      scheduled_date: item.scheduled_date,
      completed_date: item.completed_date || '',
      cost: item.cost.toString(),
      status: item.status,
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (item: Maintenance) => {
    if (!confirm('Are you sure you want to delete this maintenance record?')) return;

    try {
      const { error } = await supabase.from('maintenance').delete().eq('id', item.id);
      if (error) throw error;
      showToast('Maintenance record deleted successfully', 'success');
      await fetchData('maintenance');
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    }
  };

  const columns = [
    {
      key: 'bus',
      label: 'Bus',
      render: (item: Maintenance) =>
        item.bus ? `${item.bus.plate_number} (${item.bus.model})` : '-',
    },
    { key: 'type', label: 'Type', sortable: true },
    { key: 'description', label: 'Description' },
    {
      key: 'scheduled_date',
      label: 'Scheduled',
      sortable: true,
      render: (item: Maintenance) => new Date(item.scheduled_date).toLocaleDateString(),
    },
    {
      key: 'cost',
      label: 'Cost',
      sortable: true,
      render: (item: Maintenance) => `$${item.cost.toFixed(2)}`,
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (item: Maintenance) => <StatusBadge status={item.status} />,
    },
  ];

  const busOptions = [
    { value: '', label: 'Select a bus' },
    ...buses.map((bus) => ({ value: bus.id, label: `${bus.plate_number} (${bus.model})` })),
  ];

  const typeOptions = [
    { value: 'routine', label: 'Routine' },
    { value: 'repair', label: 'Repair' },
    { value: 'inspection', label: 'Inspection' },
  ];

  const statusOptions = [
    { value: 'scheduled', label: 'Scheduled' },
    { value: 'in_progress', label: 'In Progress' },
    { value: 'completed', label: 'Completed' },
  ];

  return (
    <PageLayout
      title="Maintenance"
      description="Manage bus maintenance records"
      actions={
        <Button
          variant="primary"
          onClick={() => {
            resetForm();
            setIsModalOpen(true);
          }}
        >
          <Plus className="w-5 h-5" />
          Add Maintenance
        </Button>
      }
    >
      <Table
        data={maintenance}
        columns={columns}
        onEdit={handleEdit}
        onDelete={handleDelete}
        searchPlaceholder="Search maintenance records..."
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          resetForm();
        }}
        title={editingMaintenance ? 'Edit Maintenance Record' : 'Add Maintenance Record'}
        size="lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <FormSelect
            label="Bus"
            value={formData.bus_id}
            onChange={(e) => setFormData({ ...formData, bus_id: e.target.value })}
            options={busOptions}
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
              label="Cost ($)"
              type="number"
              step="0.01"
              value={formData.cost}
              onChange={(e) => setFormData({ ...formData, cost: e.target.value })}
              required
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
              label="Scheduled Date"
              type="date"
              value={formData.scheduled_date}
              onChange={(e) => setFormData({ ...formData, scheduled_date: e.target.value })}
              required
            />
            <FormInput
              label="Completed Date"
              type="date"
              value={formData.completed_date}
              onChange={(e) => setFormData({ ...formData, completed_date: e.target.value })}
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
              {editingMaintenance ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>
    </PageLayout>
  );
}
