import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Eye } from 'lucide-react';
import { useQuotes } from '../../hooks/useQuotes';
import { StatusBadge } from '../../components/StatusBadge';

const STATUS_FILTERS = ['ALL', 'PENDING', 'REVIEWED', 'SENT', 'ACCEPTED', 'REJECTED'];

export default function QuoteListPage() {
  const [statusFilter, setStatusFilter] = useState('ALL');
  const { data: quotes = [], isLoading } = useQuotes(statusFilter === 'ALL' ? undefined : statusFilter);

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Quotes</h1>
        <p className="text-sm text-gray-500 mt-1">{quotes.length} quote requests</p>
      </div>

      <div className="flex gap-2 flex-wrap mb-4">
        {STATUS_FILTERS.map(s => (
          <button key={s} onClick={() => setStatusFilter(s)}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${statusFilter === s ? 'bg-primary text-white' : 'bg-white border border-gray-200 text-gray-600 hover:bg-gray-50'}`}>
            {s}
          </button>
        ))}
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-100">
        {isLoading ? (
          <div className="p-8 text-center text-gray-400 text-sm">Loading…</div>
        ) : quotes.length === 0 ? (
          <div className="p-8 text-center text-gray-400 text-sm">No quotes found.</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-xs text-gray-500 border-b border-gray-100">
                  <th className="px-6 py-3 font-medium">Customer</th>
                  <th className="px-6 py-3 font-medium">Product Type</th>
                  <th className="px-6 py-3 font-medium">Qty</th>
                  <th className="px-6 py-3 font-medium">Budget</th>
                  <th className="px-6 py-3 font-medium">Status</th>
                  <th className="px-6 py-3 font-medium">Date</th>
                  <th className="px-6 py-3 font-medium"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {quotes.map(q => (
                  <tr key={q.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <p className="font-medium text-gray-900">{q.user?.name || '—'}</p>
                      <p className="text-xs text-gray-500">{q.user?.email}</p>
                    </td>
                    <td className="px-6 py-4 text-gray-700">{q.productType}</td>
                    <td className="px-6 py-4 text-gray-600">{q.quantity.toLocaleString()}</td>
                    <td className="px-6 py-4 text-gray-600">{q.budgetRange || '—'}</td>
                    <td className="px-6 py-4"><StatusBadge status={q.status} /></td>
                    <td className="px-6 py-4 text-gray-500">{new Date(q.createdAt).toLocaleDateString()}</td>
                    <td className="px-6 py-4 text-right">
                      <Link to={`/quotes/${q.id}`} className="p-1.5 hover:bg-gray-100 rounded-lg text-gray-500 inline-flex">
                        <Eye size={15} />
                      </Link>
                    </td>
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
