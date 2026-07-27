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
exports.scheduledDailyAnalytics = exports.scheduledCleanupNotifications = exports.scheduledExpireDonations = exports.aiClassifyFood = exports.processImages = exports.onDeliveryStatusChanged = exports.onDeliveryAssigned = exports.onDonationAccepted = exports.onDonationCreated = exports.cancelDonation = exports.updateDonation = exports.createDonation = exports.checkAccountStatus = exports.validateProfile = exports.handleUserDeleted = exports.handleUserCreated = void 0;
const admin = __importStar(require("firebase-admin"));
// Initialize Firebase Admin SDK singleton
if (!admin.apps.length) {
    admin.initializeApp();
}
// ── Auth Triggers ─────────────────────────────────────────────────────────────
var onUserCreated_1 = require("./triggers/onUserCreated");
Object.defineProperty(exports, "handleUserCreated", { enumerable: true, get: function () { return onUserCreated_1.handleUserCreated; } });
var onUserDeleted_1 = require("./triggers/onUserDeleted");
Object.defineProperty(exports, "handleUserDeleted", { enumerable: true, get: function () { return onUserDeleted_1.handleUserDeleted; } });
// ── Auth Callables ────────────────────────────────────────────────────────────
var validateProfile_1 = require("./callables/validateProfile");
Object.defineProperty(exports, "validateProfile", { enumerable: true, get: function () { return validateProfile_1.validateProfile; } });
var checkAccountStatus_1 = require("./callables/checkAccountStatus");
Object.defineProperty(exports, "checkAccountStatus", { enumerable: true, get: function () { return checkAccountStatus_1.checkAccountStatus; } });
// ── Donation Callables ────────────────────────────────────────────────────────
var createDonation_1 = require("./callables/createDonation");
Object.defineProperty(exports, "createDonation", { enumerable: true, get: function () { return createDonation_1.createDonation; } });
var updateDonation_1 = require("./callables/updateDonation");
Object.defineProperty(exports, "updateDonation", { enumerable: true, get: function () { return updateDonation_1.updateDonation; } });
var cancelDonation_1 = require("./callables/cancelDonation");
Object.defineProperty(exports, "cancelDonation", { enumerable: true, get: function () { return cancelDonation_1.cancelDonation; } });
// ── Event Triggers (Donation, NGO, Volunteer, Delivery) ──────────────────────
var onDonationCreated_1 = require("./triggers/onDonationCreated");
Object.defineProperty(exports, "onDonationCreated", { enumerable: true, get: function () { return onDonationCreated_1.onDonationCreated; } });
var onDonationAccepted_1 = require("./triggers/onDonationAccepted");
Object.defineProperty(exports, "onDonationAccepted", { enumerable: true, get: function () { return onDonationAccepted_1.onDonationAccepted; } });
var onDeliveryAssigned_1 = require("./triggers/onDeliveryAssigned");
Object.defineProperty(exports, "onDeliveryAssigned", { enumerable: true, get: function () { return onDeliveryAssigned_1.onDeliveryAssigned; } });
var onDeliveryStatusChanged_1 = require("./triggers/onDeliveryStatusChanged");
Object.defineProperty(exports, "onDeliveryStatusChanged", { enumerable: true, get: function () { return onDeliveryStatusChanged_1.onDeliveryStatusChanged; } });
// ── Storage & AI Triggers ─────────────────────────────────────────────────────
var processImages_1 = require("./triggers/processImages");
Object.defineProperty(exports, "processImages", { enumerable: true, get: function () { return processImages_1.processImages; } });
var aiClassifyFood_1 = require("./triggers/aiClassifyFood");
Object.defineProperty(exports, "aiClassifyFood", { enumerable: true, get: function () { return aiClassifyFood_1.aiClassifyFood; } });
// ── Scheduled Cron Functions ──────────────────────────────────────────────────
var scheduledTasks_1 = require("./triggers/scheduledTasks");
Object.defineProperty(exports, "scheduledExpireDonations", { enumerable: true, get: function () { return scheduledTasks_1.scheduledExpireDonations; } });
Object.defineProperty(exports, "scheduledCleanupNotifications", { enumerable: true, get: function () { return scheduledTasks_1.scheduledCleanupNotifications; } });
Object.defineProperty(exports, "scheduledDailyAnalytics", { enumerable: true, get: function () { return scheduledTasks_1.scheduledDailyAnalytics; } });
//# sourceMappingURL=index.js.map