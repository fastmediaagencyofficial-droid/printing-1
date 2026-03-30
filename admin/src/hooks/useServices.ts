import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../services/api';

export interface AdminService {
  id: string;
  name: string;
  slug: string;
  description: string;
  shortDescription: string | null;
  imageUrl: string | null;
  icon: string | null;
  isActive: boolean;
  sortOrder: number;
  createdAt: string;
}

const KEY = ['admin', 'services'];

export function useServices() {
  return useQuery<AdminService[]>({
    queryKey: KEY,
    queryFn: () => api.get('/admin/services').then(r => r.data.data),
  });
}

export function useUpdateService(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (body: Partial<AdminService>) => api.put(`/admin/services/${id}`, body).then(r => r.data.data),
    onSuccess: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}

export function useUploadServiceImage(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (file: File) => {
      const fd = new FormData();
      fd.append('image', file);
      return api.post(`/admin/services/${id}/image`, fd).then(r => r.data.data);
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}
