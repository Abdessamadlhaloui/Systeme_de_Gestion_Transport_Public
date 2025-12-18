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
import { ScheduleStop } from '../types';

const API_URL = 'http://localhost:3001/api';

const getErrorMessage = (error: unknown) =>
    error instanceof Error ? error.message : String(error);

export function ScheduleStops() {
    const { scheduleStops, schedules, stations, busLines, fetchData } = useApp();
    const { showToast } = useToast();
    const { canCreate, canUpdate, canDelete } = usePermissions('scheduleStops');

    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingStop, setEditingStop] = useState<ScheduleStop | null>(null);
    const [formData, setFormData] = useState({
        id_schedule: '',
        id_station: '',
        scheduled_stop_time: '',
    });
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        try {
            const payload = {
                id_schedule: formData.id_schedule,
                id_station: formData.id_station,
                scheduled_stop_time: formData.scheduled_stop_time,
            };

            if (editingStop) {
                const response = await fetch(
                    `${API_URL}/schedule_stops/${editingStop.id_schedule}/${editingStop.id_station}`,
                    {
                        method: 'PUT',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(payload),
                    }
                );

                const result = await response.json();
                if (!response.ok || result.error) {
                    throw new Error(result.error || 'Failed to update schedule stop');
                }

                showToast('Schedule stop updated successfully', 'success');
            } else {
                const response = await fetch(`${API_URL}/schedule_stops`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload),
                });

                const result = await response.json();
                if (!response.ok || result.error) {
                    throw new Error(result.error || 'Failed to create schedule stop');
                }

                showToast('Schedule stop created successfully', 'success');
            }

            await fetchData('scheduleStops');
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
            id_schedule: '',
            id_station: '',
            scheduled_stop_time: '',
        });
        setEditingStop(null);
    };

    const handleEdit = (stop: ScheduleStop) => {
        setEditingStop(stop);
        setFormData({
            id_schedule: stop.id_schedule,
            id_station: stop.id_station,
            scheduled_stop_time: stop.scheduled_stop_time,
        });
        setIsModalOpen(true);
    };

    const handleDelete = async (stop: ScheduleStop) => {
        if (!confirm('Are you sure you want to delete this schedule stop?')) return;

        try {
            const response = await fetch(
                `${API_URL}/schedule_stops/${stop.id_schedule}/${stop.id_station}`,
                {
                    method: 'DELETE',
                }
            );

            const result = await response.json();
            if (!response.ok || result.error) {
                throw new Error(result.error || 'Failed to delete schedule stop');
            }

            showToast('Schedule stop deleted successfully', 'success');
            await fetchData('scheduleStops');
        } catch (error: unknown) {
            console.error('Error:', error);
            showToast(getErrorMessage(error) || 'An error occurred', 'error');
        }
    };

    const columns = [
        {
            key: 'schedule',
            label: 'Schedule',
            render: (stop: ScheduleStop) => {
                const schedule = schedules.find(s => {
                    const id = (s as any).id_schedule || (s as any).ID_SCHEDULE || s.id;
                    return String(id) === String(stop.id_schedule);
                });
                if (!schedule) return '-';

                const line = busLines.find(l => {
                    const lineId = (l as any).id_line || (l as any).ID_LINE || l.id;
                    return String(lineId) === String(schedule.id_line);
                });

                return line ? `${line.code} - ${schedule.service_type}` : schedule.service_type;
            },
        },
        {
            key: 'station',
            label: 'Station',
            render: (stop: ScheduleStop) => {
                const station = stations.find(s => {
                    const id = (s as any).id_station || (s as any).ID_STATION || s.id;
                    return String(id) === String(stop.id_station);
                });
                return station ? station.name : '-';
            },
        },
        {
            key: 'scheduled_stop_time',
            label: 'Stop Time',
            sortable: true,
        },
    ];

    const scheduleOptions = [
        { value: '', label: 'Select a schedule' },
        ...schedules.map((schedule) => {
            const scheduleId = (schedule as any).id_schedule || (schedule as any).ID_SCHEDULE || schedule.id;
            const line = busLines.find(l => {
                const lineId = (l as any).id_line || (l as any).ID_LINE || l.id;
                return String(lineId) === String(schedule.id_line);
            });
            return {
                value: String(scheduleId),
                label: line ? `${line.code} - ${schedule.service_type}` : schedule.service_type,
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
            title="Schedule Stops"
            description="Manage scheduled stop times for each station"
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
                        Add Schedule Stop
                    </Button>
                ) : undefined
            }
        >
            <Table
                data={scheduleStops}
                columns={columns}
                onEdit={canUpdate ? handleEdit : undefined}
                onDelete={canDelete ? handleDelete : undefined}
                searchPlaceholder="Search schedule stops..."
            />

            <Modal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                title={editingStop ? 'Edit Schedule Stop' : 'Add New Schedule Stop'}
                size="lg"
            >
                <form onSubmit={handleSubmit} className="space-y-4">
                    <FormSelect
                        label="Schedule"
                        value={formData.id_schedule}
                        onChange={(e) => setFormData({ ...formData, id_schedule: e.target.value })}
                        options={scheduleOptions}
                        required
                        disabled={!!editingStop}
                    />
                    <FormSelect
                        label="Station"
                        value={formData.id_station}
                        onChange={(e) => setFormData({ ...formData, id_station: e.target.value })}
                        options={stationOptions}
                        required
                        disabled={!!editingStop}
                    />
                    <FormInput
                        label="Scheduled Stop Time"
                        type="time"
                        value={formData.scheduled_stop_time}
                        onChange={(e) => setFormData({ ...formData, scheduled_stop_time: e.target.value })}
                        placeholder="HH:MM"
                        required
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
                            {editingStop ? 'Update' : 'Create'}
                        </Button>
                    </div>
                </form>
            </Modal>
        </PageLayout>
    );
}
