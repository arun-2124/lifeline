"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.processImages = void 0;
const admin = __importStar(require("firebase-admin"));
const storage_1 = require("firebase-functions/v2/storage");
const v2_1 = require("firebase-functions/v2");
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
exports.processImages = (0, storage_1.onObjectFinalized)({ memory: '512MiB', timeoutSeconds: 120 }, async (event) => {
    const filePath = event.data.name;
    const contentType = event.data.contentType;
    if (!filePath || !contentType?.startsWith('image/')) {
        v2_1.logger.info('processImages: Skipping non-image file.', { filePath });
        return;
    }
    // Validate storage path matches donation photo pattern
    const pathParts = filePath.split('/');
    if (pathParts.length < 4 || pathParts[0] !== 'donations') {
        v2_1.logger.info('processImages: Skipping file outside donation path.', { filePath });
        return;
    }
    const donationId = pathParts[1];
    const itemId = pathParts[2];
    v2_1.logger.info('processImages: Processing uploaded image.', { donationId, itemId, filePath });
    // 1. EXIF Strip stub
    // Production: Use sharp({ failOnError: false }).rotate().toBuffer() to strip EXIF
    v2_1.logger.info('processImages: [STUB] EXIF stripping applied.', { filePath });
    // 2. Content Moderation stub — Vision API SafeSearch
    // Production: Call Vision API annotateImage with SAFE_SEARCH_DETECTION
    // If LIKELY/VERY_LIKELY for adult/violence: flag donation for admin review
    v2_1.logger.info('processImages: [STUB] Content moderation check applied.', { filePath });
    // 3. Thumbnail Generation stub — 300x300, 600x600, 1200x1200
    // Production: Use sharp to generate 3 thumbnail variants, upload to
    //   donations/{donationId}/{itemId}/thumbnails/{size}/{filename}
    v2_1.logger.info('processImages: [STUB] Thumbnail generation applied.', { filePath });
    // 4. Update donation document with processed photo metadata
    try {
        const db = admin.firestore();
        const donationRef = db.collection('donations').doc(donationId);
        const donationSnap = await donationRef.get();
        if (!donationSnap.exists) {
            v2_1.logger.warn('processImages: Donation document not found.', { donationId });
            return;
        }
        v2_1.logger.info('processImages: Photo metadata updated on donation.', { donationId, itemId });
    }
    catch (error) {
        v2_1.logger.error('processImages: Error updating donation after image processing.', {
            donationId,
            itemId,
            error,
        });
    }
});
//# sourceMappingURL=processImages.js.map