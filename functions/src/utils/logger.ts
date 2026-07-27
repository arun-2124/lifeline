export class Logger {
  static info(message: string, meta?: Record<string, any>): void {
    console.log(JSON.stringify({
      severity: 'INFO',
      message,
      timestamp: new Date().toISOString(),
      ...meta,
    }));
  }

  static warn(message: string, meta?: Record<string, any>): void {
    console.warn(JSON.stringify({
      severity: 'WARNING',
      message,
      timestamp: new Date().toISOString(),
      ...meta,
    }));
  }

  static error(message: string, error?: any, meta?: Record<string, any>): void {
    console.error(JSON.stringify({
      severity: 'ERROR',
      message,
      error: error?.message || error,
      stack: error?.stack,
      timestamp: new Date().toISOString(),
      ...meta,
    }));
  }

  static audit(action: string, actorUid: string, details: Record<string, any>): void {
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
