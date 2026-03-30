import { Router } from 'express';
import { getAllIndustries } from '../controllers';
const router = Router();
router.get('/', getAllIndustries);
export default router;
