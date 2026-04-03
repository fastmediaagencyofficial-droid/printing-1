import fs from 'fs';
import path from 'path';
import { logger } from '../utils/logger';

const UPLOADS_DIR = path.join(process.cwd(), 'uploads');

// Ensure uploads directory exists
if (!fs.existsSync(UPLOADS_DIR)) {
  fs.mkdirSync(UPLOADS_DIR, { recursive: true });
}

/**
 * Save an image locally. Accepts base64 string or Buffer.
 * Returns the URL path to access the image.
 */
export const uploadImage = async (
  data: string | Buffer,
  folder = 'misc'
): Promise<string> => {
  try {
    const folderPath = path.join(UPLOADS_DIR, folder);
    if (!fs.existsSync(folderPath)) {
      fs.mkdirSync(folderPath, { recursive: true });
    }

    const filename = `${Date.now()}-${Math.random().toString(36).slice(2)}.jpg`;
    const filePath = path.join(folderPath, filename);

    if (Buffer.isBuffer(data)) {
      fs.writeFileSync(filePath, data);
    } else {
      // Strip base64 data URI prefix if present
      const base64Data = data.replace(/^data:image\/\w+;base64,/, '');
      fs.writeFileSync(filePath, Buffer.from(base64Data, 'base64'));
    }

    const relativePath = path.join('uploads', folder, filename).replace(/\\/g, '/');
    return `http://localhost:${process.env.PORT || 5000}/${relativePath}`;
  } catch (err) {
    logger.error('Local image upload failed:', err);
    throw new Error('Image upload failed');
  }
};

export default { uploadImage };
