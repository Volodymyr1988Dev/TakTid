
import cloudinary from '../config/cloudinary.config';

export async function deleteCloudinaryAsset(
  publicId: string,
): Promise<void> {
  if (!publicId?.trim()) {
    throw new Error('Cloudinary publicId is missing');
  }

  const result = await cloudinary.uploader.destroy(publicId);

  if (
    result.result !== 'ok' &&
    result.result !== 'not found'
  ) {
    throw new Error(
      `Cloudinary deletion failed for ${publicId}: ${result.result}`,
    );
  }
}
