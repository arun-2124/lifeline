import 'package:flutter/foundation.dart';

enum PaymentGatewayType {
  upi,
  razorpay,
  cashfree,
  phonepe,
  stripe,
}

abstract class PaymentGatewayService {
  Future<bool> initializeGateway(PaymentGatewayType gatewayType);
  Future<Map<String, dynamic>> processPayout({
    required String recipientUpiOrAccount,
    required double amount,
    required String referenceId,
  });
  Future<bool> verifyUpiId(String upiId);
}

class MockPaymentGatewayService implements PaymentGatewayService {
  @override
  Future<bool> initializeGateway(PaymentGatewayType gatewayType) async {
    debugPrint('[PAYMENT_GATEWAY] Initialized ${gatewayType.name} payment gateway abstraction layer.');
    return true;
  }

  @override
  Future<Map<String, dynamic>> processPayout({
    required String recipientUpiOrAccount,
    required double amount,
    required String referenceId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    debugPrint('[PAYMENT_GATEWAY] Mock payout of ₹$amount to $recipientUpiOrAccount (Ref: $referenceId)');
    return {
      'success': true,
      'transactionRef': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      'gateway': 'UPI_Mock_Adapter',
    };
  }

  @override
  Future<bool> verifyUpiId(String upiId) async {
    if (upiId.contains('@')) {
      return true;
    }
    return false;
  }
}
