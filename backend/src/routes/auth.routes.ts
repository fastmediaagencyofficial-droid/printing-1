import { Router } from 'express';
import { googleLogin, getMe, updateProfile } from '../controllers';
import { authMiddleware } from '../middleware/auth.middleware';
import { authRateLimit } from '../middleware/error.middleware';
const router = Router();
router.post('/google-login', authRateLimit, googleLogin);
router.get('/me', authMiddleware, getMe);
router.put('/profile', authMiddleware, updateProfile);
export default router;
