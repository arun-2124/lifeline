abstract class PaymentGatewayService {
  Future<PaymentResult> processPayment({
    required String orderId,
    required double amount,
    required String currency,
    required String paymentMethod, // UPI, CARD, NET_BANKING, WALLET
  });

  Future<bool> verifyPaymentSignature({
    required String paymentId,
    required String signature,
  });

  Future<bool> processRefund({
    required String paymentId,
    required double amount,
  });
}

class PaymentResult {
  final bool isSuccess;
  final String paymentId;
  final String? errorMessage;
  final String transactionReference;

  const PaymentResult({
    required this.isSuccess,
    required this.paymentId,
    this.errorMessage,
    required this.transactionReference,
  });
}

class MockPaymentGatewayService implements PaymentGatewayService {
  @override
  Future<PaymentResult> processPayment({
    required String orderId,
    required double amount,
    required String currency,
    required String paymentMethod,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return PaymentResult(
      isSuccess: true,
      paymentId: 'PAY_${DateTime.now().millisecondsSinceEpoch}',
      transactionReference: 'TXN_REF_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<bool> verifyPaymentSignature({
    required String paymentId,
    required String signature,
  }) async {
    return true;
  }

  @override
  Future<bool> processRefund({
    required String paymentId,
    required double amount,
  }) async {
    return true;
  }
}
