import { Router } from 'express';
import { authMiddleware, adminMiddleware } from '../middleware/auth.middleware';
import { uploadSingle, validateImageUpload } from '../middleware/upload.middleware';
import {
  // Products
  adminGetProducts, adminCreateProduct, adminUpdateProduct, adminDeleteProduct, adminUploadProductImage,
  // Services
  adminGetServices, adminCreateService, adminUpdateService, adminUploadServiceImage,
  // Categories
  adminGetCategories, adminCreateCategory, adminUpdateCategory, adminDeleteCategory, adminUploadCategoryImage,
  // Industries
  adminGetIndustries, adminCreateIndustry, adminUpdateIndustry, adminUploadIndustryImage,
  // Orders
  adminGetOrders, adminGetOrder, adminUpdateOrder, adminVerifyPayment,
  // Quotes
  adminGetQuotes, adminUpdateQuote,
  // Contacts
  adminGetContacts, adminMarkContactRead,
  // Users
  adminGetUsers, adminUpdateUserRole,
  // Dashboard
  adminGetDashboard,
} from '../controllers/index';

const router = Router();

// All admin routes require authentication + ADMIN role
router.use(authMiddleware, adminMiddleware);

// ── Dashboard ────────────────────────────────────────────────────────
router.get('/dashboard', adminGetDashboard);

// ── Products ─────────────────────────────────────────────────────────
router.get('/products',          adminGetProducts);
router.post('/products',         adminCreateProduct);
router.put('/products/:id',      adminUpdateProduct);
router.delete('/products/:id',   adminDeleteProduct);
router.post('/products/:id/image', uploadSingle, validateImageUpload, adminUploadProductImage);

// ── Services ─────────────────────────────────────────────────────────
router.get('/services',          adminGetServices);
router.post('/services',         adminCreateService);
router.put('/services/:id',      adminUpdateService);
router.post('/services/:id/image', uploadSingle, validateImageUpload, adminUploadServiceImage);

// ── Categories ───────────────────────────────────────────────────────
router.get('/categories',          adminGetCategories);
router.post('/categories',         adminCreateCategory);
router.put('/categories/:id',      adminUpdateCategory);
router.delete('/categories/:id',   adminDeleteCategory);
router.post('/categories/:id/image', uploadSingle, validateImageUpload, adminUploadCategoryImage);

// ── Industries ───────────────────────────────────────────────────────
router.get('/industries',          adminGetIndustries);
router.post('/industries',         adminCreateIndustry);
router.put('/industries/:id',      adminUpdateIndustry);
router.post('/industries/:id/image', uploadSingle, validateImageUpload, adminUploadIndustryImage);

// ── Orders ───────────────────────────────────────────────────────────
router.get('/orders',             adminGetOrders);
router.get('/orders/:id',         adminGetOrder);
router.put('/orders/:id',         adminUpdateOrder);
router.put('/orders/:id/verify-payment', adminVerifyPayment);

// ── Quotes ───────────────────────────────────────────────────────────
router.get('/quotes',             adminGetQuotes);
router.put('/quotes/:id',         adminUpdateQuote);

// ── Contacts ─────────────────────────────────────────────────────────
router.get('/contacts',           adminGetContacts);
router.put('/contacts/:id/read',  adminMarkContactRead);

// ── Users ────────────────────────────────────────────────────────────
router.get('/users',              adminGetUsers);
router.put('/users/:id/role',     adminUpdateUserRole);

export default router;
