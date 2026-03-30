import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuthStore } from './stores/auth.store';
import Layout from './components/Layout';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import ProductListPage from './pages/products/ProductListPage';
import ProductFormPage from './pages/products/ProductFormPage';
import ServiceListPage from './pages/services/ServiceListPage';
import ServiceFormPage from './pages/services/ServiceFormPage';
import CategoryListPage from './pages/categories/CategoryListPage';
import IndustryListPage from './pages/industries/IndustryListPage';
import OrderListPage from './pages/orders/OrderListPage';
import OrderDetailPage from './pages/orders/OrderDetailPage';
import QuoteListPage from './pages/quotes/QuoteListPage';
import QuoteDetailPage from './pages/quotes/QuoteDetailPage';
import ContactListPage from './pages/contacts/ContactListPage';
import UserListPage from './pages/users/UserListPage';

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { token, isAdmin } = useAuthStore();
  if (!token) return <Navigate to="/login" replace />;
  if (!isAdmin()) return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-2xl font-bold text-red-600 mb-2">Access Denied</h1>
        <p className="text-gray-600">You need Admin role to access this dashboard.</p>
        <button onClick={() => useAuthStore.getState().clearAuth()} className="mt-4 px-4 py-2 bg-primary text-white rounded-lg text-sm">Sign Out</button>
      </div>
    </div>
  );
  return <>{children}</>;
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/" element={<ProtectedRoute><Layout /></ProtectedRoute>}>
        <Route index element={<Navigate to="/dashboard" replace />} />
        <Route path="dashboard" element={<DashboardPage />} />
        <Route path="products" element={<ProductListPage />} />
        <Route path="products/new" element={<ProductFormPage />} />
        <Route path="products/:id/edit" element={<ProductFormPage />} />
        <Route path="services" element={<ServiceListPage />} />
        <Route path="services/:id/edit" element={<ServiceFormPage />} />
        <Route path="categories" element={<CategoryListPage />} />
        <Route path="industries" element={<IndustryListPage />} />
        <Route path="orders" element={<OrderListPage />} />
        <Route path="orders/:id" element={<OrderDetailPage />} />
        <Route path="quotes" element={<QuoteListPage />} />
        <Route path="quotes/:id" element={<QuoteDetailPage />} />
        <Route path="contacts" element={<ContactListPage />} />
        <Route path="users" element={<UserListPage />} />
      </Route>
      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
}
