import { useState } from 'react';
import { PageLayout } from '../components/PageLayout';
import { Table } from '../components/Table';
import { Button } from '../components/Button';
import { Modal } from '../components/Modal';
import { FormInput, FormSelect } from '../components/FormInput';
import { useToast } from '../components/Toast';
import { useApp } from '../context/AppContext';
import { Plus } from 'lucide-react';
import { usePermissions } from '../hooks/usePermissions';
import { LineStation } from '../types';

const API_URL = 'http://localhost:3001/api';

const getErrorMessage = (error: unknown) =>
    error instanceof Error ? error.message : String(error);

export function LineStations() {
    const { lineStations, busLines, stations, fetchData } = useApp();
    const { showToast } = useToast();
    const { canCreate, canUpdate, canDelete } = usePermissions('lineStations');

    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingLineStation, setEditingLineStation] = useState<LineStation | null>(null);
    const [formData, setFormData] = useState({
        id_line: '',
        id_station: '',
        stop_order: '',
        distance_from_start_km: '',
    });
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        try {
            const payload = {
                id_line: formData.id_line,
                id_station: formData.id_station,
                stop_order: parseInt(formData.stop_order),
                distance_from_start_km: formData.distance_from_start_km
                    ? parseFloat(formData.distance_from_start_km)
                    : null,
            };

            if (editingLineStation) {
                const response = await fetch(
                    `${API_URL}/line_stations/${editingLineStation.id_line}/${editingLineStation.id_station}`,
                    {
                        method: 'PUT',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(payload),
                    }
                );

                const result = await response.json();
                if (!response.ok || result.error) {
                    throw new Error(result.error || 'Failed to update line station');
                }

                showToast('Line station updated successfully', 'success');
            } else {
                const response = await fetch(`${API_URL}/line_stations`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload),
                });

                const result = await response.json();
                if (!response.ok || result.error) {
                    throw new Error(result.error || 'Failed to create line station');
                }

                showToast('Line station created successfully', 'success');
            }

            await fetchData('lineStations');
            setIsModalOpen(false);
            resetForm();
        } catch (error: unknown) {
            console.error('Error:', error);
            showToast(getErrorMessage(error) || 'An error occurred', 'error');
        } finally {
            setLoading(false);
        }
    };

    const resetForm = () => {
        setFormData({
            id_line: '',
            id_station: '',
            stop_order: '',
            distance_from_start_km: '',
        });
        setEditingLineStation(null);
    };

    const handleEdit = (lineStation: LineStation) => {
        setEditingLineStation(lineStation);
        setFormData({
            id_line: lineStation.id_line,
            id_station: lineStation.id_station,
            stop_order: lineStation.stop_order.toString(),
            distance_from_start_km: lineStation.distance_from_start_km
                ? lineStation.distance_from_start_km.toString()
                : '',
        });
        setIsModalOpen(true);
    };

    const handleDelete = async (lineStation: LineStation) => {
        if (!confirm('Are you sure you want to delete this line station?')) return;

        try {
            const response = await fetch(
                `${API_URL}/line_stations/${lineStation.id_line}/${lineStation.id_station}`,
                {
                    method: 'DELETE',
                }
            );

            const result = await response.json();
            if (!response.ok || result.error) {
                throw new Error(result.error || 'Failed to delete line station');
            }

            showToast('Line station deleted successfully', 'success');
            await fetchData('lineStations');
        } catch (error: unknown) {
            console.error('Error:', error);
            showToast(getErrorMessage(error) || 'An error occurred', 'error');
        }
    };

    const columns = [
        {
            key: 'bus_line',
            label: 'Bus Line',
            render: (ls: LineStation) => {
                const line = busLines.find(l => {
                    const id = (l as any).id_line || (l as any).ID_LINE || l.id;
                    return String(id) === String(ls.id_line);
                });
                return line ? `${line.code} - ${line.name}` : '-';
            },
        },
        {
            key: 'station',
            label: 'Station',
            render: (ls: LineStation) => {
                const station = stations.find(s => {
                    const id = (s as any).id_station || (s as any).ID_STATION || s.id;
                    return String(id) === String(ls.id_station);
                });
                return station ? station.name : '-';
            },
        },
        {
            key: 'stop_order',
            label: 'Stop Order',
            sortable: true,
        },
        {
            key: 'distance_from_start_km',
            label: 'Distance (km)',
            sortable: true,
            render: (ls: LineStation) =>
                ls.distance_from_start_km ? `${ls.distance_from_start_km} km` : '-',
        },
    ];

    const busLineOptions = [
        { value: '', label: 'Select a bus line' },
        ...busLines.map((line) => {
            const lineId = (line as any).id_line || (line as any).ID_LINE || line.id;
            return {
                value: String(lineId),
                label: `${line.code} - ${line.name}`,
            };
        }),
    ];

    const stationOptions = [
        { value: '', label: 'Select a station' },
        ...stations.map((station) => {
            const stationId = (station as any).id_station || (station as any).ID_STATION || station.id;
            return {
                value: String(stationId),
                label: `${station.name} (${station.city?.name || 'Unknown'})`,
            };
        }),
    ];

    return (
        <PageLayout
            title="Line Stations"
            description="Manage station stops and order for each bus line"
            actions={
                canCreate ? (
                    <Button
                        variant="primary"
                        onClick={() => {
                            resetForm();
                            setIsModalOpen(true);
                        }}
                    >
                        <Plus className="w-5 h-5" />
                        Add Line Station
                    </Button>
                ) : undefined
            }
        >
            <Table
                data={lineStations}
                columns={columns}
                onEdit={canUpdate ? handleEdit : undefined}
                onDelete={canDelete ? handleDelete : undefined}
                searchPlaceholder="Search line stations..."
            />

            <Modal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                title={editingLineStation ? 'Edit Line Station' : 'Add New Line Station'}
                size="lg"
            >
                <form onSubmit={handleSubmit} className="space-y-4">
                    <FormSelect
                        label="Bus Line"
                        value={formData.id_line}
                        onChange={(e) => setFormData({ ...formData, id_line: e.target.value })}
                        options={busLineOptions}
                        required
                        disabled={!!editingLineStation}
                    />
                    <FormSelect
                        label="Station"
                        value={formData.id_station}
                        onChange={(e) => setFormData({ ...formData, id_station: e.target.value })}
                        options={stationOptions}
                        required
                        disabled={!!editingLineStation}
                    />
                    <FormInput
                        label="Stop Order"
                        type="number"
                        value={formData.stop_order}
                        onChange={(e) => setFormData({ ...formData, stop_order: e.target.value })}
                        placeholder="e.g., 1, 2, 3..."
                        required
                    />
                    <FormInput
                        label="Distance from Start (km)"
                        type="number"
                        step="0.01"
                        value={formData.distance_from_start_km}
                        onChange={(e) =>
                            setFormData({ ...formData, distance_from_start_km: e.target.value })
                        }
                        placeholder="e.g., 5.5"
                    />
                    <div className="flex justify-end gap-3 pt-4">
                        <Button
                            variant="secondary"
                            type="button"
                            onClick={() => setIsModalOpen(false)}
                        >
                            Cancel
                        </Button>
                        <Button variant="primary" type="submit" loading={loading}>
                            {editingLineStation ? 'Update' : 'Create'}
                        </Button>
                    </div>
                </form>
            </Modal>
        </PageLayout>
    );
}
