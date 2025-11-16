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
import { Bus } from '../types';

export function Buses() {
  const { buses, fetchData } = useApp();
  const { showToast } = useToast();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBus, setEditingBus] = useState<Bus | null>(null);
  const [formData, setFormData] = useState({
    plate_number: '',
    model: '',
    capacity: '',
    year: '',
    status: 'available',
    last_maintenance_date: '',
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const payload = {
        ...formData,
        capacity: parseInt(formData.capacity),
        year: parseInt(formData.year),
        last_maintenance_date: formData.last_maintenance_date || null,
      };

      if (editingBus) {
        const { error } = await supabase
          .from('buses')
          .update(payload)
          .eq('id', editingBus.id);
        if (error) throw error;
        showToast('Bus updated successfully', 'success');
      } else {
        const { error } = await supabase.from('buses').insert([payload]);
        if (error) throw error;
        showToast('Bus created successfully', 'success');
      }
      await fetchData('buses');
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
      plate_number: '',
      model: '',
      capacity: '',
      year: '',
      status: 'available',
      last_maintenance_date: '',
    });
    setEditingBus(null);
  };

  const handleEdit = (bus: Bus) => {
    setEditingBus(bus);
    setFormData({
      plate_number: bus.plate_number,
      model: bus.model,
      capacity: bus.capacity.toString(),
      year: bus.year.toString(),
      status: bus.status,
      last_maintenance_date: bus.last_maintenance_date || '',
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (bus: Bus) => {
    if (!confirm('Are you sure you want to delete this bus?')) return;

    try {
      const { error } = await supabase.from('buses').delete().eq('id', bus.id);
      if (error) throw error;
      showToast('Bus deleted successfully', 'success');
      await fetchData('buses');
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    }
  };

  const columns = [
    { key: 'plate_number', label: 'Plate Number', sortable: true },
    { key: 'model', label: 'Model', sortable: true },
    { key: 'capacity', label: 'Capacity', sortable: true },
    { key: 'year', label: 'Year', sortable: true },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (bus: Bus) => <StatusBadge status={bus.status} />,
    },
  ];

  const statusOptions = [
    { value: 'available', label: 'Available' },
    { value: 'in_service', label: 'In Service' },
    { value: 'maintenance', label: 'Maintenance' },
    { value: 'retired', label: 'Retired' },
  ];

  return (
    <PageLayout
      title="Buses"
      description="Manage your bus fleet"
      actions={
        <Button
          variant="primary"
          onClick={() => {
            resetForm();
            setIsModalOpen(true);
          }}
        >
          <Plus className="w-5 h-5" />
          Add Bus
        </Button>
      }
    >
      <Table
        data={buses}
        columns={columns}
        onEdit={handleEdit}
        onDelete={handleDelete}
        searchPlaceholder="Search buses..."
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          resetForm();
        }}
        title={editingBus ? 'Edit Bus' : 'Add New Bus'}
        size="lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <FormInput
              label="Plate Number"
              value={formData.plate_number}
              onChange={(e) => setFormData({ ...formData, plate_number: e.target.value })}
              placeholder="e.g., ABC-123"
              required
            />
            <FormInput
              label="Model"
              value={formData.model}
              onChange={(e) => setFormData({ ...formData, model: e.target.value })}
              placeholder="e.g., Mercedes-Benz Citaro"
              required
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <FormInput
              label="Capacity"
              type="number"
              value={formData.capacity}
              onChange={(e) => setFormData({ ...formData, capacity: e.target.value })}
              placeholder="Number of seats"
              required
            />
            <FormInput
              label="Year"
              type="number"
              value={formData.year}
              onChange={(e) => setFormData({ ...formData, year: e.target.value })}
              placeholder="e.g., 2023"
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
          <FormInput
            label="Last Maintenance Date"
            type="date"
            value={formData.last_maintenance_date}
            onChange={(e) =>
              setFormData({ ...formData, last_maintenance_date: e.target.value })
            }
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
              {editingBus ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>
    </PageLayout>
  );
}
