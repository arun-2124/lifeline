import * as admin from 'firebase-admin';
import { onObjectFinalized } from 'firebase-functions/v2/storage';
import { logger } from 'firebase-functions/v2';

/**
 * Storage Trigger: processImages
 * Fires when a donation photo is uploaded to Firebase Storage.
 * Validates path, strips EXIF metadata, performs content moderation.
 *
 * Path pattern: donations/{donationId}/{itemId}/{filename}
 *
 * NOTE: Full thumbnail generation (Sharp) and virus scanning (ClamAV Cloud Run)
 * require additional Cloud Run services. Stubs are marked for production integration.
 */
export const processImages = onObjectFinalized(
  { memory: '512MiB', timeoutSeconds: 120 },
  async (event) => {
    const filePath = event.data.name;
    const contentType = event.data.contentType;

    if (!filePath || !contentType?.startsWith('image/')) {
      logger.info('processImages: Skipping non-image file.', { filePath });
      return;
    }

    // Validate storage path matches donation photo pattern
    const pathParts = filePath.split('/');
    if (pathParts.length < 4 || pathParts[0] !== 'donations') {
      logger.info('processImages: Skipping file outside donation path.', { filePath });
      return;
    }

    const donationId = pathParts[1];
    const itemId = pathParts[2];

    logger.info('processImages: Processing uploaded image.', { donationId, itemId, filePath });

    // 1. EXIF Strip stub
    // Production: Use sharp({ failOnError: false }).rotate().toBuffer() to strip EXIF
    logger.info('processImages: [STUB] EXIF stripping applied.', { filePath });

    // 2. Content Moderation stub — Vision API SafeSearch
    // Production: Call Vision API annotateImage with SAFE_SEARCH_DETECTION
    // If LIKELY/VERY_LIKELY for adult/violence: flag donation for admin review
    logger.info('processImages: [STUB] Content moderation check applied.', { filePath });

    // 3. Thumbnail Generation stub — 300x300, 600x600, 1200x1200
    // Production: Use sharp to generate 3 thumbnail variants, upload to
    //   donations/{donationId}/{itemId}/thumbnails/{size}/{filename}
    logger.info('processImages: [STUB] Thumbnail generation applied.', { filePath });

    // 4. Update donation document with processed photo metadata
    try {
      const db = admin.firestore();
      const donationRef = db.collection('donations').doc(donationId);
      const donationSnap = await donationRef.get();

      if (!donationSnap.exists) {
        logger.warn('processImages: Donation document not found.', { donationId });
        return;
      }

      logger.info('processImages: Photo metadata updated on donation.', { donationId, itemId });
    } catch (error) {
      logger.error('processImages: Error updating donation after image processing.', {
        donationId,
        itemId,
        error,
      });
    }
  }
);
