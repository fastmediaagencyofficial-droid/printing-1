import { useState } from 'react';
import { Plus, Pencil, Trash2, X, Check } from 'lucide-react';
import { useCategories, useCreateCategory, useUpdateCategory, useDeleteCategory, useUploadCategoryImage } from '../../hooks/useCategories';
import ImageUpload from '../../components/ImageUpload';

type Mode = 'list' | 'create' | { edit: string };

export default function CategoryListPage() {
  const { data: categories = [], isLoading } = useCategories();
  const createMutation = useCreateCategory();
  const deleteMutation = useDeleteCategory();
  const [mode, setMode] = useState<Mode>('list');
  const [form, setForm] = useState({ name: '', slug: '', description: '', sortOrder: '0' });
  const [pendingFile, setPendingFile] = useState<File | null>(null);
  const [error, setError] = useState('');

  const editingId = typeof mode === 'object' ? mode.edit : null;
  const editCat = editingId ? categories.find(c => c.id === editingId) : null;

  const updateMutation = useUpdateCategory(editingId ?? '');
  const uploadMutation = useUploadCategoryImage(editingId ?? '');

  const openCreate = () => {
    setForm({ name: '', slug: '', description: '', sortOrder: '0' });
    setPendingFile(null); setError('');
    setMode('create');
  };

  const openEdit = (id: string) => {
    const cat = categories.find(c => c.id === id)!;
    setForm({ name: cat.name, slug: cat.slug, description: cat.description ?? '', sortOrder: String(cat.sortOrder) });
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

  const handleDelete = (id: string, name: string) => {
    if (!confirm(`Delete category "${name}"?`)) return;
    deleteMutation.mutate(id);
  };

  const isFormOpen = mode !== 'list';
  const isSaving = createMutation.isPending || updateMutation.isPending;

  return (
    <div className="p-4 md:p-8">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-xl md:text-2xl font-bold text-gray-900">Categories</h1>
          <p className="text-sm text-gray-500 mt-1">{categories.length} categories</p>
        </div>
        {!isFormOpen && (
          <button onClick={openCreate}
            className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
            <Plus size={16} /> Add Category
          </button>
        )}
      </div>

      {isFormOpen && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 mb-6">
          <h2 className="text-base font-semibold text-gray-900 mb-4">{mode === 'create' ? 'New Category' : `Edit: ${editCat?.name}`}</h2>
          <div className="space-y-4 max-w-lg">
            {editingId && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Image</label>
                <ImageUpload currentUrl={editCat?.imageUrl} onUpload={setPendingFile} isUploading={uploadMutation.isPending} />
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
        ) : categories.length === 0 ? (
          <div className="p-8 text-center text-gray-400 text-sm">No categories yet.</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-xs text-gray-500 border-b border-gray-100">
                  <th className="px-6 py-3 font-medium">Category</th>
                  <th className="px-6 py-3 font-medium">Slug</th>
                  <th className="px-6 py-3 font-medium">Sort</th>
                  <th className="px-6 py-3 font-medium"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {categories.map(c => (
                  <tr key={c.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        {c.imageUrl ? (
                          <img src={c.imageUrl} alt={c.name} className="w-8 h-8 rounded-lg object-cover" />
                        ) : (
                          <div className="w-8 h-8 rounded-lg bg-gray-100" />
                        )}
                        <span className="font-medium text-gray-900">{c.name}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 font-mono text-xs text-gray-500">{c.slug}</td>
                    <td className="px-6 py-4 text-gray-600">{c.sortOrder}</td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2 justify-end">
                        <button onClick={() => openEdit(c.id)} className="p-1.5 hover:bg-gray-100 rounded-lg text-gray-500">
                          <Pencil size={15} />
                        </button>
                        <button onClick={() => handleDelete(c.id, c.name)}
                          disabled={deleteMutation.isPending}
                          className="p-1.5 hover:bg-red-50 rounded-lg text-gray-500 hover:text-red-600 disabled:opacity-50">
                          <Trash2 size={15} />
                        </button>
                      </div>
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
