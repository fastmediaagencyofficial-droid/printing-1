import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import { useQuotes, useUpdateQuote } from '../../hooks/useQuotes';
import { StatusBadge } from '../../components/StatusBadge';

const QUOTE_STATUSES = ['PENDING', 'REVIEWED', 'SENT', 'ACCEPTED', 'REJECTED'];

export default function QuoteDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data: quotes = [], isLoading } = useQuotes();
  const quote = quotes.find(q => q.id === id);
  const updateMutation = useUpdateQuote(id!);

  const [adminResponse, setAdminResponse] = useState(quote?.adminNotes ?? '');
  const [estimatedPrice, setEstimatedPrice] = useState(String(quote?.quotedPrice ?? ''));
  const [status, setStatus] = useState(quote?.status ?? 'PENDING');
  const [saved, setSaved] = useState(false);

  if (isLoading) return <div className="p-8 text-gray-400 text-sm">Loading…</div>;
  if (!quote) return <div className="p-8 text-red-600 text-sm">Quote not found.</div>;

  const handleSave = async () => {
    await updateMutation.mutateAsync({
      status,
      adminResponse: adminResponse || undefined,
      estimatedPrice: estimatedPrice ? Number(estimatedPrice) : undefined,
    });
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <div className="p-8 max-w-3xl">
      <button onClick={() => navigate('/quotes')} className="flex items-center gap-2 text-sm text-gray-500 hover:text-gray-900 mb-6">
        <ArrowLeft size={16} /> Back to Quotes
      </button>

      <div className="flex items-start justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Quote Request</h1>
          <p className="text-sm text-gray-500 mt-1">{new Date(quote.createdAt).toLocaleString()}</p>
        </div>
        <StatusBadge status={quote.status} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Quote details */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 space-y-4">
          <h2 className="text-base font-semibold text-gray-900">Request Details</h2>
          <dl className="space-y-3 text-sm">
            <div className="flex justify-between">
              <dt className="text-gray-500">Customer</dt>
              <dd className="font-medium text-gray-900">{quote.user?.name}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">Email</dt>
              <dd className="text-gray-700">{quote.user?.email}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">Product Type</dt>
              <dd className="font-medium text-gray-900">{quote.productType}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">Quantity</dt>
              <dd className="text-gray-700">{quote.quantity.toLocaleString()}</dd>
            </div>
            {quote.budgetRange && (
              <div className="flex justify-between">
                <dt className="text-gray-500">Budget</dt>
                <dd className="text-gray-700">{quote.budgetRange}</dd>
              </div>
            )}
            {quote.deadline && (
              <div className="flex justify-between">
                <dt className="text-gray-500">Deadline</dt>
                <dd className="text-gray-700">{new Date(quote.deadline).toLocaleDateString()}</dd>
              </div>
            )}
          </dl>
          {quote.specifications && (
            <div>
              <p className="text-xs font-medium text-gray-500 mb-1">Specifications</p>
              <p className="text-sm text-gray-700 whitespace-pre-wrap">{quote.specifications}</p>
            </div>
          )}
          {quote.notes && (
            <div>
              <p className="text-xs font-medium text-gray-500 mb-1">Customer Notes</p>
              <p className="text-sm text-gray-700 whitespace-pre-wrap">{quote.notes}</p>
            </div>
          )}
        </div>

        {/* Admin response */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 space-y-4">
          <h2 className="text-base font-semibold text-gray-900">Admin Response</h2>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
            <select value={status} onChange={e => setStatus(e.target.value)}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary">
              {QUOTE_STATUSES.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Quoted Price (PKR)</label>
            <input type="number" min="0" value={estimatedPrice} onChange={e => setEstimatedPrice(e.target.value)}
              placeholder="e.g. 15000"
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Response to Customer</label>
            <textarea rows={4} value={adminResponse} onChange={e => setAdminResponse(e.target.value)}
              placeholder="Internal notes or quote details to send…"
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary resize-none" />
          </div>

          <button onClick={handleSave} disabled={updateMutation.isPending}
            className="w-full bg-primary hover:bg-primary-dark text-white py-2.5 rounded-lg text-sm font-medium transition-colors disabled:opacity-50">
            {updateMutation.isPending ? 'Saving…' : saved ? 'Saved!' : 'Save Response'}
          </button>
        </div>
      </div>
    </div>
  );
}
