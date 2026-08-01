import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/user_model.dart';
import 'package:mobile_app/models/donation_model.dart';

void main() {
  group('Lifeline Production Core Unit Tests', () {
    test('UserModel instantiates with default Phase 3 verification level and scores', () {
      final user = UserModel(
        uid: 'TEST_UID_123',
        fullName: 'Arun Balaji',
        email: 'arun@example.com',
        phoneNumber: '9876543210',
        role: 'Donor',
        createdAt: DateTime.now(),
      );

      expect(user.uid, equals('TEST_UID_123'));
      expect(user.verificationLevel, equals(1));
      expect(user.reputationScore, equals(98.5));
      expect(user.trustScore, equals(5.0));
      expect(user.unlockedBadges.contains('🌱 First Donation'), isTrue);
    });

    test('DonationModel validates mandatory food quality safety checklist', () {
      final donation = DonationModel(
        donationId: 'DONATION_987654',
        donorId: 'DONOR_UID_123',
        donorName: 'Royal Kitchen',
        foodName: 'Vegetable Biryani',
        foodCategory: 'Cooked Meal',
        foodType: 'Veg',
        quantity: 25.0,
        unit: 'plates',
        numberOfMeals: 50,
        preparationTime: DateTime.now(),
        expiryTime: DateTime.now().add(const Duration(hours: 4)),
        pickupAddress: 'MG Road, Indiranagar, Bengaluru',
        latitude: 12.9716,
        longitude: 77.5946,
        contactNumber: '9876543210',
        isFreshlyCooked: true,
        isProperlyPacked: true,
        isHygienicallyPrepared: true,
        isProperlyStored: true,
        isSafeForConsumption: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(donation.isChecklistComplete, isTrue);
      expect(donation.status, equals('Available'));
    });
  });
}
