import { v2 as cloudinary } from 'cloudinary';
import fs from 'fs';
import path from 'path';
import { logger } from '../utils/logger';

const useCloudinary = !!(
  process.env.CLOUDINARY_CLOUD_NAME &&
  process.env.CLOUDINARY_CLOUD_NAME !== 'your_cloud' &&
  process.env.CLOUDINARY_API_KEY &&
  process.env.CLOUDINARY_API_SECRET
);

if (useCloudinary) {
  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key:    process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
  });
  logger.info('Image storage: Cloudinary');
} else {
  logger.info('Image storage: local filesystem (dev only)');
}

const UPLOADS_DIR = path.join(process.cwd(), 'uploads');

export const uploadImage = async (
  data: string | Buffer,
  folder = 'misc'
): Promise<string> => {
  // ── Cloudinary (production) ───────────────────────────────────────────────
  if (useCloudinary) {
    try {
      const base64 = Buffer.isBuffer(data)
        ? `data:image/jpeg;base64,${data.toString('base64')}`
        : data.startsWith('data:') ? data : `data:image/jpeg;base64,${data}`;

      const result = await cloudinary.uploader.upload(base64, {
        folder: `fast-printing/${folder}`,
        resource_type: 'image',
      });
      return result.secure_url;
    } catch (err) {
      logger.error('Cloudinary upload failed:', err);
      throw new Error('Image upload failed');
    }
  }

  // ── Local filesystem (development fallback) ───────────────────────────────
  try {
    const folderPath = path.join(UPLOADS_DIR, folder);
    fs.mkdirSync(folderPath, { recursive: true });

    const filename = `${Date.now()}-${Math.random().toString(36).slice(2)}.jpg`;
    const filePath = path.join(folderPath, filename);

    if (Buffer.isBuffer(data)) {
      fs.writeFileSync(filePath, data);
    } else {
      const base64Data = data.replace(/^data:image\/\w+;base64,/, '');
      fs.writeFileSync(filePath, Buffer.from(base64Data, 'base64'));
    }

    const relativePath = `uploads/${folder}/${filename}`;
    const base = process.env.BASE_URL || `http://localhost:${process.env.PORT || 5000}`;
    return `${base}/${relativePath}`;
  } catch (err) {
    logger.error('Local image upload failed:', err);
    throw new Error('Image upload failed');
  }
};

export default { uploadImage };
