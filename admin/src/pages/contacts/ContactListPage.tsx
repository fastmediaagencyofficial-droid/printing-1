import { useState } from 'react';
import { MailOpen, Mail } from 'lucide-react';
import { useContacts, useMarkContactRead } from '../../hooks/useContacts';

export default function ContactListPage() {
  const [unreadOnly, setUnreadOnly] = useState(false);
  const { data: contacts = [], isLoading } = useContacts(unreadOnly);
  const markReadMutation = useMarkContactRead();
  const [expanded, setExpanded] = useState<string | null>(null);

  return (
    <div className="p-4 md:p-8">
      <div className="flex items-center justify-between mb-5 gap-3 flex-wrap">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Contact Messages</h1>
          <p className="text-sm text-gray-500 mt-1">{contacts.length} messages</p>
        </div>
        <label className="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
          <input type="checkbox" checked={unreadOnly} onChange={e => setUnreadOnly(e.target.checked)}
            className="rounded border-gray-300 text-primary focus:ring-primary" />
          Unread only
        </label>
      </div>

      <div className="space-y-3">
        {isLoading ? (
          <div className="text-gray-400 text-sm">Loading…</div>
        ) : contacts.length === 0 ? (
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 text-center text-gray-400 text-sm">
            No messages found.
          </div>
        ) : contacts.map(c => (
          <div key={c.id} className={`bg-white rounded-xl shadow-sm border transition-colors ${c.isRead ? 'border-gray-100' : 'border-primary/30 bg-primary-surface/20'}`}>
            <div
              className="px-6 py-4 flex items-start justify-between gap-4 cursor-pointer"
              onClick={() => {
                setExpanded(expanded === c.id ? null : c.id);
                if (!c.isRead) markReadMutation.mutate(c.id);
              }}>
              <div className="flex items-start gap-3">
                <div className={`mt-0.5 ${c.isRead ? 'text-gray-400' : 'text-primary'}`}>
                  {c.isRead ? <MailOpen size={16} /> : <Mail size={16} />}
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <p className={`text-sm ${c.isRead ? 'font-normal text-gray-900' : 'font-semibold text-gray-900'}`}>{c.name}</p>
                    <span className="text-xs text-gray-500">{c.email}</span>
                    {c.phone && <span className="text-xs text-gray-500">· {c.phone}</span>}
                  </div>
                  {c.subject && <p className="text-xs text-gray-600 mt-0.5">{c.subject}</p>}
                  {expanded !== c.id && <p className="text-xs text-gray-500 mt-1 truncate max-w-xl">{c.message}</p>}
                </div>
              </div>
              <span className="text-xs text-gray-400 shrink-0">{new Date(c.createdAt).toLocaleDateString()}</span>
            </div>
            {expanded === c.id && (
              <div className="px-6 pb-4 border-t border-gray-100 pt-4">
                <p className="text-sm text-gray-700 whitespace-pre-wrap">{c.message}</p>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
