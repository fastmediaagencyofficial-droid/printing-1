import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { ArrowLeft } from 'lucide-react';
import { useProducts, useCreateProduct, useUpdateProduct, useUploadProductImage } from '../../hooks/useProducts';
import { api } from '../../services/api';
import ImageUpload from '../../components/ImageUpload';

const schema = z.object({
  name: z.string().min(2, 'Name required'),
  slug: z.string().min(2, 'Slug required'),
  description: z.string().optional(),
  startingPrice: z.coerce.number().min(0),
  category: z.string().min(1, 'Category required'),
  isActive: z.boolean(),
  isFeatured: z.boolean(),
});

type FormValues = z.infer<typeof schema>;

export default function ProductFormPage() {
  const { id } = useParams<{ id: string }>();
  const isEdit = Boolean(id);
  const navigate = useNavigate();

  const { data: products = [] } = useProducts();
  const product = isEdit ? products.find(p => p.id === id) : undefined;

  const createMutation = useCreateProduct();
  const updateMutation = useUpdateProduct(id!);
  const uploadMutation = useUploadProductImage(id!);

  const [pendingFile, setPendingFile] = useState<File | null>(null);
  const [serverError, setServerError] = useState('');

  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { isActive: true, isFeatured: false },
  });

  useEffect(() => {
    if (product) reset({
      name: product.name,
      slug: product.slug,
      description: product.description,
      startingPrice: product.startingPrice,
      category: product.category,
      isActive: product.isActive,
      isFeatured: product.isFeatured,
    });
  }, [product, reset]);

  const onSubmit = async (values: FormValues) => {
    setServerError('');
    try {
      if (isEdit) {
        await updateMutation.mutateAsync(values);
        if (pendingFile) await uploadMutation.mutateAsync(pendingFile);
      } else {
        const created = await createMutation.mutateAsync(values) as any;
        if (pendingFile && created?.id) {
          const fd = new FormData();
          fd.append('image', pendingFile);
          await api.post(`/admin/products/${created.id}/image`, fd);
        }
      }
      navigate('/products');
    } catch (e: any) {
      setServerError(e.response?.data?.message || e.response?.data?.error || 'Failed to save product');
    }
  };

  return (
    <div className="p-4 md:p-8 max-w-2xl">
      <button onClick={() => navigate('/products')} className="flex items-center gap-2 text-sm text-gray-500 hover:text-gray-900 mb-6">
        <ArrowLeft size={16} /> Back to Products
      </button>

      <h1 className="text-xl md:text-2xl font-bold text-gray-900 mb-6">{isEdit ? 'Edit Product' : 'Add Product'}</h1>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Product Image</label>
          <ImageUpload
            currentUrl={product?.imageUrl}
            onUpload={setPendingFile}
            isUploading={uploadMutation.isPending}
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Name *</label>
            <input {...register('name')} className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
            {errors.name && <p className="text-xs text-red-600 mt-1">{errors.name.message}</p>}
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Slug *</label>
            <input {...register('slug')} className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
            {errors.slug && <p className="text-xs text-red-600 mt-1">{errors.slug.message}</p>}
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
          <textarea {...register('description')} rows={3}
            className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary resize-none" />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Starting Price (PKR) *</label>
            <input {...register('startingPrice')} type="number" min="0" step="1"
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
            {errors.startingPrice && <p className="text-xs text-red-600 mt-1">{errors.startingPrice.message}</p>}
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Category *</label>
            <input {...register('category')} placeholder="e.g. business-cards"
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
            {errors.category && <p className="text-xs text-red-600 mt-1">{errors.category.message}</p>}
          </div>
        </div>

        <div className="flex items-center gap-6">
          <label className="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
            <input {...register('isActive')} type="checkbox" className="rounded border-gray-300 text-primary focus:ring-primary" />
            Active
          </label>
          <label className="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
            <input {...register('isFeatured')} type="checkbox" className="rounded border-gray-300 text-primary focus:ring-primary" />
            Featured
          </label>
        </div>

        {serverError && <div className="bg-red-50 border border-red-200 rounded-lg px-3 py-2 text-sm text-red-700">{serverError}</div>}

        <div className="flex gap-3 pt-2">
          <button type="submit" disabled={isSubmitting}
            className="bg-primary hover:bg-primary-dark text-white px-6 py-2.5 rounded-lg text-sm font-medium transition-colors disabled:opacity-50">
            {isSubmitting ? 'Saving…' : isEdit ? 'Save Changes' : 'Create Product'}
          </button>
          <button type="button" onClick={() => navigate('/products')}
            className="px-6 py-2.5 rounded-lg text-sm font-medium border border-gray-300 text-gray-700 hover:bg-gray-50 transition-colors">
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}
