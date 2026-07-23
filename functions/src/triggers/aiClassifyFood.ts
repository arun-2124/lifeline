import * as admin from 'firebase-admin';
import { onMessagePublished } from 'firebase-functions/v2/pubsub';
import { logger } from 'firebase-functions/v2';
import { FoodItemDocument, AiClassificationResult } from '../types/donation.types';

const MAX_RETRIES = 3;
const AI_TIMEOUT_MS = 10_000;

/**
 * Deterministic mock AI classifier for development/emulator environments.
 */
function mockAiClassify(item: FoodItemDocument): AiClassificationResult {
  const MOCK_CATEGORIES: Record<string, AiClassificationResult['category']> = {
    cooked_meal: 'cooked_meal',
    produce: 'produce',
    bakery: 'bakery',
    dairy: 'dairy',
    packaged: 'packaged',
    beverages: 'beverages',
  };
  return {
    status: 'completed',
    category: MOCK_CATEGORIES[item.category] ?? 'cooked_meal',
    confidence: 0.92,
    freshnessScore: 85,
    estimatedServings: Math.ceil(item.quantity * 2),
    detectedAllergens: item.allergens ?? [],
    analyzedAt: new Date().toISOString(),
    modelVersion: 'mock-foodnet-v1.0',
  };
}

/**
 * Classify a single food item with retry + timeout logic.
 * In production: replace mockAiClassify with Vertex AI endpoint call.
 */
async function classifyItemWithRetry(
  item: FoodItemDocument
): Promise<AiClassificationResult> {
  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      // Simulate async AI call with timeout
      const result = await Promise.race<AiClassificationResult>([
        Promise.resolve(mockAiClassify(item)),
        new Promise<AiClassificationResult>((_, reject) =>
          setTimeout(() => reject(new Error('AI timeout')), AI_TIMEOUT_MS)
        ),
      ]);
      return result;
    } catch (err) {
      logger.warn(`aiClassifyFood: Attempt ${attempt}/${MAX_RETRIES} failed for item.`, {
        itemId: item.itemId,
        error: err,
      });

      if (attempt === MAX_RETRIES) {
        return { status: 'failed' };
      }

      // Exponential backoff: 500ms, 1000ms, 2000ms
      await new Promise((res) => setTimeout(res, 500 * Math.pow(2, attempt - 1)));
    }
  }
  return { status: 'failed' };
}

/**
 * PubSub Trigger: aiClassifyFood
 * Listens to 'ai-classify-donation' topic.
 * Classifies all food items in parallel, updates Firestore atomically.
 */
export const aiClassifyFood = onMessagePublished(
  { topic: 'ai-classify-donation', memory: '1GiB', timeoutSeconds: 300 },
  async (event) => {
    const messageData = event.data.message.json as { donationId: string };
    const { donationId } = messageData;

    if (!donationId) {
      logger.error('aiClassifyFood: Missing donationId in PubSub message.');
      return;
    }

    logger.info('aiClassifyFood: Starting classification.', { donationId });

    const db = admin.firestore();
    const donationRef = db.collection('donations').doc(donationId);
    const donationSnap = await donationRef.get();

    if (!donationSnap.exists) {
      logger.error('aiClassifyFood: Donation not found.', { donationId });
      return;
    }

    const donation = donationSnap.data()!;
    const foodItems: FoodItemDocument[] = donation.foodItems ?? [];

    // Classify all items in parallel with individual retry + timeout
    const startTime = Date.now();
    const classifiedItems = await Promise.all(
      foodItems.map(async (item) => {
        const result = await classifyItemWithRetry(item);
        return { ...item, aiClassification: result };
      })
    );
    const classificationLatencyMs = Date.now() - startTime;

    // Recompute aggregates from AI results
    const totalEstimatedServings = classifiedItems.reduce((sum, item) => {
      return sum + (item.aiClassification?.estimatedServings ?? 0);
    }, 0);

    const aiResultsRef = donationRef.collection('aiResults').doc();

    // Atomic update of donation document + aiResults subcollection
    await db.runTransaction(async (transaction) => {
      transaction.update(donationRef, {
        foodItems: classifiedItems,
        totalEstimatedServings,
      });

      transaction.set(aiResultsRef, {
        donationId,
        processingTimeMs: classificationLatencyMs,
        itemResults: classifiedItems.map((item) => ({
          itemId: item.itemId,
          aiClassification: item.aiClassification,
        })),
        classifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    logger.info('aiClassifyFood: Classification complete.', {
      donationId,
      totalItems: foodItems.length,
      classificationLatencyMs,
    });

    // Trigger matching engine if all items classified (non-blocking stub)
    const allClassified = classifiedItems.every(
      (item) => item.aiClassification?.status !== 'pending'
    );
    if (allClassified) {
      logger.info('aiClassifyFood: All items classified. Triggering matching engine.', { donationId });
      // Production: await pubSubClient.topic('trigger-matching').publishMessage({ json: { donationId } });
    }
  }
);
