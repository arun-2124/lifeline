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
exports.expireDonations = exports.aiClassifyFood = exports.processImages = exports.cancelDonation = exports.updateDonation = exports.createDonation = exports.checkAccountStatus = exports.validateProfile = exports.onUserDeleted = exports.onUserCreated = void 0;
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions/v1"));
// Initialize Firebase Admin SDK (once)
admin.initializeApp();
// ── Sprint 2: Auth Functions ──────────────────────────────────────────────────
const onUserCreated_1 = require("./triggers/onUserCreated");
const onUserDeleted_1 = require("./triggers/onUserDeleted");
exports.onUserCreated = functions.auth.user().onCreate(async (user) => {
    await (0, onUserCreated_1.handleUserCreated)(user);
});
exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
    await (0, onUserDeleted_1.handleUserDeleted)(user);
});
// ── Sprint 2: Auth Callables ──────────────────────────────────────────────────
var validateProfile_1 = require("./callables/validateProfile");
Object.defineProperty(exports, "validateProfile", { enumerable: true, get: function () { return validateProfile_1.validateProfile; } });
var checkAccountStatus_1 = require("./callables/checkAccountStatus");
Object.defineProperty(exports, "checkAccountStatus", { enumerable: true, get: function () { return checkAccountStatus_1.checkAccountStatus; } });
// ── Sprint 3: Donation Callables ──────────────────────────────────────────────
var createDonation_1 = require("./callables/createDonation");
Object.defineProperty(exports, "createDonation", { enumerable: true, get: function () { return createDonation_1.createDonation; } });
var updateDonation_1 = require("./callables/updateDonation");
Object.defineProperty(exports, "updateDonation", { enumerable: true, get: function () { return updateDonation_1.updateDonation; } });
var cancelDonation_1 = require("./callables/cancelDonation");
Object.defineProperty(exports, "cancelDonation", { enumerable: true, get: function () { return cancelDonation_1.cancelDonation; } });
// ── Sprint 3: Storage Trigger ─────────────────────────────────────────────────
var processImages_1 = require("./triggers/processImages");
Object.defineProperty(exports, "processImages", { enumerable: true, get: function () { return processImages_1.processImages; } });
// ── Sprint 3: PubSub Trigger ──────────────────────────────────────────────────
var aiClassifyFood_1 = require("./triggers/aiClassifyFood");
Object.defineProperty(exports, "aiClassifyFood", { enumerable: true, get: function () { return aiClassifyFood_1.aiClassifyFood; } });
// ── Sprint 3: Scheduled Function ──────────────────────────────────────────────
var expireDonations_1 = require("./triggers/expireDonations");
Object.defineProperty(exports, "expireDonations", { enumerable: true, get: function () { return expireDonations_1.expireDonations; } });
//# sourceMappingURL=index.js.map