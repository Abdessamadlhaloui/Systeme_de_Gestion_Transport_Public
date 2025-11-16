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
import { Driver } from '../types';

export function Drivers() {
  const { drivers, fetchData } = useApp();
  const { showToast } = useToast();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingDriver, setEditingDriver] = useState<Driver | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    license_number: '',
    license_expiry: '',
    status: 'active',
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (editingDriver) {
        const { error } = await supabase
          .from('drivers')
          .update(formData)
          .eq('id', editingDriver.id);
        if (error) throw error;
        showToast('Driver updated successfully', 'success');
      } else {
        const { error } = await supabase.from('drivers').insert([formData]);
        if (error) throw error;
        showToast('Driver created successfully', 'success');
      }
      await fetchData('drivers');
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
      email: '',
      phone: '',
      license_number: '',
      license_expiry: '',
      status: 'active',
    });
    setEditingDriver(null);
  };

  const handleEdit = (driver: Driver) => {
    setEditingDriver(driver);
    setFormData({
      name: driver.name,
      email: driver.email,
      phone: driver.phone,
      license_number: driver.license_number,
      license_expiry: driver.license_expiry,
      status: driver.status,
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (driver: Driver) => {
    if (!confirm('Are you sure you want to delete this driver?')) return;

    try {
      const { error } = await supabase.from('drivers').delete().eq('id', driver.id);
      if (error) throw error;
      showToast('Driver deleted successfully', 'success');
      await fetchData('drivers');
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    }
  };

  const columns = [
    { key: 'name', label: 'Name', sortable: true },
    { key: 'email', label: 'Email', sortable: true },
    { key: 'phone', label: 'Phone', sortable: true },
    { key: 'license_number', label: 'License', sortable: true },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (driver: Driver) => <StatusBadge status={driver.status} />,
    },
  ];

  const statusOptions = [
    { value: 'active', label: 'Active' },
    { value: 'inactive', label: 'Inactive' },
    { value: 'on_leave', label: 'On Leave' },
  ];

  return (
    <PageLayout
      title="Drivers"
      description="Manage your driver workforce"
      actions={
        <Button
          variant="primary"
          onClick={() => {
            resetForm();
            setIsModalOpen(true);
          }}
        >
          <Plus className="w-5 h-5" />
          Add Driver
        </Button>
      }
    >
      <Table
        data={drivers}
        columns={columns}
        onEdit={handleEdit}
        onDelete={handleDelete}
        searchPlaceholder="Search drivers..."
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          resetForm();
        }}
        title={editingDriver ? 'Edit Driver' : 'Add New Driver'}
        size="lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <FormInput
            label="Full Name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            required
          />
          <div className="grid grid-cols-2 gap-4">
            <FormInput
              label="Email"
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              required
            />
            <FormInput
              label="Phone"
              type="tel"
              value={formData.phone}
              onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
              required
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <FormInput
              label="License Number"
              value={formData.license_number}
              onChange={(e) => setFormData({ ...formData, license_number: e.target.value })}
              required
            />
            <FormInput
              label="License Expiry"
              type="date"
              value={formData.license_expiry}
              onChange={(e) => setFormData({ ...formData, license_expiry: e.target.value })}
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
              {editingDriver ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>
    </PageLayout>
  );
}
