import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../services/api';

export interface AdminIndustry {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  imageUrl: string | null;
  sortOrder: number;
  createdAt: string;
}

const KEY = ['admin', 'industries'];

export function useIndustries() {
  return useQuery<AdminIndustry[]>({
    queryKey: KEY,
    queryFn: () => api.get('/admin/industries').then(r => r.data.data),
  });
}

export function useCreateIndustry() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (body: Partial<AdminIndustry>) => api.post('/admin/industries', body).then(r => r.data.data),
    onSuccess: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}

export function useUpdateIndustry(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (body: Partial<AdminIndustry>) => api.put(`/admin/industries/${id}`, body).then(r => r.data.data),
    onSuccess: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}

export function useUploadIndustryImage(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (file: File) => {
      const fd = new FormData();
      fd.append('image', file);
      return api.post(`/admin/industries/${id}/image`, fd).then(r => r.data.data);
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}
