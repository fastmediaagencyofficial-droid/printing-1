import multer, { FileFilterCallback } from 'multer';
import { Request, Response, NextFunction } from 'express';
import { sendBadRequest } from '../utils/response';

const ALLOWED_MIME = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
const MAX_SIZE = 5 * 1024 * 1024; // 5 MB

const storage = multer.memoryStorage();

const fileFilter = (_req: Request, file: Express.Multer.File, cb: FileFilterCallback) => {
  if (ALLOWED_MIME.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Only JPEG, PNG, and WEBP images are allowed'));
  }
};

const upload = multer({ storage, fileFilter, limits: { fileSize: MAX_SIZE } });

export const uploadSingle = upload.single('image');

/** Middleware: validates that req.file exists after uploadSingle. */
export const validateImageUpload = (req: Request, res: Response, next: NextFunction): void => {
  if (!req.file) {
    sendBadRequest(res, 'Image file is required (field name: image)');
    return;
  }
  next();
};
