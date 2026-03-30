import 'dotenv/config';
import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import { connectDatabase, disconnectDatabase } from './config/database';
import { logger } from './utils/logger';
import { errorMiddleware } from './middleware/error.middleware';
import { rateLimitMiddleware } from './middleware/rateLimit.middleware';

import authRoutes     from './routes/auth.routes';
import productRoutes  from './routes/product.routes';
import serviceRoutes  from './routes/service.routes';
import cartRoutes     from './routes/cart.routes';
import wishlistRoutes from './routes/wishlist.routes';
import orderRoutes    from './routes/order.routes';
import paymentRoutes  from './routes/payment.routes';
import quoteRoutes    from './routes/quote.routes';
import contactRoutes  from './routes/contact.routes';
import industryRoutes from './routes/industry.routes';
import adminRoutes    from './routes/admin.routes';

const app: Application = express();
const PORT = Number(process.env.PORT) || 5000;
const API = '/api/v1';

// ── Security ─────────────────────────────────────────────────────────────────
app.use(helmet());
app.use(cors({
  origin: (process.env.ALLOWED_ORIGINS || '*').split(','),
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// ── Core middleware ───────────────────────────────────────────────────────────
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(morgan('dev', { stream: { write: (m) => logger.info(m.trim()) } }));
app.use(`${API}/`, rateLimitMiddleware);

// ── Health ────────────────────────────────────────────────────────────────────
app.get('/health', (_req: Request, res: Response) => {
  res.json({
    status: 'ok',
    message: 'Fast Printing API is running',
    version: '2.0.0',
    stack: 'PostgreSQL + Prisma + JWT (no Firebase)',
    timestamp: new Date().toISOString(),
  });
});

// ── Routes ────────────────────────────────────────────────────────────────────
app.use(`${API}/auth`,      authRoutes);
app.use(`${API}/products`,  productRoutes);
app.use(`${API}/services`,  serviceRoutes);
app.use(`${API}/cart`,      cartRoutes);
app.use(`${API}/wishlist`,  wishlistRoutes);
app.use(`${API}/orders`,    orderRoutes);
app.use(`${API}/payment`,   paymentRoutes);
app.use(`${API}/quotes`,    quoteRoutes);
app.use(`${API}/contact`,   contactRoutes);
app.use(`${API}/industries`,industryRoutes);
app.use(`${API}/admin`,     adminRoutes);

// ── 404 ───────────────────────────────────────────────────────────────────────
app.use('*', (req: Request, res: Response) => {
  res.status(404).json({ success: false, message: `Route ${req.originalUrl} not found`, code: 'NOT_FOUND' });
});

// ── Global errors ─────────────────────────────────────────────────────────────
app.use(errorMiddleware);

// ── Start ─────────────────────────────────────────────────────────────────────
const start = async () => {
  try {
    await connectDatabase();
    const server = app.listen(PORT, () => {
      logger.info(`🚀  Fast Printing API  →  http://localhost:${PORT}`);
      logger.info(`📡  API prefix: ${API}`);
      logger.info(`💾  DB: PostgreSQL (Prisma)`);
      logger.info(`🔐  Auth: Google OAuth 2.0 + JWT`);
    });

    // Graceful shutdown
    const shutdown = async () => {
      logger.info('Shutting down...');
      server.close(async () => {
        await disconnectDatabase();
        process.exit(0);
      });
    };
    process.on('SIGTERM', shutdown);
    process.on('SIGINT', shutdown);
  } catch (err) {
    logger.error('Failed to start server:', err);
    process.exit(1);
  }
};

start();
export default app;
