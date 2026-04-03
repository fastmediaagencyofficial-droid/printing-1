import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../services/api';

export interface AdminQuote {
  id: string;
  status: string;
  productType: string;
  quantity: number;
  specifications: string | null;
  budgetRange: string | null;
  deadline: string | null;
  notes: string | null;
  adminNotes: string | null;
  quotedPrice: number | null;
  createdAt: string;
  user: { id: string; name: string; email: string };
}

const KEY = ['admin', 'quotes'];

export function useQuotes(status?: string) {
  return useQuery<AdminQuote[]>({
    queryKey: [...KEY, status],
    queryFn: () => api.get('/admin/quotes', { params: { limit: 200, ...(status ? { status } : {}) } }).then(r => r.data.data.quotes ?? r.data.data),
  });
}

export function useUpdateQuote(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (body: { status?: string; adminResponse?: string; estimatedPrice?: number }) =>
      api.put(`/admin/quotes/${id}`, body).then(r => r.data.data),
    onSuccess: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}
