import { useQuery } from '@tanstack/react-query';
import { ShoppingCart, DollarSign, Clock, Mail, Package, MessageSquare } from 'lucide-react';
import { api } from '../services/api';
import { StatusBadge } from '../components/StatusBadge';

interface DashboardData {
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

function StatCard({ icon: Icon, label, value, color }: { icon: any; label: string; value: number | string; color: string }) {
  return (
    <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm text-gray-500">{label}</p>
          <p className="text-2xl font-bold text-gray-900 mt-1">{value}</p>
        </div>
        <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${color}`}>
          <Icon size={22} />
        </div>
      </div>
    </div>
  );
}

export default function DashboardPage() {
  const { data, isLoading, error } = useQuery<DashboardData>({
    queryKey: ['dashboard'],
    queryFn: () => api.get('/admin/dashboard').then(r => r.data.data),
    refetchInterval: 60_000,
  });

  if (isLoading) return (
    <div className="p-8">
      <div className="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4 mb-8">
        {Array.from({ length: 6 }).map((_, i) => (
          <div key={i} className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 animate-pulse">
            <div className="h-4 bg-gray-200 rounded mb-3 w-3/4" />
            <div className="h-8 bg-gray-200 rounded w-1/2" />
          </div>
        ))}
      </div>
    </div>
  );

  if (error) return (
    <div className="p-8">
      <div className="bg-red-50 border border-red-200 rounded-xl p-4 text-red-700">
        Failed to load dashboard data.
      </div>
    </div>
  );

  const d = data!;

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-sm text-gray-500 mt-1">Overview of your business metrics</p>
      </div>

      {/* Stat Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4 mb-8">
        <StatCard icon={ShoppingCart} label="Total Orders" value={d.totalOrders} color="bg-blue-50 text-blue-600" />
        <StatCard icon={DollarSign} label="Revenue (PKR)" value={`₨${d.totalRevenue.toLocaleString()}`} color="bg-green-50 text-green-600" />
        <StatCard icon={Clock} label="Pending Payments" value={d.pendingPayments} color="bg-yellow-50 text-yellow-600" />
        <StatCard icon={Mail} label="Unread Contacts" value={d.unreadContacts} color="bg-red-50 text-red-600" />
        <StatCard icon={Package} label="Products" value={d.totalProducts} color="bg-purple-50 text-purple-600" />
        <StatCard icon={MessageSquare} label="Pending Quotes" value={d.pendingQuotes} color="bg-indigo-50 text-indigo-600" />
      </div>

      {/* Orders by Status */}
      {d.ordersByStatus && Object.keys(d.ordersByStatus).length > 0 && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 mb-6">
          <h2 className="text-base font-semibold text-gray-900 mb-4">Orders by Status</h2>
          <div className="flex flex-wrap gap-3">
            {Object.entries(d.ordersByStatus).map(([status, count]) => (
              <div key={status} className="flex items-center gap-2">
                <StatusBadge status={status} />
                <span className="text-sm font-semibold text-gray-700">{count}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Recent Orders */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
        <h2 className="text-base font-semibold text-gray-900 mb-4">Recent Orders</h2>
        {d.recentOrders.length === 0 ? (
          <p className="text-sm text-gray-500">No orders yet.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-xs text-gray-500 border-b border-gray-100">
                  <th className="pb-3 font-medium">Order #</th>
                  <th className="pb-3 font-medium">Customer</th>
                  <th className="pb-3 font-medium">Amount</th>
                  <th className="pb-3 font-medium">Status</th>
                  <th className="pb-3 font-medium">Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {d.recentOrders.map(order => (
                  <tr key={order.id} className="hover:bg-gray-50">
                    <td className="py-3 font-mono text-xs text-gray-600">{order.orderNumber}</td>
                    <td className="py-3">
                      <p className="font-medium text-gray-900">{order.customer?.name || '—'}</p>
                      <p className="text-xs text-gray-500">{order.customer?.email}</p>
                    </td>
                    <td className="py-3 font-medium">₨{order.totalAmount.toLocaleString()}</td>
                    <td className="py-3"><StatusBadge status={order.status} /></td>
                    <td className="py-3 text-gray-500">{new Date(order.createdAt).toLocaleDateString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
