import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { useAuthStore } from '../stores/auth.store';
import { LayoutDashboard, Package, Scissors, Tag, Globe, ShoppingCart, MessageSquare, Mail, Users, LogOut, Menu, X, ChevronLeft, ChevronRight } from 'lucide-react';
import { useState, useEffect } from 'react';

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
  const [mobileOpen, setMobileOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);

  // Close mobile sidebar on route change
  useEffect(() => { setMobileOpen(false); }, [navigate]);

  const handleSignOut = () => { clearAuth(); navigate('/login'); };

  return (
    <div className="flex h-screen bg-gray-50 overflow-hidden">

      {/* Mobile backdrop */}
      {mobileOpen && (
        <div
          className="fixed inset-0 bg-black/40 z-20 md:hidden"
          onClick={() => setMobileOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside className={[
        'fixed md:static inset-y-0 left-0 z-30 bg-white border-r border-gray-200 flex flex-col transition-all duration-200',
        // Mobile: full width drawer, hidden off-screen when closed
        mobileOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0',
        // Desktop: collapsible width
        collapsed ? 'md:w-16' : 'md:w-64',
        // Always 260px wide on mobile
        'w-64',
      ].join(' ')}>

        {/* Sidebar header */}
        <div className="flex items-center justify-between px-4 py-3 border-b border-gray-200 min-h-[57px]">
          {!collapsed && (
            <span className="font-bold text-primary text-sm leading-tight">
              Fast Printing<br />
              <span className="font-normal text-gray-400 text-xs">Admin Panel</span>
            </span>
          )}
          {/* Desktop collapse toggle */}
          <button
            onClick={() => setCollapsed(!collapsed)}
            className="hidden md:flex p-1.5 rounded-lg hover:bg-gray-100 text-gray-500 ml-auto"
            title={collapsed ? 'Expand' : 'Collapse'}
          >
            {collapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
          </button>
          {/* Mobile close */}
          <button
            onClick={() => setMobileOpen(false)}
            className="md:hidden p-1.5 rounded-lg hover:bg-gray-100 text-gray-500 ml-auto"
          >
            <X size={18} />
          </button>
        </div>

        {/* Nav links */}
        <nav className="flex-1 py-3 overflow-y-auto">
          {nav.map(({ to, label, icon: Icon }) => (
            <NavLink
              key={to}
              to={to}
              onClick={() => setMobileOpen(false)}
              className={({ isActive }) =>
                `flex items-center gap-3 px-4 py-2.5 text-sm transition-colors ${
                  isActive
                    ? 'bg-red-50 text-primary font-semibold border-r-2 border-primary'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                }`
              }
              title={collapsed ? label : undefined}
            >
              <Icon size={18} className="shrink-0" />
              {(!collapsed) && <span>{label}</span>}
            </NavLink>
          ))}
        </nav>

        {/* User / sign out */}
        <div className="p-4 border-t border-gray-200">
          {!collapsed && (
            <p className="text-xs text-gray-400 truncate mb-2">{user?.email}</p>
          )}
          <button
            onClick={handleSignOut}
            className="flex items-center gap-2 text-sm text-gray-600 hover:text-red-600 transition-colors w-full"
            title={collapsed ? 'Sign Out' : undefined}
          >
            <LogOut size={16} className="shrink-0" />
            {!collapsed && 'Sign Out'}
          </button>
        </div>
      </aside>

      {/* Right side */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">

        {/* Mobile top bar */}
        <header className="md:hidden flex items-center gap-3 px-4 py-3 bg-white border-b border-gray-200 shrink-0">
          <button
            onClick={() => setMobileOpen(true)}
            className="p-1.5 rounded-lg hover:bg-gray-100 text-gray-600"
          >
            <Menu size={20} />
          </button>
          <span className="font-bold text-primary text-sm">Fast Printing Admin</span>
        </header>

        <main className="flex-1 overflow-y-auto">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
