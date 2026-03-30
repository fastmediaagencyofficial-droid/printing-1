import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../services/api';

export interface AdminOrder {
  id: string;
  orderNumber: string;
  status: string;
  totalAmount: number;
  notes: string | null;
  paymentProofUrl: string | null;
  paymentVerifiedAt: string | null;
  createdAt: string;
  updatedAt: string;
  customer: { id: string; name: string; email: string; phone: string | null };
  items: Array<{
    id: string;
    quantity: number;
    unitPrice: number;
    totalPrice: number;
    productSnapshot: any;
  }>;
}

const LIST_KEY = ['admin', 'orders'];

export function useOrders(status?: string) {
  return useQuery<AdminOrder[]>({
    queryKey: [...LIST_KEY, status],
    queryFn: () => api.get('/admin/orders', { params: status ? { status } : {} }).then(r => r.data.data),
  });
}

export function useOrder(id: string) {
  return useQuery<AdminOrder>({
    queryKey: [...LIST_KEY, id],
    queryFn: () => api.get(`/admin/orders/${id}`).then(r => r.data.data),
    enabled: Boolean(id),
  });
}

export function useUpdateOrderStatus(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (status: string) => api.put(`/admin/orders/${id}`, { status }).then(r => r.data.data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: LIST_KEY });
      qc.invalidateQueries({ queryKey: [...LIST_KEY, id] });
    },
  });
}

export function useVerifyPayment(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (action: 'VERIFY' | 'REJECT') => api.put(`/admin/orders/${id}/verify-payment`, { action }).then(r => r.data.data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: LIST_KEY });
      qc.invalidateQueries({ queryKey: [...LIST_KEY, id] });
    },
  });
}
