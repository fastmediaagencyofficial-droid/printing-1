import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../services/api';

export interface AdminContact {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  subject: string | null;
  message: string;
  isRead: boolean;
  createdAt: string;
}

const KEY = ['admin', 'contacts'];

export function useContacts(unreadOnly?: boolean) {
  return useQuery<AdminContact[]>({
    queryKey: [...KEY, unreadOnly],
    queryFn: () => api.get('/admin/contacts', { params: { limit: 200, ...(unreadOnly ? { unread: true } : {}) } }).then(r => r.data.data.contacts ?? r.data.data),
  });
}

export function useMarkContactRead() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.put(`/admin/contacts/${id}/read`),
    onSuccess: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}
