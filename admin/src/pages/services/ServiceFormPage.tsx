import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { ArrowLeft } from 'lucide-react';
import { useServices, useUpdateService, useUploadServiceImage } from '../../hooks/useServices';
import ImageUpload from '../../components/ImageUpload';

const schema = z.object({
  name: z.string().min(2),
  shortDescription: z.string().optional(),
  description: z.string().optional(),
  icon: z.string().optional(),
  sortOrder: z.coerce.number().int().min(0),
  isActive: z.boolean(),
});

type FormValues = z.infer<typeof schema>;

export default function ServiceFormPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();

  const { data: services = [] } = useServices();
  const service = services.find(s => s.id === id);

  const updateMutation = useUpdateService(id!);
  const uploadMutation = useUploadServiceImage(id!);
  const [pendingFile, setPendingFile] = useState<File | null>(null);
  const [serverError, setServerError] = useState('');

  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { sortOrder: 0, isActive: true },
  });

  useEffect(() => {
    if (service) reset({
      name: service.name,
      shortDescription: service.shortDescription ?? '',
      description: service.description ?? '',
      icon: service.icon ?? '',
      sortOrder: service.sortOrder,
      isActive: service.isActive,
    });
  }, [service, reset]);

  const onSubmit = async (values: FormValues) => {
    setServerError('');
    try {
      await updateMutation.mutateAsync(values);
      if (pendingFile) await uploadMutation.mutateAsync(pendingFile);
      navigate('/services');
    } catch (e: any) {
      setServerError(e.response?.data?.error || 'Failed to save service');
    }
  };

  if (!service) return <div className="p-8 text-gray-400 text-sm">Loading…</div>;

  return (
    <div className="p-8 max-w-2xl">
      <button onClick={() => navigate('/services')} className="flex items-center gap-2 text-sm text-gray-500 hover:text-gray-900 mb-6">
        <ArrowLeft size={16} /> Back to Services
      </button>

      <h1 className="text-2xl font-bold text-gray-900 mb-6">Edit Service</h1>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Service Image</label>
          <ImageUpload currentUrl={service.imageUrl} onUpload={setPendingFile} isUploading={uploadMutation.isPending} />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Name *</label>
            <input {...register('name')} className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
            {errors.name && <p className="text-xs text-red-600 mt-1">{errors.name.message}</p>}
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Icon (emoji)</label>
            <input {...register('icon')} placeholder="🖨️"
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Short Description</label>
          <input {...register('shortDescription')}
            className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Full Description</label>
          <textarea {...register('description')} rows={4}
            className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary resize-none" />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Sort Order</label>
            <input {...register('sortOrder')} type="number" min="0"
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
          </div>
          <div className="flex items-end pb-2">
            <label className="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
              <input {...register('isActive')} type="checkbox" className="rounded border-gray-300 text-primary focus:ring-primary" />
              Active
            </label>
          </div>
        </div>

        {serverError && <div className="bg-red-50 border border-red-200 rounded-lg px-3 py-2 text-sm text-red-700">{serverError}</div>}

        <div className="flex gap-3 pt-2">
          <button type="submit" disabled={isSubmitting}
            className="bg-primary hover:bg-primary-dark text-white px-6 py-2.5 rounded-lg text-sm font-medium transition-colors disabled:opacity-50">
            {isSubmitting ? 'Saving…' : 'Save Changes'}
          </button>
          <button type="button" onClick={() => navigate('/services')}
            className="px-6 py-2.5 rounded-lg text-sm font-medium border border-gray-300 text-gray-700 hover:bg-gray-50 transition-colors">
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}
