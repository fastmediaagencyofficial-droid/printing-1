import { useState } from 'react';
import { useUsers, useUpdateUserRole, AdminUser } from '../../hooks/useUsers';

const ROLES = ['CUSTOMER', 'ADMIN'];

export default function UserListPage() {
  const { data: users = [], isLoading } = useUsers();
  const [search, setSearch] = useState('');

  const filtered = users.filter(u =>
    u.name.toLowerCase().includes(search.toLowerCase()) ||
    u.email.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Users</h1>
        <p className="text-sm text-gray-500 mt-1">{users.length} registered users</p>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-100">
        <div className="p-4 border-b border-gray-100">
          <input
            type="text"
            placeholder="Search users…"
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full max-w-sm border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary"
          />
        </div>

        {isLoading ? (
          <div className="p-8 text-center text-gray-400 text-sm">Loading…</div>
        ) : filtered.length === 0 ? (
          <div className="p-8 text-center text-gray-400 text-sm">No users found.</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-xs text-gray-500 border-b border-gray-100">
                  <th className="px-6 py-3 font-medium">User</th>
                  <th className="px-6 py-3 font-medium">Phone</th>
                  <th className="px-6 py-3 font-medium">Orders</th>
                  <th className="px-6 py-3 font-medium">Role</th>
                  <th className="px-6 py-3 font-medium">Joined</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {filtered.map(u => <UserRow key={u.id} user={u} />)}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}

function UserRow({ user }: { user: AdminUser }) {
  const updateRoleMutation = useUpdateUserRole(user.id);
  const [role, setRole] = useState(user.role);

  const handleRoleChange = (newRole: string) => {
    if (newRole === role) return;
    if (!confirm(`Change ${user.name}'s role to ${newRole}?`)) return;
    setRole(newRole);
    updateRoleMutation.mutate(newRole);
  };

  return (
    <tr className="hover:bg-gray-50">
      <td className="px-6 py-4">
        <p className="font-medium text-gray-900">{user.name}</p>
        <p className="text-xs text-gray-500">{user.email}</p>
      </td>
      <td className="px-6 py-4 text-gray-600">{user.phone || '—'}</td>
      <td className="px-6 py-4 text-gray-600">{user._count?.orders ?? 0}</td>
      <td className="px-6 py-4">
        <select value={role} onChange={e => handleRoleChange(e.target.value)}
          disabled={updateRoleMutation.isPending}
          className="border border-gray-300 rounded-lg px-2 py-1 text-xs focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary disabled:opacity-50">
          {ROLES.map(r => <option key={r} value={r}>{r}</option>)}
        </select>
      </td>
      <td className="px-6 py-4 text-gray-500">{new Date(user.createdAt).toLocaleDateString()}</td>
    </tr>
  );
}
