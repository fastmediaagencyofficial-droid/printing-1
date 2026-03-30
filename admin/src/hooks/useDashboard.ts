import { useQuery } from '@tanstack/react-query';
import { api } from '../services/api';

export interface DashboardData {
  totalOrders: number;
  totalRevenue: number;
  pendingPayments: number;
  unreadContacts: number;
  totalProducts: number;
  pendingQuotes: number;
  ordersByStatus: Record<string, number>;
  recentOrders: Array<{
    id: string;
    orderNumber: string;
    customer: { name: string; email: string };
    totalAmount: number;
    status: string;
    createdAt: string;
  }>;
}

export function useDashboard() {
  return useQuery<DashboardData>({
    queryKey: ['dashboard'],
    queryFn: () => api.get('/admin/dashboard').then(r => r.data.data),
    refetchInterval: 60_000,
  });
}
