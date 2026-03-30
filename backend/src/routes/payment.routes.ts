import { Router } from 'express';
import { getPaymentMethods } from '../controllers';
const router = Router();
router.get('/methods', getPaymentMethods);
export default router;
