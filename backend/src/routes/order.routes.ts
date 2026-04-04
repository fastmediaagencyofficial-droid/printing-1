import { Router } from 'express';
import { createOrder, guestCreateOrder, trackOrdersByPhone, getUserOrders, getOrderById, uploadPaymentProof, cancelOrder } from '../controllers';
import { authMiddleware } from '../middleware/auth.middleware';
const router = Router();
router.post('/guest', guestCreateOrder);          // no auth — guest checkout
router.get('/track', trackOrdersByPhone);          // no auth — track by phone number
router.use(authMiddleware);
router.get('/', getUserOrders);
router.post('/', createOrder);
router.get('/:id', getOrderById);
router.post('/:id/payment-proof', uploadPaymentProof);
router.put('/:id/cancel', cancelOrder);
export default router;
