import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { prisma } from '../config/database';
import { verifyGoogleToken } from '../config/google-auth';
import { uploadImage } from '../config/cloudinary';
import { signToken } from '../utils/jwt';
import { AuthRequest } from '../middleware/auth.middleware';
import {
  sendSuccess, sendCreated, sendError,
  sendNotFound, sendBadRequest,
} from '../utils/response';
import {
  sendEmail,
  orderConfirmationHtml, paymentVerifiedHtml,
  quoteReceivedHtml, contactAutoReplyHtml, adminNewOrderHtml,
} from '../config/email';
import { logger } from '../utils/logger';

// ════════════════════════════════════════════════════════════════════
//  AUTH
// ════════════════════════════════════════════════════════════════════

/** POST /auth/google-login
 *  Body: { idToken: string }
 *  Verifies Google ID token, upserts user, returns our JWT.
 */
export const googleLogin = async (req: Request, res: Response): Promise<void> => {
  try {
    const { idToken } = req.body;
    if (!idToken) { sendBadRequest(res, 'idToken is required'); return; }

    const google = await verifyGoogleToken(idToken);

    // Upsert user — check by googleId first, fall back to email (preserves pre-seeded ADMIN role)
    let user = await prisma.user.findUnique({ where: { googleId: google.googleId } });
    if (!user) {
      const byEmail = await prisma.user.findUnique({ where: { email: google.email } });
      if (byEmail) {
        // Link Google account to pre-seeded user, preserve existing role
        user = await prisma.user.update({
          where: { email: google.email },
          data: { googleId: google.googleId, displayName: google.displayName, photoUrl: google.photoUrl },
        });
      } else {
        user = await prisma.user.create({
          data: {
            googleId: google.googleId,
            email: google.email,
            displayName: google.displayName,
            photoUrl: google.photoUrl,
            role: 'CUSTOMER',
          },
        });
      }
    } else {
      user = await prisma.user.update({
        where: { googleId: google.googleId },
        data: { displayName: google.displayName, photoUrl: google.photoUrl, email: google.email },
      });
    }

    const token = signToken({ userId: user.id, email: user.email, role: user.role });

    sendSuccess(res, {
      token,
      user: {
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        role: user.role,
      },
    }, 'Login successful');
  } catch (err: any) {
    logger.error('googleLogin error:', err);
    sendError(res, 401, err.message || 'Google authentication failed', 'AUTH_FAILED');
  }
};

/** GET /auth/me */
export const getMe = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const user = await prisma.user.findUnique({ where: { id: req.user!.userId } });
    if (!user) { sendNotFound(res, 'User not found'); return; }
    sendSuccess(res, user);
  } catch (err) {
    sendError(res, 500, 'Failed to fetch user');
  }
};

/** PUT /auth/profile */
export const updateProfile = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { phone, street, city, province, postalCode } = req.body;
    const user = await prisma.user.update({
      where: { id: req.user!.userId },
      data: { phone, street, city, province, postalCode },
    });
    sendSuccess(res, user, 'Profile updated');
  } catch (err) {
    sendError(res, 500, 'Failed to update profile');
  }
};

// ════════════════════════════════════════════════════════════════════
//  PRODUCTS
// ════════════════════════════════════════════════════════════════════

export const getAllProducts = async (req: Request, res: Response): Promise<void> => {
  try {
    const { page = '1', limit = '20', category, search, featured } = req.query;
    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

    const where: any = { isActive: true };
    if (category) where.category = category as string;
    if (featured === 'true') where.isFeatured = true;
    if (search) where.name = { contains: search as string, mode: 'insensitive' };

    const [products, total] = await prisma.$transaction([
      prisma.product.findMany({
        where,
        include: { specs: true },
        orderBy: [{ sortOrder: 'asc' }, { createdAt: 'desc' }],
        skip,
        take: parseInt(limit as string),
      }),
      prisma.product.count({ where }),
    ]);

    sendSuccess(res, products, 'Products fetched', 200, {
      page: parseInt(page as string),
      limit: parseInt(limit as string),
      total,
      pages: Math.ceil(total / parseInt(limit as string)),
    });
  } catch (err) {
    logger.error('getAllProducts:', err);
    sendError(res, 500, 'Failed to fetch products');
  }
};

export const getProductById = async (req: Request, res: Response): Promise<void> => {
  try {
    const product = await prisma.product.findFirst({
      where: { OR: [{ id: req.params.id }, { slug: req.params.id }], isActive: true },
      include: { specs: true },
    });
    if (!product) { sendNotFound(res, 'Product not found'); return; }
    sendSuccess(res, product);
  } catch (err) {
    sendError(res, 500, 'Failed to fetch product');
  }
};

export const getProductCategories = async (_req: Request, res: Response): Promise<void> => {
  try {
    const cats = await prisma.product.findMany({
      where: { isActive: true },
      select: { category: true },
      distinct: ['category'],
    });
    sendSuccess(res, cats.map(c => c.category));
  } catch (err) {
    sendError(res, 500, 'Failed to fetch categories');
  }
};

// ════════════════════════════════════════════════════════════════════
//  SERVICES
// ════════════════════════════════════════════════════════════════════

export const getAllServices = async (_req: Request, res: Response): Promise<void> => {
  try {
    const services = await prisma.service.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
    });
    sendSuccess(res, services);
  } catch (err) {
    sendError(res, 500, 'Failed to fetch services');
  }
};

export const getServiceBySlug = async (req: Request, res: Response): Promise<void> => {
  try {
    const service = await prisma.service.findFirst({
      where: { slug: req.params.slug, isActive: true },
    });
    if (!service) { sendNotFound(res, 'Service not found'); return; }
    sendSuccess(res, service);
  } catch (err) {
    sendError(res, 500, 'Failed to fetch service');
  }
};

// ════════════════════════════════════════════════════════════════════
//  CART
// ════════════════════════════════════════════════════════════════════

export const getCart = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const items = await prisma.cartItem.findMany({
      where: { userId: req.user!.userId },
      include: { product: { select: { id: true, name: true, images: true } } },
      orderBy: { createdAt: 'asc' },
    });
    sendSuccess(res, { items, total: items.reduce((s, i) => s + i.totalPrice, 0) });
  } catch (err) {
    sendError(res, 500, 'Failed to fetch cart');
  }
};

export const addToCart = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { productId, productName, quantity, unitPrice, customSpecs, note } = req.body;
    if (!productId || !quantity || !unitPrice) {
      sendBadRequest(res, 'productId, quantity and unitPrice are required'); return;
    }

    // Check if same product+specs already in cart → update qty instead
    const existing = await prisma.cartItem.findFirst({
      where: { userId: req.user!.userId, productId },
    });

    let item;
    if (existing) {
      const newQty = existing.quantity + quantity;
      item = await prisma.cartItem.update({
        where: { id: existing.id },
        data: { quantity: newQty, totalPrice: unitPrice * newQty, customSpecs, note },
      });
    } else {
      item = await prisma.cartItem.create({
        data: {
          userId: req.user!.userId,
          productId,
          productName,
          quantity,
          unitPrice,
          totalPrice: unitPrice * quantity,
          customSpecs,
          note,
        },
      });
    }

    sendSuccess(res, item, 'Item added to cart');
  } catch (err) {
    logger.error('addToCart:', err);
    sendError(res, 500, 'Failed to add to cart');
  }
};

export const updateCartItem = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { quantity } = req.body;
    const item = await prisma.cartItem.findFirst({
      where: { id: req.params.itemId, userId: req.user!.userId },
    });
    if (!item) { sendNotFound(res, 'Cart item not found'); return; }

    const updated = await prisma.cartItem.update({
      where: { id: item.id },
      data: { quantity, totalPrice: item.unitPrice * quantity },
    });
    sendSuccess(res, updated, 'Cart updated');
  } catch (err) {
    sendError(res, 500, 'Failed to update cart');
  }
};

export const removeFromCart = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const item = await prisma.cartItem.findFirst({
      where: { id: req.params.itemId, userId: req.user!.userId },
    });
    if (!item) { sendNotFound(res, 'Cart item not found'); return; }
    await prisma.cartItem.delete({ where: { id: item.id } });
    sendSuccess(res, null, 'Item removed from cart');
  } catch (err) {
    sendError(res, 500, 'Failed to remove from cart');
  }
};

export const clearCart = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    await prisma.cartItem.deleteMany({ where: { userId: req.user!.userId } });
    sendSuccess(res, null, 'Cart cleared');
  } catch (err) {
    sendError(res, 500, 'Failed to clear cart');
  }
};

// ════════════════════════════════════════════════════════════════════
//  WISHLIST
// ════════════════════════════════════════════════════════════════════

export const getWishlist = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const items = await prisma.wishlistItem.findMany({
      where: { userId: req.user!.userId },
      include: { product: { select: { id: true, name: true, images: true, startingPrice: true, category: true } } },
      orderBy: { createdAt: 'desc' },
    });
    sendSuccess(res, items);
  } catch (err) {
    sendError(res, 500, 'Failed to fetch wishlist');
  }
};

export const addToWishlist = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { productId } = req.body;
    if (!productId) { sendBadRequest(res, 'productId is required'); return; }

    const item = await prisma.wishlistItem.upsert({
      where: { userId_productId: { userId: req.user!.userId, productId } },
      update: {},
      create: { userId: req.user!.userId, productId },
    });
    sendSuccess(res, item, 'Added to wishlist');
  } catch (err) {
    sendError(res, 500, 'Failed to add to wishlist');
  }
};

export const removeFromWishlist = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    await prisma.wishlistItem.deleteMany({
      where: { userId: req.user!.userId, productId: req.params.productId },
    });
    sendSuccess(res, null, 'Removed from wishlist');
  } catch (err) {
    sendError(res, 500, 'Failed to remove from wishlist');
  }
};

export const moveToCart = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { productId } = req.params;
    const product = await prisma.product.findUnique({ where: { id: productId } });
    if (!product) { sendNotFound(res, 'Product not found'); return; }

    // Add to cart with default qty 1
    await prisma.cartItem.create({
      data: {
        userId: req.user!.userId,
        productId,
        productName: product.name,
        quantity: 1,
        unitPrice: product.startingPrice,
        totalPrice: product.startingPrice,
      },
    });

    // Remove from wishlist
    await prisma.wishlistItem.deleteMany({
      where: { userId: req.user!.userId, productId },
    });

    sendSuccess(res, null, 'Moved to cart');
  } catch (err) {
    sendError(res, 500, 'Failed to move to cart');
  }
};

// ════════════════════════════════════════════════════════════════════
//  ORDERS
// ════════════════════════════════════════════════════════════════════

const makeOrderId = (): string => {
  const d = new Date();
  const pad = (n: number) => String(n).padStart(2, '0');
  const rand = String(Math.floor(Math.random() * 9000) + 1000);
  return `FP-${d.getFullYear()}${pad(d.getMonth()+1)}${pad(d.getDate())}-${rand}`;
};

export const createOrder = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { items, totalAmount, paymentMethod, shippingStreet,
            shippingCity, shippingProvince, shippingPostal, notes } = req.body;

    if (!items?.length || !totalAmount || !paymentMethod) {
      sendBadRequest(res, 'items, totalAmount and paymentMethod are required'); return;
    }

    const user = await prisma.user.findUnique({ where: { id: req.user!.userId } });
    if (!user) { sendNotFound(res, 'User not found'); return; }

    const order = await prisma.order.create({
      data: {
        orderId: makeOrderId(),
        userId: user.id,
        userEmail: user.email,
        userName: user.displayName,
        totalAmount,
        paymentMethod,
        shippingStreet, shippingCity, shippingProvince, shippingPostal,
        notes,
        status: 'PENDING_PAYMENT',
        items: {
          create: items.map((it: any) => ({
            productId: it.productId || null,
            productName: it.productName,
            quantity: it.quantity,
            unitPrice: it.unitPrice,
            totalPrice: it.totalPrice,
            customSpecs: it.customSpecs || undefined,
          })),
        },
      },
      include: { items: true },
    });

    // Clear cart
    await prisma.cartItem.deleteMany({ where: { userId: user.id } });

    // Emails (non-blocking)
    sendEmail({ to: user.email, subject: `Order Confirmed — ${order.orderId}`,
      html: orderConfirmationHtml(order.orderId, user.displayName, totalAmount, paymentMethod) });
    sendEmail({ to: process.env.EMAIL_USER!, subject: `🆕 New Order: ${order.orderId}`,
      html: adminNewOrderHtml(order.orderId, user.displayName, user.email, totalAmount, paymentMethod) });

    sendCreated(res, { orderId: order.orderId, order }, 'Order placed successfully');
  } catch (err) {
    logger.error('createOrder:', err);
    sendError(res, 500, 'Failed to create order');
  }
};

export const getUserOrders = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const orders = await prisma.order.findMany({
      where: { userId: req.user!.userId },
      include: { items: true },
      orderBy: { createdAt: 'desc' },
    });
    sendSuccess(res, orders);
  } catch (err) {
    sendError(res, 500, 'Failed to fetch orders');
  }
};

export const getOrderById = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const order = await prisma.order.findFirst({
      where: { orderId: req.params.id, userId: req.user!.userId },
      include: { items: true },
    });
    if (!order) { sendNotFound(res, 'Order not found'); return; }
    sendSuccess(res, order);
  } catch (err) {
    sendError(res, 500, 'Failed to fetch order');
  }
};

export const uploadPaymentProof = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { orderId, proofBase64, paymentMethod } = req.body;
    if (!orderId || !proofBase64) {
      sendBadRequest(res, 'orderId and proofBase64 are required'); return;
    }

    const order = await prisma.order.findFirst({
      where: { orderId, userId: req.user!.userId },
    });
    if (!order) { sendNotFound(res, 'Order not found'); return; }
    if (order.status !== 'PENDING_PAYMENT') {
      sendBadRequest(res, 'Payment proof already submitted for this order'); return;
    }

    // Upload screenshot to Cloudinary
    const proofUrl = await uploadImage(proofBase64, 'fast-printing/payment-proofs');

    // Update order
    const updated = await prisma.order.update({
      where: { id: order.id },
      data: { status: 'PAYMENT_UPLOADED', paymentProofUrl: proofUrl },
    });

    // Save proof record
    await prisma.paymentProof.create({
      data: {
        orderId,
        userId: req.user!.userId,
        method: paymentMethod || order.paymentMethod,
        amount: order.totalAmount,
        proofUrl,
        status: 'PENDING',
      },
    });

    // Notify admin
    sendEmail({
      to: process.env.EMAIL_USER!,
      subject: `💳 Payment Proof Uploaded — ${orderId}`,
      html: `<p>Customer uploaded payment proof for <b>${orderId}</b>. Please verify: <a href="${proofUrl}">View Screenshot</a></p>`,
    });

    sendSuccess(res, updated, 'Payment proof submitted. We will verify within 1–2 hours.');
  } catch (err) {
    logger.error('uploadPaymentProof:', err);
    sendError(res, 500, 'Failed to upload payment proof');
  }
};

export const cancelOrder = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const order = await prisma.order.findFirst({
      where: { orderId: req.params.id, userId: req.user!.userId },
    });
    if (!order) { sendNotFound(res, 'Order not found'); return; }
    if (['IN_PRODUCTION', 'SHIPPED', 'DELIVERED'].includes(order.status)) {
      sendBadRequest(res, 'Cannot cancel order already in production or delivered'); return;
    }
    const updated = await prisma.order.update({
      where: { id: order.id },
      data: { status: 'CANCELLED' },
    });
    sendSuccess(res, updated, 'Order cancelled');
  } catch (err) {
    sendError(res, 500, 'Failed to cancel order');
  }
};

// ════════════════════════════════════════════════════════════════════
//  PAYMENT
// ════════════════════════════════════════════════════════════════════

export const getPaymentMethods = (_req: Request, res: Response): void => {
  sendSuccess(res, {
    methods: [
      {
        id: 'JAZZCASH',
        name: 'JazzCash',
        accountNumber: process.env.JAZZCASH_NUMBER || '0325-2467463',
        accountName: process.env.PAYMENT_ACCOUNT_NAME || 'XFast Group',
        logo: 'jazzcash',
        instructions: [
          'Open your JazzCash app',
          'Tap Send Money → Mobile Account',
          `Enter number: ${process.env.JAZZCASH_NUMBER || '0325-2467463'}`,
          'Enter the exact order amount shown',
          'Add your Order ID in the description/note field',
          'Complete payment and take a screenshot',
          'Upload the screenshot in the app',
        ],
      },
      {
        id: 'EASYPAISA',
        name: 'EasyPaisa',
        accountNumber: process.env.EASYPAISA_NUMBER || '0321-0846667',
        accountName: process.env.PAYMENT_ACCOUNT_NAME || 'XFast Group',
        logo: 'easypaisa',
        instructions: [
          'Open your EasyPaisa app',
          'Tap Send Money → EasyPaisa Account',
          `Enter number: ${process.env.EASYPAISA_NUMBER || '0321-0846667'}`,
          'Enter the exact order amount shown',
          'Add your Order ID in the description/note field',
          'Complete payment and take a screenshot',
          'Upload the screenshot in the app',
        ],
      },
    ],
  });
};

// ════════════════════════════════════════════════════════════════════
//  QUOTES
// ════════════════════════════════════════════════════════════════════

export const requestQuote = async (req: Request, res: Response): Promise<void> => {
  try {
    const { name, email, phone, product, quantity,
            size, material, specialRequirements, deliveryLocation, deadline } = req.body;

    if (!name || !email || !phone || !product || !quantity) {
      sendBadRequest(res, 'name, email, phone, product and quantity are required'); return;
    }

    const quote = await prisma.quote.create({
      data: {
        quoteId: `QT-${Date.now()}`,
        name, email, phone, product,
        quantity: parseInt(quantity),
        size, material, specialRequirements, deliveryLocation, deadline,
        status: 'PENDING',
      },
    });

    // Emails
    sendEmail({ to: process.env.EMAIL_USER!,
      subject: `📋 New Quote: ${product} from ${name}`,
      html: `<h2>New Quote Request</h2><p><b>From:</b> ${name} (${email}, ${phone})</p><p><b>Product:</b> ${product}</p><p><b>Quantity:</b> ${quantity}</p><p><b>Notes:</b> ${specialRequirements || 'None'}</p><p><b>Quote ID:</b> ${quote.quoteId}</p>`,
    });
    sendEmail({ to: email, subject: 'Quote Request Received — Fast Printing',
      html: quoteReceivedHtml(name, product, quote.quoteId) });

    sendCreated(res, { quoteId: quote.quoteId }, "Quote request submitted. We'll respond within 24 hours.");
  } catch (err) {
    logger.error('requestQuote:', err);
    sendError(res, 500, 'Failed to submit quote request');
  }
};

export const getUserQuotes = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const quotes = await prisma.quote.findMany({
      where: { userId: req.user!.userId },
      orderBy: { createdAt: 'desc' },
    });
    sendSuccess(res, quotes);
  } catch (err) {
    sendError(res, 500, 'Failed to fetch quotes');
  }
};

// ════════════════════════════════════════════════════════════════════
//  CONTACT
// ════════════════════════════════════════════════════════════════════

export const sendContactMessage = async (req: Request, res: Response): Promise<void> => {
  try {
    const { name, email, phone, service, message } = req.body;
    if (!name || !email || !phone || !message) {
      sendBadRequest(res, 'name, email, phone and message are required'); return;
    }

    // Save to DB
    await prisma.contactMessage.create({ data: { name, email, phone, service, message } });

    // Emails
    sendEmail({ to: process.env.EMAIL_USER!,
      subject: `📩 Contact from ${name}`,
      html: `<h2>Contact Form</h2><p><b>Name:</b> ${name}</p><p><b>Email:</b> ${email}</p><p><b>Phone:</b> ${phone}</p><p><b>Service:</b> ${service || 'N/A'}</p><p><b>Message:</b><br>${message}</p>`,
    });
    sendEmail({ to: email, subject: 'Message Received — Fast Printing',
      html: contactAutoReplyHtml(name) });

    sendSuccess(res, null, "Message sent! We'll respond within 24 hours.");
  } catch (err) {
    logger.error('sendContactMessage:', err);
    sendError(res, 500, 'Failed to send message');
  }
};

// ════════════════════════════════════════════════════════════════════
//  INDUSTRIES (static — no DB table needed)
// ════════════════════════════════════════════════════════════════════

export const getAllIndustries = (_req: Request, res: Response): void => {
  sendSuccess(res, [
    {
      slug: 'schools-education',
      name: 'Schools & Education',
      description: 'Notebooks, ID cards, certificates, prospectuses, and educational materials.',
      products: ['Certificates', 'Notepads', 'Brochures', 'Banners', 'Calendars', 'Bill Books'],
    },
    {
      slug: 'healthcare-medical',
      name: 'Healthcare & Medical',
      description: 'Medical brochures, labels, packaging, and compliance materials.',
      products: ['Labels', 'Brochures', 'Packaging', 'Flyers', 'Prescription Pads', 'Posters'],
    },
    {
      slug: 'restaurants-food',
      name: 'Restaurants & Food',
      description: 'Menus, labels, takeout packaging, and food-safe materials.',
      products: ['Food Packaging', 'Tissue Papers', 'Bags', 'Stickers', 'Menus', 'Posters'],
    },
    {
      slug: 'retail-ecommerce',
      name: 'Retail & E-commerce',
      description: 'Product packaging, labels, shipping boxes, and branded materials.',
      products: ['Custom Boxes', 'Labels', 'Shopping Bags', 'Flyers', 'Catalogs', 'Roll-Up Banners'],
    },
  ]);
};

// ════════════════════════════════════════════════════════════════════
//  ADMIN — PRODUCTS
// ════════════════════════════════════════════════════════════════════

export const adminGetProducts = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const page = parseInt(String(req.query.page || '1'));
    const limit = parseInt(String(req.query.limit || '20'));
    const skip = (page - 1) * limit;
    const [products, total] = await Promise.all([
      prisma.product.findMany({ skip, take: limit, include: { specs: true }, orderBy: { sortOrder: 'asc' } }),
      prisma.product.count(),
    ]);
    sendSuccess(res, { products, total, page, limit });
  } catch (err) { logger.error('adminGetProducts:', err); sendError(res, 500, 'Failed to fetch products'); }
};

export const adminCreateProduct = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { name, slug, description, category, startingPrice, priceUnit, isActive, isFeatured, sortOrder, industries } = req.body;
    if (!name || !slug || !description || !category) { sendBadRequest(res, 'name, slug, description, category required'); return; }
    const product = await prisma.product.create({
      data: { name, slug, description, category, startingPrice: parseFloat(startingPrice || '0'),
        priceUnit: priceUnit || 'custom quote', isActive: isActive !== false, isFeatured: isFeatured === true,
        sortOrder: parseInt(sortOrder || '0'), industries: industries || [] },
    });
    sendCreated(res, product, 'Product created');
  } catch (err: any) {
    logger.error('adminCreateProduct:', err);
    if (err.code === 'P2002') { sendBadRequest(res, 'Slug already exists'); return; }
    sendError(res, 500, 'Failed to create product');
  }
};

export const adminUpdateProduct = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { name, slug, description, category, startingPrice, priceUnit, isActive, isFeatured, sortOrder, industries } = req.body;
    const product = await prisma.product.update({
      where: { id },
      data: {
        ...(name && { name }), ...(slug && { slug }), ...(description && { description }),
        ...(category && { category }), ...(startingPrice !== undefined && { startingPrice: parseFloat(startingPrice) }),
        ...(priceUnit && { priceUnit }), ...(isActive !== undefined && { isActive }),
        ...(isFeatured !== undefined && { isFeatured }), ...(sortOrder !== undefined && { sortOrder: parseInt(sortOrder) }),
        ...(industries && { industries }),
      },
    });
    sendSuccess(res, product, 'Product updated');
  } catch (err: any) {
    logger.error('adminUpdateProduct:', err);
    if (err.code === 'P2025') { sendNotFound(res, 'Product not found'); return; }
    sendError(res, 500, 'Failed to update product');
  }
};

export const adminDeleteProduct = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    await prisma.cartItem.deleteMany({ where: { productId: id } });
    await prisma.productSpec.deleteMany({ where: { productId: id } });
    await prisma.product.delete({ where: { id } });
    sendSuccess(res, null, 'Product deleted');
  } catch (err: any) {
    logger.error('adminDeleteProduct:', err);
    if (err.code === 'P2025') { sendNotFound(res, 'Product not found'); return; }
    sendError(res, 500, 'Failed to delete product');
  }
};

export const adminUploadProductImage = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    if (!req.file) { sendBadRequest(res, 'Image file required'); return; }
    const imageUrl = await uploadImage(req.file.buffer, 'fast-printing/products');
    const product = await prisma.product.update({ where: { id }, data: { imageUrl } });
    sendSuccess(res, { imageUrl: product.imageUrl }, 'Image uploaded');
  } catch (err: any) {
    logger.error('adminUploadProductImage:', err);
    if (err.code === 'P2025') { sendNotFound(res, 'Product not found'); return; }
    sendError(res, 500, 'Failed to upload image');
  }
};

// ════════════════════════════════════════════════════════════════════
//  ADMIN — SERVICES
// ════════════════════════════════════════════════════════════════════

export const adminGetServices = async (_req: AuthRequest, res: Response): Promise<void> => {
  try {
    const services = await prisma.service.findMany({ orderBy: { sortOrder: 'asc' } });
    sendSuccess(res, services);
  } catch (err) { sendError(res, 500, 'Failed to fetch services'); }
};

export const adminCreateService = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { name, slug, description, shortDescription, features, isActive, sortOrder } = req.body;
    if (!name || !slug || !description || !shortDescription) { sendBadRequest(res, 'name, slug, description, shortDescription required'); return; }
    const service = await prisma.service.create({
      data: { name, slug, description, shortDescription,
        features: Array.isArray(features) ? features : (features ? features.split('\n').filter(Boolean) : []),
        isActive: isActive !== false, sortOrder: parseInt(sortOrder || '0') },
    });
    sendCreated(res, service, 'Service created');
  } catch (err: any) {
    logger.error('adminCreateService:', err);
    if (err.code === 'P2002') { sendBadRequest(res, 'Slug already exists'); return; }
    sendError(res, 500, 'Failed to create service');
  }
};

export const adminUpdateService = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { name, slug, description, shortDescription, features, isActive, sortOrder } = req.body;
    const service = await prisma.service.update({
      where: { id },
      data: {
        ...(name && { name }), ...(slug && { slug }),
        ...(description && { description }), ...(shortDescription && { shortDescription }),
        ...(features && { features: Array.isArray(features) ? features : features.split('\n').filter(Boolean) }),
        ...(isActive !== undefined && { isActive }), ...(sortOrder !== undefined && { sortOrder: parseInt(sortOrder) }),
      },
    });
    sendSuccess(res, service, 'Service updated');
  } catch (err: any) {
    if (err.code === 'P2025') { sendNotFound(res, 'Service not found'); return; }
    sendError(res, 500, 'Failed to update service');
  }
};

export const adminUploadServiceImage = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    if (!req.file) { sendBadRequest(res, 'Image file required'); return; }
    const imageUrl = await uploadImage(req.file.buffer, 'fast-printing/services');
    const service = await prisma.service.update({ where: { id }, data: { imageUrl } });
    sendSuccess(res, { imageUrl: service.imageUrl }, 'Image uploaded');
  } catch (err: any) {
    if (err.code === 'P2025') { sendNotFound(res, 'Service not found'); return; }
    sendError(res, 500, 'Failed to upload image');
  }
};

// ════════════════════════════════════════════════════════════════════
//  ADMIN — CATEGORIES
// ════════════════════════════════════════════════════════════════════

export const adminGetCategories = async (_req: AuthRequest, res: Response): Promise<void> => {
  try {
    const categories = await prisma.category.findMany({ orderBy: { sortOrder: 'asc' } });
    sendSuccess(res, categories);
  } catch (err) { sendError(res, 500, 'Failed to fetch categories'); }
};

export const adminCreateCategory = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { name, slug, description, sortOrder } = req.body;
    if (!name || !slug) { sendBadRequest(res, 'name and slug required'); return; }
    const category = await prisma.category.create({
      data: { name, slug, description, sortOrder: parseInt(sortOrder || '0') },
    });
    sendCreated(res, category, 'Category created');
  } catch (err: any) {
    if (err.code === 'P2002') { sendBadRequest(res, 'Name or slug already exists'); return; }
    sendError(res, 500, 'Failed to create category');
  }
};

export const adminUpdateCategory = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { name, slug, description, sortOrder } = req.body;
    const category = await prisma.category.update({
      where: { id },
      data: { ...(name && { name }), ...(slug && { slug }), ...(description !== undefined && { description }), ...(sortOrder !== undefined && { sortOrder: parseInt(sortOrder) }) },
    });
    sendSuccess(res, category, 'Category updated');
  } catch (err: any) {
    if (err.code === 'P2025') { sendNotFound(res, 'Category not found'); return; }
    sendError(res, 500, 'Failed to update category');
  }
};

export const adminDeleteCategory = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const cat = await prisma.category.findUnique({ where: { id } });
    if (!cat) { sendNotFound(res, 'Category not found'); return; }
    const products = await prisma.product.count({ where: { category: cat.slug } });
    if (products > 0) { sendBadRequest(res, `Cannot delete: ${products} products reference this category`); return; }
    await prisma.category.delete({ where: { id } });
    sendSuccess(res, null, 'Category deleted');
  } catch (err) { sendError(res, 500, 'Failed to delete category'); }
};

export const adminUploadCategoryImage = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    if (!req.file) { sendBadRequest(res, 'Image file required'); return; }
    const imageUrl = await uploadImage(req.file.buffer, 'fast-printing/categories');
    const category = await prisma.category.update({ where: { id }, data: { imageUrl } });
    sendSuccess(res, { imageUrl: category.imageUrl }, 'Image uploaded');
  } catch (err: any) {
    if (err.code === 'P2025') { sendNotFound(res, 'Category not found'); return; }
    sendError(res, 500, 'Failed to upload image');
  }
};

// ════════════════════════════════════════════════════════════════════
//  ADMIN — INDUSTRIES
// ════════════════════════════════════════════════════════════════════

export const adminGetIndustries = async (_req: AuthRequest, res: Response): Promise<void> => {
  try {
    const industries = await prisma.industry.findMany({ orderBy: { sortOrder: 'asc' } });
    sendSuccess(res, industries);
  } catch (err) { sendError(res, 500, 'Failed to fetch industries'); }
};

export const adminCreateIndustry = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { name, slug, description, sortOrder } = req.body;
    if (!name || !slug) { sendBadRequest(res, 'name and slug required'); return; }
    const industry = await prisma.industry.create({
      data: { name, slug, description, sortOrder: parseInt(sortOrder || '0') },
    });
    sendCreated(res, industry, 'Industry created');
  } catch (err: any) {
    if (err.code === 'P2002') { sendBadRequest(res, 'Name or slug already exists'); return; }
    sendError(res, 500, 'Failed to create industry');
  }
};

export const adminUpdateIndustry = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { name, slug, description, sortOrder } = req.body;
    const industry = await prisma.industry.update({
      where: { id },
      data: { ...(name && { name }), ...(slug && { slug }), ...(description !== undefined && { description }), ...(sortOrder !== undefined && { sortOrder: parseInt(sortOrder) }) },
    });
    sendSuccess(res, industry, 'Industry updated');
  } catch (err: any) {
    if (err.code === 'P2025') { sendNotFound(res, 'Industry not found'); return; }
    sendError(res, 500, 'Failed to update industry');
  }
};

export const adminUploadIndustryImage = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    if (!req.file) { sendBadRequest(res, 'Image file required'); return; }
    const imageUrl = await uploadImage(req.file.buffer, 'fast-printing/industries');
    const industry = await prisma.industry.update({ where: { id }, data: { imageUrl } });
    sendSuccess(res, { imageUrl: industry.imageUrl }, 'Image uploaded');
  } catch (err: any) {
    if (err.code === 'P2025') { sendNotFound(res, 'Industry not found'); return; }
    sendError(res, 500, 'Failed to upload image');
  }
};

// ════════════════════════════════════════════════════════════════════
//  ADMIN — ORDERS
// ════════════════════════════════════════════════════════════════════

export const adminGetOrders = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const page = parseInt(String(req.query.page || '1'));
    const limit = parseInt(String(req.query.limit || '20'));
    const skip = (page - 1) * limit;
    const where: any = {};
    if (req.query.status) where.status = req.query.status;
    if (req.query.search) where.orderId = { contains: String(req.query.search), mode: 'insensitive' };

    const [orders, total] = await Promise.all([
      prisma.order.findMany({
        where, skip, take: limit,
        include: { user: { select: { displayName: true, email: true } }, items: true },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.order.count({ where }),
    ]);
    sendSuccess(res, { orders, total, page, limit });
  } catch (err) { logger.error('adminGetOrders:', err); sendError(res, 500, 'Failed to fetch orders'); }
};

export const adminGetOrder = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const order = await prisma.order.findUnique({
      where: { id: req.params.id },
      include: { user: { select: { displayName: true, email: true, phone: true } }, items: true },
    });
    if (!order) { sendNotFound(res, 'Order not found'); return; }
    sendSuccess(res, order);
  } catch (err) { sendError(res, 500, 'Failed to fetch order'); }
};

export const adminUpdateOrder = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { status, adminNotes } = req.body;
    const order = await prisma.order.update({
      where: { id },
      data: { ...(status && { status }), ...(adminNotes !== undefined && { adminNotes }) },
    });
    sendSuccess(res, order, 'Order updated');
  } catch (err: any) {
    if (err.code === 'P2025') { sendNotFound(res, 'Order not found'); return; }
    sendError(res, 500, 'Failed to update order');
  }
};

export const adminVerifyPayment = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { action, notes } = req.body;
    if (!['VERIFY', 'REJECT'].includes(action)) { sendBadRequest(res, 'action must be VERIFY or REJECT'); return; }

    const isVerify = action === 'VERIFY';
    const order = await prisma.order.update({
      where: { id },
      data: {
        status: isVerify ? 'CONFIRMED' : 'PAYMENT_UPLOADED',
        ...(isVerify && { paymentVerifiedAt: new Date() }),
      },
    });

    // Update PaymentProof record if exists
    await prisma.paymentProof.updateMany({
      where: { orderId: id, status: 'PENDING' },
      data: {
        status: isVerify ? 'VERIFIED' : 'REJECTED',
        ...(isVerify && { verifiedAt: new Date() }),
        ...(notes && { notes }),
      },
    });

    // Send email notification if verified
    if (isVerify && order.userEmail) {
      sendEmail({ to: order.userEmail, subject: '✅ Payment Verified — Fast Printing',
        html: paymentVerifiedHtml(order.userName, order.orderId) });
    }

    sendSuccess(res, order, isVerify ? 'Payment verified' : 'Payment rejected');
  } catch (err: any) {
    logger.error('adminVerifyPayment:', err);
    if (err.code === 'P2025') { sendNotFound(res, 'Order not found'); return; }
    sendError(res, 500, 'Failed to process payment verification');
  }
};

// ════════════════════════════════════════════════════════════════════
//  ADMIN — QUOTES
// ════════════════════════════════════════════════════════════════════

export const adminGetQuotes = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const page = parseInt(String(req.query.page || '1'));
    const limit = parseInt(String(req.query.limit || '20'));
    const skip = (page - 1) * limit;
    const where: any = {};
    if (req.query.status) where.status = req.query.status;

    const [quotes, total] = await Promise.all([
      prisma.quote.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
      prisma.quote.count({ where }),
    ]);
    sendSuccess(res, { quotes, total, page, limit });
  } catch (err) { sendError(res, 500, 'Failed to fetch quotes'); }
};

export const adminUpdateQuote = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { status, adminResponse, estimatedPrice } = req.body;
    const quote = await prisma.quote.update({
      where: { id },
      data: {
        ...(status && { status }), ...(adminResponse !== undefined && { adminResponse }),
        ...(estimatedPrice !== undefined && { estimatedPrice: parseFloat(estimatedPrice) }),
      },
    });
    sendSuccess(res, quote, 'Quote updated');
  } catch (err: any) {
    if (err.code === 'P2025') { sendNotFound(res, 'Quote not found'); return; }
    sendError(res, 500, 'Failed to update quote');
  }
};

// ════════════════════════════════════════════════════════════════════
//  ADMIN — CONTACTS
// ════════════════════════════════════════════════════════════════════

export const adminGetContacts = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const page = parseInt(String(req.query.page || '1'));
    const limit = parseInt(String(req.query.limit || '20'));
    const skip = (page - 1) * limit;
    const where: any = {};
    if (req.query.isRead !== undefined) where.isRead = req.query.isRead === 'true';

    const [contacts, total] = await Promise.all([
      prisma.contactMessage.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
      prisma.contactMessage.count({ where }),
    ]);
    sendSuccess(res, { contacts, total, page, limit });
  } catch (err) { sendError(res, 500, 'Failed to fetch contacts'); }
};

export const adminMarkContactRead = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const contact = await prisma.contactMessage.update({
      where: { id: req.params.id },
      data: { isRead: true },
    });
    sendSuccess(res, contact, 'Marked as read');
  } catch (err: any) {
    if (err.code === 'P2025') { sendNotFound(res, 'Contact message not found'); return; }
    sendError(res, 500, 'Failed to mark as read');
  }
};

// ════════════════════════════════════════════════════════════════════
//  ADMIN — USERS
// ════════════════════════════════════════════════════════════════════

export const adminGetUsers = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const page = parseInt(String(req.query.page || '1'));
    const limit = parseInt(String(req.query.limit || '20'));
    const skip = (page - 1) * limit;
    const where: any = {};
    if (req.query.search) where.email = { contains: String(req.query.search), mode: 'insensitive' };

    const [users, total] = await Promise.all([
      prisma.user.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' },
        select: { id: true, email: true, displayName: true, photoUrl: true, role: true, phone: true, createdAt: true } }),
      prisma.user.count({ where }),
    ]);
    sendSuccess(res, { users, total, page, limit });
  } catch (err) { sendError(res, 500, 'Failed to fetch users'); }
};

export const adminUpdateUserRole = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { role } = req.body;
    if (!['ADMIN', 'CUSTOMER'].includes(role)) { sendBadRequest(res, 'role must be ADMIN or CUSTOMER'); return; }
    if (id === req.user!.userId) { sendBadRequest(res, 'Cannot change your own role'); return; }
    const user = await prisma.user.update({ where: { id }, data: { role } });
    sendSuccess(res, { id: user.id, email: user.email, role: user.role }, 'Role updated');
  } catch (err: any) {
    if (err.code === 'P2025') { sendNotFound(res, 'User not found'); return; }
    sendError(res, 500, 'Failed to update user role');
  }
};

// ════════════════════════════════════════════════════════════════════
//  ADMIN — DASHBOARD
// ════════════════════════════════════════════════════════════════════

export const adminGetDashboard = async (_req: AuthRequest, res: Response): Promise<void> => {
  try {
    const [
      totalOrders, pendingPayment, paymentUploaded, confirmed, inProduction, shipped, delivered, cancelled,
      recentOrders, unreadContacts, pendingQuotes, revenueResult,
    ] = await Promise.all([
      prisma.order.count(),
      prisma.order.count({ where: { status: 'PENDING_PAYMENT' } }),
      prisma.order.count({ where: { status: 'PAYMENT_UPLOADED' } }),
      prisma.order.count({ where: { status: 'CONFIRMED' } }),
      prisma.order.count({ where: { status: 'IN_PRODUCTION' } }),
      prisma.order.count({ where: { status: 'SHIPPED' } }),
      prisma.order.count({ where: { status: 'DELIVERED' } }),
      prisma.order.count({ where: { status: 'CANCELLED' } }),
      prisma.order.findMany({
        take: 5, orderBy: { createdAt: 'desc' },
        select: { id: true, orderId: true, userName: true, status: true, totalAmount: true, createdAt: true, paymentMethod: true },
      }),
      prisma.contactMessage.count({ where: { isRead: false } }),
      prisma.quote.count({ where: { status: 'PENDING' } }),
      prisma.order.aggregate({
        _sum: { totalAmount: true },
        where: { status: { in: ['CONFIRMED', 'IN_PRODUCTION', 'SHIPPED', 'DELIVERED'] } },
      }),
    ]);

    sendSuccess(res, {
      orders: {
        total: totalOrders,
        byStatus: { PENDING_PAYMENT: pendingPayment, PAYMENT_UPLOADED: paymentUploaded,
          CONFIRMED: confirmed, IN_PRODUCTION: inProduction, SHIPPED: shipped,
          DELIVERED: delivered, CANCELLED: cancelled },
      },
      revenue: { totalVerified: revenueResult._sum.totalAmount || 0 },
      recentOrders,
      unreadContacts,
      pendingQuotes,
    });
  } catch (err) { logger.error('adminGetDashboard:', err); sendError(res, 500, 'Failed to fetch dashboard data'); }
};
