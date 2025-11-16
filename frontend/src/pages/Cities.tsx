import { useState } from 'react';
import { PageLayout } from '../components/PageLayout';
import { Table } from '../components/Table';
import { Button } from '../components/Button';
import { Modal } from '../components/Modal';
import { FormInput } from '../components/FormInput';
import { useToast } from '../components/Toast';
import { useApp } from '../context/AppContext';
import { Plus } from 'lucide-react';
import { supabase } from '../utils/supabase';
import { City } from '../types';

export function Cities() {
  const { cities, fetchData } = useApp();
  const { showToast } = useToast();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingCity, setEditingCity] = useState<City | null>(null);
  const [formData, setFormData] = useState({ name: '', country: '' });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (editingCity) {
        const { error } = await supabase
          .from('cities')
          .update(formData)
          .eq('id', editingCity.id);
        if (error) throw error;
        showToast('City updated successfully', 'success');
      } else {
        const { error } = await supabase.from('cities').insert([formData]);
        if (error) throw error;
        showToast('City created successfully', 'success');
      }
      await fetchData('cities');
      setIsModalOpen(false);
      setFormData({ name: '', country: '' });
      setEditingCity(null);
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = (city: City) => {
    setEditingCity(city);
    setFormData({ name: city.name, country: city.country });
    setIsModalOpen(true);
  };

  const handleDelete = async (city: City) => {
    if (!confirm('Are you sure you want to delete this city?')) return;

    try {
      const { error } = await supabase.from('cities').delete().eq('id', city.id);
      if (error) throw error;
      showToast('City deleted successfully', 'success');
      await fetchData('cities');
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    }
  };

  const columns = [
    { key: 'name', label: 'Name', sortable: true },
    { key: 'country', label: 'Country', sortable: true },
  ];

  return (
    <PageLayout
      title="Cities"
      description="Manage cities in your bus network"
      actions={
        <Button
          variant="primary"
          onClick={() => {
            setEditingCity(null);
            setFormData({ name: '', country: '' });
            setIsModalOpen(true);
          }}
        >
          <Plus className="w-5 h-5" />
          Add City
        </Button>
      }
    >
      <Table
        data={cities}
        columns={columns}
        onEdit={handleEdit}
        onDelete={handleDelete}
        searchPlaceholder="Search cities..."
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setEditingCity(null);
          setFormData({ name: '', country: '' });
        }}
        title={editingCity ? 'Edit City' : 'Add New City'}
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <FormInput
            label="City Name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            required
          />
          <FormInput
            label="Country"
            value={formData.country}
            onChange={(e) => setFormData({ ...formData, country: e.target.value })}
            required
          />
          <div className="flex gap-3 justify-end pt-4">
            <Button
              variant="secondary"
              type="button"
              onClick={() => {
                setIsModalOpen(false);
                setEditingCity(null);
                setFormData({ name: '', country: '' });
              }}
            >
              Cancel
            </Button>
            <Button variant="primary" type="submit" loading={loading}>
              {editingCity ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>
    </PageLayout>
  );
}
