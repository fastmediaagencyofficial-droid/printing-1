import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, CheckCircle, XCircle } from 'lucide-react';
import { useOrder, useUpdateOrderStatus, useVerifyPayment } from '../../hooks/useOrders';
import { StatusBadge } from '../../components/StatusBadge';

const ORDER_STATUSES = ['PENDING_PAYMENT', 'PAYMENT_UPLOADED', 'CONFIRMED', 'IN_PRODUCTION', 'SHIPPED', 'DELIVERED', 'CANCELLED'];

function InfoRow({ label, value }: { label: string; value?: string | null }) {
  if (!value) return null;
  return (
    <div className="flex flex-col sm:flex-row sm:gap-2">
      <span className="text-xs text-gray-400 sm:w-32 shrink-0">{label}</span>
      <span className="text-sm text-gray-800 font-medium">{value}</span>
    </div>
  );
}

export default function OrderDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data: order, isLoading, error } = useOrder(id!);
  const statusMutation = useUpdateOrderStatus(id!);
  const paymentMutation = useVerifyPayment(id!);

  if (isLoading) return <div className="p-4 md:p-8 text-gray-400 text-sm">Loading…</div>;
  if (error || !order) return <div className="p-4 md:p-8 text-red-600 text-sm">Order not found.</div>;

  const handleStatusChange = (status: string) => {
    if (!confirm(`Change status to "${status}"?`)) return;
    statusMutation.mutate(status);
  };

  return (
    <div className="p-4 md:p-8 max-w-4xl">
      <button onClick={() => navigate('/orders')} className="flex items-center gap-2 text-sm text-gray-500 hover:text-gray-900 mb-5">
        <ArrowLeft size={16} /> Back to Orders
      </button>

      <div className="flex items-start justify-between mb-5 gap-3">
        <div>
          <h1 className="text-xl md:text-2xl font-bold text-gray-900">Order {order.orderNumber}</h1>
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
              {order.items.map(item => (
                <div key={item.id} className="py-3 flex items-start justify-between gap-4">
                  <div>
                    <p className="font-medium text-gray-900 text-sm">
                      {item.productName || item.productSnapshot?.name || 'Product'}
                    </p>
                    <p className="text-xs text-gray-500">Qty: {item.quantity} × ₨{(item.unitPrice ?? 0).toLocaleString()}</p>
                  </div>
                  <p className="font-semibold text-sm">₨{(item.totalPrice ?? 0).toLocaleString()}</p>
                </div>
              ))}
            </div>
            <div className="border-t border-gray-100 pt-3 mt-3 flex justify-between">
              <span className="font-semibold text-gray-900">Total</span>
              <span className="font-bold text-lg">₨{(order.totalAmount ?? 0).toLocaleString()}</span>
            </div>
          </div>

          {/* Print Job Details */}
          {(order.printDetails?.description || order.printDetails?.size || order.printDetails?.category) && (
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h2 className="text-base font-semibold text-gray-900 mb-4">Print Job Details</h2>
              <div className="space-y-3">
                <InfoRow label="Category" value={order.printDetails?.category} />
                <InfoRow label="Size" value={order.printDetails?.size} />
                <InfoRow label="Description" value={order.printDetails?.description} />
              </div>
            </div>
          )}

          {/* Delivery Address */}
          {(order.shippingStreet || order.shippingCity) && (
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h2 className="text-base font-semibold text-gray-900 mb-4">Delivery Address</h2>
              <div className="space-y-3">
                <InfoRow label="Street" value={order.shippingStreet} />
                <InfoRow label="City" value={order.shippingCity} />
                <InfoRow label="Province" value={order.shippingProvince} />
              </div>
            </div>
          )}

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
              <h2 className="text-base font-semibold text-gray-900 mb-2">Customer Notes</h2>
              <p className="text-sm text-gray-700">{order.notes}</p>
            </div>
          )}

          {/* Admin Notes */}
          {order.adminNotes && (
            <div className="bg-amber-50 rounded-xl border border-amber-200 p-6">
              <h2 className="text-base font-semibold text-amber-800 mb-2">Admin Notes</h2>
              <p className="text-sm text-amber-700">{order.adminNotes}</p>
            </div>
          )}
        </div>

        {/* Right column */}
        <div className="space-y-6">
          {/* Customer */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h2 className="text-base font-semibold text-gray-900 mb-4">Customer</h2>
            <div className="space-y-3">
              <InfoRow label="Name" value={order.customer?.name} />
              <InfoRow label="Email" value={order.customer?.email} />
              <InfoRow label="Phone" value={order.customer?.phone} />
            </div>
          </div>

          {/* Payment */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h2 className="text-base font-semibold text-gray-900 mb-3">Payment</h2>
            <InfoRow label="Method" value={order.paymentMethod} />
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
