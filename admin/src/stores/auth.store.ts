import { create } from 'zustand';

interface AdminUser { id: string; email: string; displayName: string; role: string; }

interface AuthStore {
  token: string | null;
  user: AdminUser | null;
  setAuth: (token: string, user: AdminUser) => void;
  clearAuth: () => void;
  isAdmin: () => boolean;
}

export const useAuthStore = create<AuthStore>((set, get) => ({
  token: localStorage.getItem('admin_token'),
  user: (() => { try { const u = localStorage.getItem('admin_user'); return u ? JSON.parse(u) : null; } catch { return null; } })(),
  setAuth: (token, user) => {
    localStorage.setItem('admin_token', token);
    localStorage.setItem('admin_user', JSON.stringify(user));
    set({ token, user });
  },
  clearAuth: () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
    set({ token: null, user: null });
  },
  isAdmin: () => get().user?.role === 'ADMIN',
}));
