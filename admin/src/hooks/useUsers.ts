import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../services/api';

export interface AdminUser {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  role: string;
  isActive: boolean;
  createdAt: string;
  _count: { orders: number };
}

const KEY = ['admin', 'users'];

export function useUsers() {
  return useQuery<AdminUser[]>({
    queryKey: KEY,
    queryFn: () => api.get('/admin/users').then(r => r.data.data),
  });
}

export function useUpdateUserRole(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (role: string) => api.put(`/admin/users/${id}/role`, { role }).then(r => r.data.data),
    onSuccess: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}
