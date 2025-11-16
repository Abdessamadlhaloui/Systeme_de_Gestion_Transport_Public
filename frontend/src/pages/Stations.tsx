import { useState } from 'react';
import { PageLayout } from '../components/PageLayout';
import { Table } from '../components/Table';
import { Button } from '../components/Button';
import { Modal } from '../components/Modal';
import { FormInput, FormSelect } from '../components/FormInput';
import { useToast } from '../components/Toast';
import { useApp } from '../context/AppContext';
import { Plus } from 'lucide-react';
import { supabase } from '../utils/supabase';
import { Station } from '../types';

export function Stations() {
  const { stations, cities, fetchData } = useApp();
  const { showToast } = useToast();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingStation, setEditingStation] = useState<Station | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    city_id: '',
    address: '',
    latitude: '',
    longitude: '',
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const payload = {
        ...formData,
        latitude: formData.latitude ? parseFloat(formData.latitude) : null,
        longitude: formData.longitude ? parseFloat(formData.longitude) : null,
      };

      if (editingStation) {
        const { error } = await supabase
          .from('stations')
          .update(payload)
          .eq('id', editingStation.id);
        if (error) throw error;
        showToast('Station updated successfully', 'success');
      } else {
        const { error } = await supabase.from('stations').insert([payload]);
        if (error) throw error;
        showToast('Station created successfully', 'success');
      }
      await fetchData('stations');
      setIsModalOpen(false);
      setFormData({ name: '', city_id: '', address: '', latitude: '', longitude: '' });
      setEditingStation(null);
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = (station: Station) => {
    setEditingStation(station);
    setFormData({
      name: station.name,
      city_id: station.city_id,
      address: station.address,
      latitude: station.latitude?.toString() || '',
      longitude: station.longitude?.toString() || '',
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (station: Station) => {
    if (!confirm('Are you sure you want to delete this station?')) return;

    try {
      const { error } = await supabase.from('stations').delete().eq('id', station.id);
      if (error) throw error;
      showToast('Station deleted successfully', 'success');
      await fetchData('stations');
    } catch (error: any) {
      showToast(error.message || 'An error occurred', 'error');
    }
  };

  const columns = [
    { key: 'name', label: 'Name', sortable: true },
    {
      key: 'city.name',
      label: 'City',
      sortable: true,
      render: (station: Station) => station.city?.name || '-',
    },
    { key: 'address', label: 'Address', sortable: true },
  ];

  const cityOptions = [
    { value: '', label: 'Select a city' },
    ...cities.map((city) => ({ value: city.id, label: `${city.name}, ${city.country}` })),
  ];

  return (
    <PageLayout
      title="Stations"
      description="Manage bus stations in your network"
      actions={
        <Button
          variant="primary"
          onClick={() => {
            setEditingStation(null);
            setFormData({ name: '', city_id: '', address: '', latitude: '', longitude: '' });
            setIsModalOpen(true);
          }}
        >
          <Plus className="w-5 h-5" />
          Add Station
        </Button>
      }
    >
      <Table
        data={stations}
        columns={columns}
        onEdit={handleEdit}
        onDelete={handleDelete}
        searchPlaceholder="Search stations..."
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setEditingStation(null);
          setFormData({ name: '', city_id: '', address: '', latitude: '', longitude: '' });
        }}
        title={editingStation ? 'Edit Station' : 'Add New Station'}
        size="lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <FormInput
            label="Station Name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            required
          />
          <FormSelect
            label="City"
            value={formData.city_id}
            onChange={(e) => setFormData({ ...formData, city_id: e.target.value })}
            options={cityOptions}
            required
          />
          <FormInput
            label="Address"
            value={formData.address}
            onChange={(e) => setFormData({ ...formData, address: e.target.value })}
            required
          />
          <div className="grid grid-cols-2 gap-4">
            <FormInput
              label="Latitude"
              type="number"
              step="any"
              value={formData.latitude}
              onChange={(e) => setFormData({ ...formData, latitude: e.target.value })}
              placeholder="Optional"
            />
            <FormInput
              label="Longitude"
              type="number"
              step="any"
              value={formData.longitude}
              onChange={(e) => setFormData({ ...formData, longitude: e.target.value })}
              placeholder="Optional"
            />
          </div>
          <div className="flex gap-3 justify-end pt-4">
            <Button
              variant="secondary"
              type="button"
              onClick={() => {
                setIsModalOpen(false);
                setEditingStation(null);
                setFormData({ name: '', city_id: '', address: '', latitude: '', longitude: '' });
              }}
            >
              Cancel
            </Button>
            <Button variant="primary" type="submit" loading={loading}>
              {editingStation ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>
    </PageLayout>
  );
}
