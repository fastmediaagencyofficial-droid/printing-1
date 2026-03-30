import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { useAuthStore } from '../stores/auth.store';
import { LayoutDashboard, Package, Scissors, Tag, Globe, ShoppingCart, MessageSquare, Mail, Users, LogOut, Menu, X } from 'lucide-react';
import { useState } from 'react';

const nav = [
  { to: '/dashboard',  label: 'Dashboard',  icon: LayoutDashboard },
  { to: '/orders',     label: 'Orders',      icon: ShoppingCart },
  { to: '/products',   label: 'Products',    icon: Package },
  { to: '/services',   label: 'Services',    icon: Scissors },
  { to: '/categories', label: 'Categories',  icon: Tag },
  { to: '/industries', label: 'Industries',  icon: Globe },
  { to: '/quotes',     label: 'Quotes',      icon: MessageSquare },
  { to: '/contacts',   label: 'Contacts',    icon: Mail },
  { to: '/users',      label: 'Users',       icon: Users },
];

export default function Layout() {
  const { user, clearAuth } = useAuthStore();
  const navigate = useNavigate();
  const [open, setOpen] = useState(true);

  const handleSignOut = () => { clearAuth(); navigate('/login'); };

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <aside className={`${open ? 'w-64' : 'w-16'} bg-white border-r border-gray-200 flex flex-col transition-all duration-200`}>
        <div className="flex items-center justify-between p-4 border-b border-gray-200">
          {open && <span className="font-bold text-primary text-sm">Fast Printing Admin</span>}
          <button onClick={() => setOpen(!open)} className="p-1 rounded hover:bg-gray-100">
            {open ? <X size={18} /> : <Menu size={18} />}
          </button>
        </div>
        <nav className="flex-1 py-4 overflow-y-auto">
          {nav.map(({ to, label, icon: Icon }) => (
            <NavLink key={to} to={to}
              className={({ isActive }) =>
                `flex items-center gap-3 px-4 py-2.5 text-sm transition-colors ${isActive
                  ? 'bg-primary-surface text-primary font-semibold border-r-2 border-primary'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'}`
              }>
              <Icon size={18} className="shrink-0" />
              {open && label}
            </NavLink>
          ))}
        </nav>
        <div className="p-4 border-t border-gray-200">
          {open && <p className="text-xs text-gray-500 truncate mb-2">{user?.email}</p>}
          <button onClick={handleSignOut}
            className="flex items-center gap-2 text-sm text-gray-600 hover:text-red-600 w-full">
            <LogOut size={16} />
            {open && 'Sign Out'}
          </button>
        </div>
      </aside>

      {/* Main content */}
      <main className="flex-1 overflow-y-auto">
        <Outlet />
      </main>
    </div>
  );
}
