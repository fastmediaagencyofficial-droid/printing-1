import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../services/api';

export interface AdminProduct {
  id: string;
  name: string;
  slug: string;
  description: string;
  basePrice: number;
  imageUrl: string | null;
  category: string;
  isActive: boolean;
  isFeatured: boolean;
  createdAt: string;
}

const KEY = ['admin', 'products'];

export function useProducts() {
  return useQuery<AdminProduct[]>({
    queryKey: KEY,
    queryFn: () => api.get('/admin/products').then(r => r.data.data),
  });
}

export function useCreateProduct() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (body: Partial<AdminProduct>) => api.post('/admin/products', body).then(r => r.data.data),
    onSuccess: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}

export function useUpdateProduct(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (body: Partial<AdminProduct>) => api.put(`/admin/products/${id}`, body).then(r => r.data.data),
    onSuccess: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}

export function useDeleteProduct() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/admin/products/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}

export function useUploadProductImage(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (file: File) => {
      const fd = new FormData();
      fd.append('image', file);
      return api.post(`/admin/products/${id}/image`, fd).then(r => r.data.data);
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}
