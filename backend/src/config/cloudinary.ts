import { v2 as cloudinary } from 'cloudinary';
import { logger } from '../utils/logger';

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

/**
 * Upload an image to Cloudinary. Accepts base64 string or Buffer.
 * Returns the secure URL.
 */
export const uploadImage = async (
  data: string | Buffer,
  folder = 'fast-printing/payment-proofs'
): Promise<string> => {
  try {
    if (Buffer.isBuffer(data)) {
      // Stream upload for Buffer (from multer memoryStorage)
      return await new Promise<string>((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
          {
            folder,
            allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
            transformation: [{ quality: 'auto', fetch_format: 'auto' }],
          },
          (error, result) => {
            if (error || !result) { reject(error || new Error('Upload failed')); return; }
            resolve(result.secure_url);
          }
        );
        stream.end(data);
      });
    }

    // Base64 string upload
    const result = await cloudinary.uploader.upload(data, {
      folder,
      allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
      max_bytes: 5 * 1024 * 1024,
      transformation: [{ quality: 'auto', fetch_format: 'auto' }],
    });
    return result.secure_url;
  } catch (err) {
    logger.error('Cloudinary upload failed:', err);
    throw new Error('Image upload failed');
  }
};

export default cloudinary;
