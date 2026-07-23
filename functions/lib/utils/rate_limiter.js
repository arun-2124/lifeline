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
exports.checkRateLimit = checkRateLimit;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
async function checkRateLimit(key, maxAttempts, windowMs) {
    const db = admin.firestore();
    const rateLimitRef = db.collection('rate_limits').doc(key);
    const now = Date.now();
    await db.runTransaction(async (transaction) => {
        const doc = await transaction.get(rateLimitRef);
        if (!doc.exists) {
            transaction.set(rateLimitRef, {
                count: 1,
                resetAt: now + windowMs,
            });
            return;
        }
        const data = doc.data();
        if (now > data.resetAt) {
            // Window expired, reset counter
            transaction.set(rateLimitRef, {
                count: 1,
                resetAt: now + windowMs,
            });
        }
        else {
            if (data.count >= maxAttempts) {
                throw new https_1.HttpsError('resource-exhausted', `Rate limit exceeded for action (${key}). Please try again later.`);
            }
            transaction.update(rateLimitRef, {
                count: admin.firestore.FieldValue.increment(1),
            });
        }
    });
}
//# sourceMappingURL=rate_limiter.js.map