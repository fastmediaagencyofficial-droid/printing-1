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
    <div className="bg-white rounded-xl p-4 md:p-5 shadow-sm border border-gray-100">
      <div className="flex items-center justify-between gap-2">
        <div className="min-w-0">
          <p className="text-xs text-gray-500 truncate">{label}</p>
          <p className="text-xl md:text-2xl font-bold text-gray-900 mt-0.5 truncate">{value}</p>
        </div>
        <div className={`w-10 h-10 md:w-12 md:h-12 rounded-xl flex items-center justify-center shrink-0 ${color}`}>
          <Icon size={20} />
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
    <div className="p-4 md:p-8">
      <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-6 gap-3 mb-8">
        {Array.from({ length: 6 }).map((_, i) => (
          <div key={i} className="bg-white rounded-xl p-4 md:p-5 shadow-sm border border-gray-100 animate-pulse">
            <div className="h-3 bg-gray-200 rounded mb-3 w-3/4" />
            <div className="h-7 bg-gray-200 rounded w-1/2" />
          </div>
        ))}
      </div>
    </div>
  );

  if (error) return (
    <div className="p-4 md:p-8">
      <div className="bg-red-50 border border-red-200 rounded-xl p-4 text-red-700 text-sm">
        Failed to load dashboard data.
      </div>
    </div>
  );

  const d = data!;

  return (
    <div className="p-4 md:p-8">
      <div className="mb-5">
        <h1 className="text-xl md:text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-sm text-gray-500 mt-1">Overview of your business metrics</p>
      </div>

      {/* Stat Cards */}
      <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-6 gap-3 mb-6">
        <StatCard icon={ShoppingCart} label="Total Orders"     value={d.totalOrders}      color="bg-blue-50 text-blue-600" />
        <StatCard icon={DollarSign}  label="Revenue (PKR)"    value={`₨${(d.totalRevenue ?? 0).toLocaleString()}`} color="bg-green-50 text-green-600" />
        <StatCard icon={Clock}       label="Pending Payments"  value={d.pendingPayments}   color="bg-yellow-50 text-yellow-600" />
        <StatCard icon={Mail}        label="Unread Contacts"   value={d.unreadContacts}    color="bg-red-50 text-red-600" />
        <StatCard icon={Package}     label="Products"          value={d.totalProducts}     color="bg-purple-50 text-purple-600" />
        <StatCard icon={MessageSquare} label="Pending Quotes"  value={d.pendingQuotes}     color="bg-indigo-50 text-indigo-600" />
      </div>

      {/* Orders by Status */}
      {d.ordersByStatus && Object.keys(d.ordersByStatus).length > 0 && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 md:p-6 mb-6">
          <h2 className="text-sm font-semibold text-gray-900 mb-3">Orders by Status</h2>
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
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 md:p-6">
        <h2 className="text-sm font-semibold text-gray-900 mb-4">Recent Orders</h2>
        {d.recentOrders.length === 0 ? (
          <p className="text-sm text-gray-500">No orders yet.</p>
        ) : (
          <>
            {/* Desktop table */}
            <div className="hidden md:block overflow-x-auto">
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
                      <td className="py-3 font-medium">₨{(order.totalAmount ?? 0).toLocaleString()}</td>
                      <td className="py-3"><StatusBadge status={order.status} /></td>
                      <td className="py-3 text-gray-500">{new Date(order.createdAt).toLocaleDateString()}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Mobile cards */}
            <div className="md:hidden space-y-3">
              {d.recentOrders.map(order => (
                <div key={order.id} className="border border-gray-100 rounded-lg p-3">
                  <div className="flex items-start justify-between gap-2 mb-2">
                    <p className="font-mono text-xs text-gray-500">{order.orderNumber}</p>
                    <StatusBadge status={order.status} />
                  </div>
                  <p className="text-sm font-medium text-gray-900">{order.customer?.name || '—'}</p>
                  <p className="text-xs text-gray-500 mb-2">{order.customer?.email}</p>
                  <div className="flex items-center justify-between text-xs text-gray-500">
                    <span className="font-semibold text-gray-900">₨{(order.totalAmount ?? 0).toLocaleString()}</span>
                    <span>{new Date(order.createdAt).toLocaleDateString()}</span>
                  </div>
                </div>
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
}
