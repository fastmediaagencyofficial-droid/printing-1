import { useState } from 'react';
import { Plus, Pencil, X, Check } from 'lucide-react';
import { useIndustries, useCreateIndustry, useUpdateIndustry, useUploadIndustryImage } from '../../hooks/useIndustries';
import ImageUpload from '../../components/ImageUpload';

type Mode = 'list' | 'create' | { edit: string };

export default function IndustryListPage() {
  const { data: industries = [], isLoading } = useIndustries();
  const createMutation = useCreateIndustry();
  const [mode, setMode] = useState<Mode>('list');
  const [form, setForm] = useState({ name: '', slug: '', description: '', sortOrder: '0' });
  const [pendingFile, setPendingFile] = useState<File | null>(null);
  const [error, setError] = useState('');

  const editingId = typeof mode === 'object' ? mode.edit : null;
  const editInd = editingId ? industries.find(i => i.id === editingId) : null;
  const updateMutation = useUpdateIndustry(editingId ?? '');
  const uploadMutation = useUploadIndustryImage(editingId ?? '');

  const openCreate = () => {
    setForm({ name: '', slug: '', description: '', sortOrder: String(industries.length) });
    setPendingFile(null); setError('');
    setMode('create');
  };

  const openEdit = (id: string) => {
    const ind = industries.find(i => i.id === id)!;
    setForm({ name: ind.name, slug: ind.slug, description: ind.description ?? '', sortOrder: String(ind.sortOrder) });
    setPendingFile(null); setError('');
    setMode({ edit: id });
  };

  const handleSave = async () => {
    setError('');
    if (!form.name.trim() || !form.slug.trim()) { setError('Name and slug are required'); return; }
    try {
      const body = { name: form.name, slug: form.slug, description: form.description, sortOrder: Number(form.sortOrder) };
      if (mode === 'create') {
        await createMutation.mutateAsync(body);
      } else if (editingId) {
        await updateMutation.mutateAsync(body);
        if (pendingFile) await uploadMutation.mutateAsync(pendingFile);
      }
      setMode('list');
    } catch (e: any) {
      setError(e.response?.data?.error || 'Failed to save');
    }
  };

  const isFormOpen = mode !== 'list';
  const isSaving = createMutation.isPending || updateMutation.isPending;

  return (
    <div className="p-4 md:p-8">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-xl md:text-2xl font-bold text-gray-900">Industries</h1>
          <p className="text-sm text-gray-500 mt-1">{industries.length} industries</p>
        </div>
        {!isFormOpen && (
          <button onClick={openCreate}
            className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
            <Plus size={16} /> Add Industry
          </button>
        )}
      </div>

      {isFormOpen && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 mb-6">
          <h2 className="text-base font-semibold text-gray-900 mb-4">{mode === 'create' ? 'New Industry' : `Edit: ${editInd?.name}`}</h2>
          <div className="space-y-4 max-w-lg">
            {editingId && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Image</label>
                <ImageUpload currentUrl={editInd?.imageUrl} onUpload={setPendingFile} isUploading={uploadMutation.isPending} />
              </div>
            )}
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Name *</label>
                <input value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Slug *</label>
                <input value={form.slug} onChange={e => setForm(f => ({ ...f, slug: e.target.value }))}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
              <input value={form.description} onChange={e => setForm(f => ({ ...f, description: e.target.value }))}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Sort Order</label>
              <input type="number" min="0" value={form.sortOrder} onChange={e => setForm(f => ({ ...f, sortOrder: e.target.value }))}
                className="w-32 border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary" />
            </div>
            {error && <p className="text-sm text-red-600">{error}</p>}
            <div className="flex gap-3">
              <button onClick={handleSave} disabled={isSaving}
                className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors disabled:opacity-50">
                <Check size={14} /> {isSaving ? 'Saving…' : 'Save'}
              </button>
              <button onClick={() => setMode('list')}
                className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium border border-gray-300 text-gray-700 hover:bg-gray-50">
                <X size={14} /> Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="bg-white rounded-xl shadow-sm border border-gray-100">
        {isLoading ? (
          <div className="p-8 text-center text-gray-400 text-sm">Loading…</div>
        ) : industries.length === 0 ? (
          <div className="p-8 text-center text-gray-400 text-sm">No industries yet.</div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 p-6">
            {industries.map(ind => (
              <div key={ind.id} className="border border-gray-100 rounded-xl overflow-hidden">
                {ind.imageUrl ? (
                  <img src={ind.imageUrl} alt={ind.name} className="w-full h-32 object-cover" />
                ) : (
                  <div className="w-full h-32 bg-gray-100" />
                )}
                <div className="p-3">
                  <p className="font-medium text-gray-900 text-sm">{ind.name}</p>
                  <p className="text-xs text-gray-500 mt-0.5 truncate">{ind.description}</p>
                  <button onClick={() => openEdit(ind.id)}
                    className="mt-2 flex items-center gap-1 text-xs text-primary hover:underline">
                    <Pencil size={11} /> Edit
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
