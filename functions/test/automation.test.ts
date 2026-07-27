import { Logger } from '../src/utils/logger';

describe('Firebase Automation Utilities Test Suite', () => {
  test('Logger emits structured JSON format correctly', () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation();
    
    Logger.info('Test log message', { testKey: 'testValue' });

    expect(consoleSpy).toHaveBeenCalledTimes(1);
    const logOutput = JSON.parse(consoleSpy.mock.calls[0][0]);
    expect(logOutput.severity).toBe('INFO');
    expect(logOutput.message).toBe('Test log message');
    expect(logOutput.testKey).toBe('testValue');

    consoleSpy.mockRestore();
  });

  test('Logger records audit events correctly', () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation();

    Logger.audit('USER_ROLE_CHANGED', 'uid_123', { oldRole: 'DONOR', newRole: 'NGO' });

    expect(consoleSpy).toHaveBeenCalledTimes(1);
    const logOutput = JSON.parse(consoleSpy.mock.calls[0][0]);
    expect(logOutput.event).toBe('AUDIT_LOG');
    expect(logOutput.action).toBe('USER_ROLE_CHANGED');
    expect(logOutput.actorUid).toBe('uid_123');

    consoleSpy.mockRestore();
  });
});
