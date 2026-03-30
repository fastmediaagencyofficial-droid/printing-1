import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, CheckCircle, XCircle } from 'lucide-react';
import { useOrder, useUpdateOrderStatus, useVerifyPayment } from '../../hooks/useOrders';
import { StatusBadge } from '../../components/StatusBadge';

const ORDER_STATUSES = ['PENDING_PAYMENT', 'PAYMENT_UPLOADED', 'CONFIRMED', 'IN_PRODUCTION', 'SHIPPED', 'DELIVERED', 'CANCELLED'];

export default function OrderDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data: order, isLoading, error } = useOrder(id!);
  const statusMutation = useUpdateOrderStatus(id!);
  const paymentMutation = useVerifyPayment(id!);

  if (isLoading) return <div className="p-8 text-gray-400 text-sm">Loading…</div>;
  if (error || !order) return <div className="p-8 text-red-600 text-sm">Order not found.</div>;

  const handleStatusChange = (status: string) => {
    if (!confirm(`Change status to "${status}"?`)) return;
    statusMutation.mutate(status);
  };

  return (
    <div className="p-8 max-w-4xl">
      <button onClick={() => navigate('/orders')} className="flex items-center gap-2 text-sm text-gray-500 hover:text-gray-900 mb-6">
        <ArrowLeft size={16} /> Back to Orders
      </button>

      <div className="flex items-start justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Order {order.orderNumber}</h1>
          <p className="text-sm text-gray-500 mt-1">{new Date(order.createdAt).toLocaleString()}</p>
        </div>
        <StatusBadge status={order.status} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left column */}
        <div className="lg:col-span-2 space-y-6">
          {/* Items */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h2 className="text-base font-semibold text-gray-900 mb-4">Order Items</h2>
            <div className="divide-y divide-gray-50">
              {order.items.map(item => {
                const snapshot = item.productSnapshot || {};
                return (
                  <div key={item.id} className="py-3 flex items-start justify-between gap-4">
                    <div>
                      <p className="font-medium text-gray-900 text-sm">{snapshot.name || 'Product'}</p>
                      <p className="text-xs text-gray-500">Qty: {item.quantity} × ₨{item.unitPrice.toLocaleString()}</p>
                    </div>
                    <p className="font-semibold text-sm">₨{item.totalPrice.toLocaleString()}</p>
                  </div>
                );
              })}
            </div>
            <div className="border-t border-gray-100 pt-3 mt-3 flex justify-between">
              <span className="font-semibold text-gray-900">Total</span>
              <span className="font-bold text-lg">₨{order.totalAmount.toLocaleString()}</span>
            </div>
          </div>

          {/* Payment Proof */}
          {order.paymentProofUrl && (
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h2 className="text-base font-semibold text-gray-900 mb-4">Payment Proof</h2>
              <img src={order.paymentProofUrl} alt="Payment proof" className="max-w-sm rounded-lg border border-gray-200" />
              {order.status === 'PAYMENT_UPLOADED' && (
                <div className="flex gap-3 mt-4">
                  <button onClick={() => paymentMutation.mutate('VERIFY')}
                    disabled={paymentMutation.isPending}
                    className="flex items-center gap-2 bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors disabled:opacity-50">
                    <CheckCircle size={16} /> Verify Payment
                  </button>
                  <button onClick={() => paymentMutation.mutate('REJECT')}
                    disabled={paymentMutation.isPending}
                    className="flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors disabled:opacity-50">
                    <XCircle size={16} /> Reject
                  </button>
                </div>
              )}
              {order.paymentVerifiedAt && (
                <p className="text-xs text-green-600 mt-2">Verified at {new Date(order.paymentVerifiedAt).toLocaleString()}</p>
              )}
            </div>
          )}

          {/* Notes */}
          {order.notes && (
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h2 className="text-base font-semibold text-gray-900 mb-2">Notes</h2>
              <p className="text-sm text-gray-700">{order.notes}</p>
            </div>
          )}
        </div>

        {/* Right column */}
        <div className="space-y-6">
          {/* Customer */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h2 className="text-base font-semibold text-gray-900 mb-3">Customer</h2>
            <p className="font-medium text-gray-900">{order.customer?.name}</p>
            <p className="text-sm text-gray-500">{order.customer?.email}</p>
            {order.customer?.phone && <p className="text-sm text-gray-500">{order.customer.phone}</p>}
          </div>

          {/* Update Status */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h2 className="text-base font-semibold text-gray-900 mb-3">Update Status</h2>
            <div className="space-y-2">
              {ORDER_STATUSES.map(s => (
                <button key={s} onClick={() => handleStatusChange(s)}
                  disabled={order.status === s || statusMutation.isPending}
                  className={`w-full text-left px-3 py-2 rounded-lg text-xs font-medium transition-colors ${order.status === s
                    ? 'bg-primary-surface text-primary border border-primary/20'
                    : 'border border-gray-200 text-gray-600 hover:bg-gray-50 disabled:opacity-50'}`}>
                  {s.replace(/_/g, ' ')}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
