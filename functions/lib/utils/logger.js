"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Logger = void 0;
class Logger {
    static info(message, meta) {
        console.log(JSON.stringify({
            severity: 'INFO',
            message,
            timestamp: new Date().toISOString(),
            ...meta,
        }));
    }
    static warn(message, meta) {
        console.warn(JSON.stringify({
            severity: 'WARNING',
            message,
            timestamp: new Date().toISOString(),
            ...meta,
        }));
    }
    static error(message, error, meta) {
        console.error(JSON.stringify({
            severity: 'ERROR',
            message,
            error: error?.message || error,
            stack: error?.stack,
            timestamp: new Date().toISOString(),
            ...meta,
        }));
    }
    static audit(action, actorUid, details) {
        console.log(JSON.stringify({
            severity: 'NOTICE',
            event: 'AUDIT_LOG',
            action,
            actorUid,
            details,
            timestamp: new Date().toISOString(),
        }));
    }
}
exports.Logger = Logger;
//# sourceMappingURL=logger.js.map