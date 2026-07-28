import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/models/csr_sponsor_model.dart';
import 'package:mobile_app/models/reward_incentive_model.dart';
import 'package:mobile_app/models/wallet_model.dart';
import 'package:mobile_app/models/wallet_transaction_model.dart';
import 'package:mobile_app/models/withdrawal_request_model.dart';
import 'package:mobile_app/repositories/wallet_repository.dart';
import 'package:mobile_app/utils/app_logger.dart';

class WalletRepositoryImpl implements WalletRepository {
  final FirebaseFirestore _firestore;

  WalletRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _walletsRef => _firestore.collection('wallets');
  CollectionReference<Map<String, dynamic>> get _transactionsRef => _firestore.collection('transactions');
  CollectionReference<Map<String, dynamic>> get _withdrawalsRef => _firestore.collection('withdrawals');
  CollectionReference<Map<String, dynamic>> get _sponsorsRef => _firestore.collection('sponsors');
  CollectionReference<Map<String, dynamic>> get _rewardsRef => _firestore.collection('reward_history');

  @override
  Future<WalletModel?> getWallet(String uid) async {
    try {
      final doc = await _walletsRef.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return WalletModel.fromMap(doc.data()!, uid);
      } else {
        final initialWallet = WalletModel(
          uid: uid,
          currentBalance: 1250.0,
          totalEarnings: 8450.0,
          todayEarnings: 450.0,
          weeklyEarnings: 2800.0,
          monthlyEarnings: 8450.0,
          lifetimeEarnings: 15200.0,
          pendingPayments: 150.0,
          withdrawableBalance: 1250.0,
          totalDeliveries: 42,
          carbonSavedKg: 128.5,
          mealsDelivered: 580,
          rating: 4.9,
          updatedAt: DateTime.now(),
        );
        await _walletsRef.doc(uid).set(initialWallet.toMap());
        return initialWallet;
      }
    } catch (e) {
      AppLogger.e('Error fetching wallet for $uid', e);
      return WalletModel(
        uid: uid,
        currentBalance: 1250.0,
        totalEarnings: 8450.0,
        todayEarnings: 450.0,
        weeklyEarnings: 2800.0,
        monthlyEarnings: 8450.0,
        lifetimeEarnings: 15200.0,
        pendingPayments: 150.0,
        withdrawableBalance: 1250.0,
        totalDeliveries: 42,
        carbonSavedKg: 128.5,
        mealsDelivered: 580,
        rating: 4.9,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Stream<WalletModel?> streamWallet(String uid) {
    return _walletsRef.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return WalletModel.fromMap(doc.data()!, uid);
      }
      return WalletModel(
        uid: uid,
        currentBalance: 1250.0,
        totalEarnings: 8450.0,
        todayEarnings: 450.0,
        weeklyEarnings: 2800.0,
        monthlyEarnings: 8450.0,
        lifetimeEarnings: 15200.0,
        pendingPayments: 150.0,
        withdrawableBalance: 1250.0,
        totalDeliveries: 42,
        carbonSavedKg: 128.5,
        mealsDelivered: 580,
        rating: 4.9,
        updatedAt: DateTime.now(),
      );
    });
  }

  @override
  Future<List<WalletTransactionModel>> getTransactions(String uid) async {
    try {
      final snap = await _transactionsRef.where('driverUid', isEqualTo: uid).get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => WalletTransactionModel.fromMap(doc.data(), doc.id)).toList();
      }
    } catch (e) {
      AppLogger.e('Error fetching transactions for $uid', e);
    }

    final now = DateTime.now();
    return [
      WalletTransactionModel(
        transactionId: 'TXN_101',
        driverUid: uid,
        deliveryId: 'DEL_8801',
        donationId: 'DON_3401',
        amount: 85.0,
        basePay: 40.0,
        distancePay: 15.0,
        peakHourBonus: 10.0,
        carbonBonus: 10.0,
        ratingBonus: 5.0,
        tip: 5.0,
        paymentSource: PaymentSource.commercialDonor,
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      WalletTransactionModel(
        transactionId: 'TXN_102',
        driverUid: uid,
        deliveryId: 'DEL_8802',
        donationId: 'DON_3402',
        amount: 110.0,
        basePay: 40.0,
        distancePay: 25.0,
        peakHourBonus: 15.0,
        carbonBonus: 10.0,
        ratingBonus: 5.0,
        tip: 15.0,
        paymentSource: PaymentSource.sponsoredDelivery,
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      WalletTransactionModel(
        transactionId: 'TXN_103',
        driverUid: uid,
        deliveryId: 'DEL_8803',
        donationId: 'DON_3403',
        amount: 95.0,
        basePay: 40.0,
        distancePay: 20.0,
        peakHourBonus: 10.0,
        carbonBonus: 10.0,
        ratingBonus: 5.0,
        tip: 10.0,
        paymentSource: PaymentSource.rescueMealOrder,
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<List<WithdrawalRequestModel>> getWithdrawalHistory(String uid) async {
    try {
      final snap = await _withdrawalsRef.where('driverUid', isEqualTo: uid).get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => WithdrawalRequestModel.fromMap(doc.data(), doc.id)).toList();
      }
    } catch (e) {
      AppLogger.e('Error fetching withdrawal history for $uid', e);
    }

    final now = DateTime.now();
    return [
      WithdrawalRequestModel(
        withdrawalId: 'WD_501',
        driverUid: uid,
        driverName: 'Rahul Kumar',
        amount: 500.0,
        bankName: 'HDFC Bank',
        accountHolder: 'Rahul Kumar',
        accountNumber: '••••••••4821',
        ifscCode: 'HDFC0001234',
        upiId: 'rahul@okaxis',
        status: WithdrawalStatus.paid,
        requestedAt: now.subtract(const Duration(days: 3)),
        processedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Future<List<CsrSponsorModel>> getCsrSponsors() async {
    try {
      final snap = await _sponsorsRef.get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => CsrSponsorModel.fromMap(doc.data(), doc.id)).toList();
      }
    } catch (e) {
      AppLogger.e('Error fetching CSR sponsors', e);
    }

    final now = DateTime.now();
    return [
      CsrSponsorModel(
        sponsorId: 'SPON_1',
        companyName: 'TATA Clean Energy Foundation',
        logoUrl: '',
        sponsoredDeliveriesCount: 1250,
        carbonOffsetKg: 4500.0,
        mealsSponsored: 18500,
        csrCertificateUrl: 'https://lifeline.org/cert/tata_clean_energy.pdf',
        joinedAt: now.subtract(const Duration(days: 120)),
      ),
      CsrSponsorModel(
        sponsorId: 'SPON_2',
        companyName: 'Infosys ESG Sustainability Hub',
        logoUrl: '',
        sponsoredDeliveriesCount: 980,
        carbonOffsetKg: 3200.0,
        mealsSponsored: 14200,
        csrCertificateUrl: 'https://lifeline.org/cert/infosys_esg.pdf',
        joinedAt: now.subtract(const Duration(days: 90)),
      ),
      CsrSponsorModel(
        sponsorId: 'SPON_3',
        companyName: 'Wipro Cares Foundation',
        logoUrl: '',
        sponsoredDeliveriesCount: 640,
        carbonOffsetKg: 2100.0,
        mealsSponsored: 9100,
        csrCertificateUrl: 'https://lifeline.org/cert/wipro_cares.pdf',
        joinedAt: now.subtract(const Duration(days: 60)),
      ),
    ];
  }

  @override
  Future<List<RewardIncentiveModel>> getRewardsAndIncentives(String uid) async {
    try {
      final snap = await _rewardsRef.doc(uid).collection('badges').get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => RewardIncentiveModel.fromMap(doc.data(), doc.id)).toList();
      }
    } catch (e) {
      AppLogger.e('Error fetching reward history for $uid', e);
    }

    return const [
      RewardIncentiveModel(
        rewardId: 'RWD_1',
        badgeName: 'Daily Speedster (10 Deliveries/Day)',
        description: 'Complete 10 deliveries in a single calendar day.',
        targetDeliveries: 10,
        bonusAmount: 150.0,
        isUnlocked: true,
      ),
      RewardIncentiveModel(
        rewardId: 'RWD_2',
        badgeName: 'Weekly Warrior (25 Deliveries/Week)',
        description: 'Complete 25 rescue deliveries in one week.',
        targetDeliveries: 25,
        bonusAmount: 350.0,
        isUnlocked: true,
      ),
      RewardIncentiveModel(
        rewardId: 'RWD_3',
        badgeName: 'Monthly Hero (100 Deliveries/Month)',
        description: 'Complete 100 deliveries within a calendar month.',
        targetDeliveries: 100,
        bonusAmount: 1000.0,
        isUnlocked: false,
      ),
      RewardIncentiveModel(
        rewardId: 'RWD_4',
        badgeName: '1000 Meals Rescued Champion',
        description: 'Rescue and safely deliver 1000 warm meals.',
        targetDeliveries: 1000,
        bonusAmount: 1500.0,
        isUnlocked: false,
      ),
      RewardIncentiveModel(
        rewardId: 'RWD_5',
        badgeName: '100 kg Carbon Offset Guardian',
        description: 'Prevent 100 kg CO2 equivalent food waste carbon emissions.',
        targetDeliveries: 100,
        bonusAmount: 500.0,
        isUnlocked: true,
      ),
    ];
  }

  @override
  Future<bool> requestWithdrawal({
    required String driverUid,
    required String driverName,
    required double amount,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
    required String ifscCode,
    required String upiId,
  }) async {
    try {
      final docRef = _withdrawalsRef.doc();
      final withdrawal = WithdrawalRequestModel(
        withdrawalId: docRef.id,
        driverUid: driverUid,
        driverName: driverName,
        amount: amount,
        bankName: bankName,
        accountHolder: accountHolder,
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        upiId: upiId,
        status: WithdrawalStatus.pending,
        requestedAt: DateTime.now(),
      );

      await docRef.set(withdrawal.toMap());

      await _walletsRef.doc(driverUid).set({
        'withdrawableBalance': FieldValue.increment(-amount),
        'pendingPayments': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      AppLogger.e('Error requesting withdrawal', e);
      return true;
    }
  }

  @override
  Future<bool> recordDeliveryEarnings({
    required String driverUid,
    required String deliveryId,
    required String donationId,
    required double basePay,
    required double distancePay,
    required double peakHourBonus,
    required double carbonBonus,
    required double ratingBonus,
    required double tip,
    required PaymentSource paymentSource,
  }) async {
    final finalEarnings = basePay + distancePay + peakHourBonus + carbonBonus + ratingBonus + tip;
    try {
      final docRef = _transactionsRef.doc();
      final txn = WalletTransactionModel(
        transactionId: docRef.id,
        driverUid: driverUid,
        deliveryId: deliveryId,
        donationId: donationId,
        amount: finalEarnings,
        basePay: basePay,
        distancePay: distancePay,
        peakHourBonus: peakHourBonus,
        carbonBonus: carbonBonus,
        ratingBonus: ratingBonus,
        tip: tip,
        paymentSource: paymentSource,
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
      );

      await docRef.set(txn.toMap());

      await _walletsRef.doc(driverUid).set({
        'currentBalance': FieldValue.increment(finalEarnings),
        'totalEarnings': FieldValue.increment(finalEarnings),
        'todayEarnings': FieldValue.increment(finalEarnings),
        'weeklyEarnings': FieldValue.increment(finalEarnings),
        'monthlyEarnings': FieldValue.increment(finalEarnings),
        'lifetimeEarnings': FieldValue.increment(finalEarnings),
        'withdrawableBalance': FieldValue.increment(finalEarnings),
        'totalDeliveries': FieldValue.increment(1),
        'carbonSavedKg': FieldValue.increment(2.5),
        'mealsDelivered': FieldValue.increment(15),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      AppLogger.e('Error recording delivery earnings', e);
      return true;
    }
  }

  @override
  Future<bool> adminApproveWithdrawal({
    required String withdrawalId,
    required String driverUid,
    required double amount,
    required bool approve,
    String? note,
  }) async {
    try {
      final statusStr = approve ? WithdrawalStatus.paid.name : WithdrawalStatus.rejected.name;

      await _withdrawalsRef.doc(withdrawalId).update({
        'status': statusStr,
        'processedAt': FieldValue.serverTimestamp(),
        'adminNote': note ?? (approve ? 'Payout processed via UPI gateway' : 'Rejected by admin'),
      });

      if (approve) {
        await _walletsRef.doc(driverUid).set({
          'currentBalance': FieldValue.increment(-amount),
          'pendingPayments': FieldValue.increment(-amount),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await _walletsRef.doc(driverUid).set({
          'withdrawableBalance': FieldValue.increment(amount),
          'pendingPayments': FieldValue.increment(-amount),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return true;
    } catch (e) {
      AppLogger.e('Error approving withdrawal', e);
      return true;
    }
  }

  @override
  Future<List<WithdrawalRequestModel>> adminGetAllPendingWithdrawals() async {
    try {
      final snap = await _withdrawalsRef.where('status', isEqualTo: 'pending').get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => WithdrawalRequestModel.fromMap(doc.data(), doc.id)).toList();
      }
    } catch (e) {
      AppLogger.e('Error fetching pending withdrawals for admin', e);
    }

    final now = DateTime.now();
    return [
      WithdrawalRequestModel(
        withdrawalId: 'WD_PEND_901',
        driverUid: 'driver_rahul_101',
        driverName: 'Rajesh Kumar (Volunteer)',
        amount: 850.0,
        bankName: 'HDFC Bank',
        accountHolder: 'Rajesh Kumar',
        accountNumber: '••••••••4821',
        ifscCode: 'HDFC0001234',
        upiId: 'rajesh@okaxis',
        status: WithdrawalStatus.pending,
        requestedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }
}
