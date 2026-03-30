import { Router } from 'express';
import { requestQuote, getUserQuotes } from '../controllers';
import { authMiddleware } from '../middleware/auth.middleware';
const router = Router();
router.post('/request', requestQuote);
router.get('/my', authMiddleware, getUserQuotes);
export default router;
