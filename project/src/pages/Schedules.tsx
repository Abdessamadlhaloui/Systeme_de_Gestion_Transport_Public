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
import { Schedule } from '../types';

const API_URL = 'http://localhost:3001/api';

const getErrorMessage = (error: unknown) =>
    error instanceof Error ? error.message : String(error);

const getScheduleId = (schedule: Schedule | Record<string, unknown>) => {
    const source = schedule as Record<string, unknown>;
    const rawId =
        source['id_schedule'] ||
        source['ID_SCHEDULE'] ||
        source['id'] ||
        source['ID'];
    return rawId ? String(rawId) : '';
};

export function Schedules() {
    const { schedules, busLines, fetchData } = useApp();
    const { showToast } = useToast();
    const { canCreate, canUpdate, canDelete } = usePermissions('schedules');

    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingSchedule, setEditingSchedule] = useState<Schedule | null>(null);
    const [formData, setFormData] = useState({
        service_type: 'weekday',
        day_of_week: '',
        frequency_min: '',
        id_line: '',
    });
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        try {
            const payload = {
                service_type: formData.service_type,
                day_of_week: formData.day_of_week || null,
                frequency_min: formData.frequency_min ? parseInt(formData.frequency_min) : null,
                id_line: formData.id_line,
            };

            if (editingSchedule) {
                const scheduleId = getScheduleId(editingSchedule);
                if (!scheduleId) {
                    throw new Error('Schedule ID missing, cannot update');
                }

                const response = await fetch(`${API_URL}/schedules/${scheduleId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload),
                });

                const result = await response.json();
                if (!response.ok || result.error) {
                    throw new Error(result.error || 'Failed to update schedule');
                }

                showToast('Schedule updated successfully', 'success');
            } else {
                const response = await fetch(`${API_URL}/schedules`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload),
                });

                const result = await response.json();
                if (!response.ok || result.error) {
                    throw new Error(result.error || 'Failed to create schedule');
                }

                showToast('Schedule created successfully', 'success');
            }

            await fetchData('schedules');
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
            service_type: 'weekday',
            day_of_week: '',
            frequency_min: '',
            id_line: '',
        });
        setEditingSchedule(null);
    };

    const handleEdit = (schedule: Schedule) => {
        setEditingSchedule(schedule);
        setFormData({
            service_type: schedule.service_type,
            day_of_week: schedule.day_of_week || '',
            frequency_min: schedule.frequency_min ? schedule.frequency_min.toString() : '',
            id_line: schedule.id_line,
        });
        setIsModalOpen(true);
    };

    const handleDelete = async (schedule: Schedule) => {
        if (!confirm('Are you sure you want to delete this schedule?')) return;

        const scheduleId = getScheduleId(schedule);
        if (!scheduleId) {
            showToast('Cannot delete: Schedule ID not found', 'error');
            return;
        }

        try {
            const response = await fetch(`${API_URL}/schedules/${scheduleId}`, {
                method: 'DELETE',
            });

            const result = await response.json();
            if (!response.ok || result.error) {
                throw new Error(result.error || 'Failed to delete schedule');
            }

            showToast('Schedule deleted successfully', 'success');
            await fetchData('schedules');
        } catch (error: unknown) {
            console.error('Error:', error);
            showToast(getErrorMessage(error) || 'An error occurred', 'error');
        }
    };

    const columns = [
        {
            key: 'service_type',
            label: 'Service Type',
            sortable: true,
        },
        {
            key: 'day_of_week',
            label: 'Day of Week',
            sortable: true,
            render: (schedule: Schedule) => schedule.day_of_week || '-',
        },
        {
            key: 'frequency_min',
            label: 'Frequency (min)',
            sortable: true,
            render: (schedule: Schedule) => schedule.frequency_min ? `${schedule.frequency_min} min` : '-',
        },
        {
            key: 'bus_line',
            label: 'Bus Line',
            render: (schedule: Schedule) => {
                const lineId = schedule.id_line;
                const line = busLines.find(l => {
                    const id = (l as any).id_line || (l as any).ID_LINE || l.id;
                    return String(id) === String(lineId);
                });
                return line ? `${line.code} - ${line.name}` : '-';
            },
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

    const serviceTypeOptions = [
        { value: 'weekday', label: 'Weekday' },
        { value: 'weekend', label: 'Weekend' },
        { value: 'holiday', label: 'Holiday' },
    ];

    const dayOfWeekOptions = [
        { value: '', label: 'All Days' },
        { value: 'Monday', label: 'Monday' },
        { value: 'Tuesday', label: 'Tuesday' },
        { value: 'Wednesday', label: 'Wednesday' },
        { value: 'Thursday', label: 'Thursday' },
        { value: 'Friday', label: 'Friday' },
        { value: 'Saturday', label: 'Saturday' },
        { value: 'Sunday', label: 'Sunday' },
    ];

    return (
        <PageLayout
            title="Schedules"
            description="Manage bus schedules and service types"
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
                        Add Schedule
                    </Button>
                ) : undefined
            }
        >
            <Table
                data={schedules}
                columns={columns}
                onEdit={canUpdate ? handleEdit : undefined}
                onDelete={canDelete ? handleDelete : undefined}
                searchPlaceholder="Search schedules..."
            />

            <Modal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                title={editingSchedule ? 'Edit Schedule' : 'Add New Schedule'}
                size="lg"
            >
                <form onSubmit={handleSubmit} className="space-y-4">
                    <FormSelect
                        label="Service Type"
                        value={formData.service_type}
                        onChange={(e) => setFormData({ ...formData, service_type: e.target.value })}
                        options={serviceTypeOptions}
                        required
                    />
                    <FormSelect
                        label="Day of Week"
                        value={formData.day_of_week}
                        onChange={(e) => setFormData({ ...formData, day_of_week: e.target.value })}
                        options={dayOfWeekOptions}
                    />
                    <FormInput
                        label="Frequency (minutes)"
                        type="number"
                        value={formData.frequency_min}
                        onChange={(e) => setFormData({ ...formData, frequency_min: e.target.value })}
                        placeholder="e.g., 15"
                    />
                    <FormSelect
                        label="Bus Line"
                        value={formData.id_line}
                        onChange={(e) => setFormData({ ...formData, id_line: e.target.value })}
                        options={busLineOptions}
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
                            {editingSchedule ? 'Update' : 'Create'}
                        </Button>
                    </div>
                </form>
            </Modal>
        </PageLayout>
    );
}
