import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../stores/auth.store';
import { api } from '../services/api';

export default function LoginPage() {
  const [idToken, setIdToken] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { setAuth } = useAuthStore();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!idToken.trim()) { setError('Please enter your Google ID Token'); return; }
    setLoading(true); setError('');
    try {
      const res = await api.post('/auth/google-login', { idToken: idToken.trim() });
      const { token, user } = res.data.data;
      if (user.role !== 'ADMIN') { setError('Access denied. Admin role required.'); setLoading(false); return; }
      setAuth(token, user);
      navigate('/dashboard');
    } catch (err: any) {
      setError(err.response?.data?.error || 'Authentication failed');
    } finally { setLoading(false); }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-lg p-8 w-full max-w-md">
        <div className="text-center mb-8">
          <div className="w-16 h-16 bg-primary-surface rounded-2xl flex items-center justify-center mx-auto mb-4">
            <span className="text-3xl">🖨️</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Fast Printing Admin</h1>
          <p className="text-gray-500 text-sm mt-1">XFast Group — Internal Dashboard</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Google ID Token</label>
            <textarea value={idToken} onChange={(e) => setIdToken(e.target.value)}
              rows={4} placeholder="Paste your Google OAuth idToken here…"
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary resize-none" />
            <p className="text-xs text-gray-500 mt-1">
              Get your token from: Google OAuth2 Playground or the Flutter app (developer mode).
              The token must be from an account with Admin role.
            </p>
          </div>

          {error && <div className="bg-red-50 border border-red-200 rounded-lg px-3 py-2 text-sm text-red-700">{error}</div>}

          <button type="submit" disabled={loading}
            className="w-full bg-primary hover:bg-primary-dark text-white font-semibold py-3 rounded-xl transition-colors disabled:opacity-50">
            {loading ? 'Signing in…' : 'Sign In'}
          </button>
        </form>

        <div className="mt-6 p-4 bg-gray-50 rounded-xl">
          <p className="text-xs text-gray-600 font-medium mb-2">First-time setup:</p>
          <ol className="text-xs text-gray-500 space-y-1 list-decimal list-inside">
            <li>Sign in to the Flutter app with your Google account</li>
            <li>In your PostgreSQL DB, run: <code className="bg-gray-200 px-1 rounded">UPDATE users SET role = 'ADMIN' WHERE email = 'your@email.com';</code></li>
            <li>Get a fresh Google idToken and paste it above</li>
          </ol>
        </div>
      </div>
    </div>
  );
}
