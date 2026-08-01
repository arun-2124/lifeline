import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final List<Map<String, String>> _topics = const [
    {
      'title': '1. Data We Collect',
      'content': 'We collect your full name, email address, phone number, role type, verification documents, and device telemetry when using Lifeline.',
    },
    {
      'title': '2. Purpose of Data Collection',
      'content': 'Data is used strictly to authenticate user identity, route delivery volunteers, match surplus food with nearby beneficiaries, and prevent fraud.',
    },
    {
      'title': '3. Firebase Services Integration',
      'content': 'Lifeline uses Firebase Authentication for secure sign-in, Cloud Firestore for encrypted profile storage, and Firebase Storage for verification images.',
    },
    {
      'title': '4. Location Services (GPS Telemetry)',
      'content': 'Location telemetry is collected during active deliveries to display live 3D turn-by-turn navigation and estimated meal arrival times.',
    },
    {
      'title': '5. Camera & Media Usage',
      'content': 'Camera permission is requested only to capture food photos for AI freshness evaluation, QR code verification, and hygiene self-declarations.',
    },
    {
      'title': '6. Push Notifications (FCM)',
      'content': 'Firebase Cloud Messaging delivers critical alerts regarding food availability, donation pickups, and live delivery status updates.',
    },
    {
      'title': '7. Data Retention & User Rights',
      'content': 'Your data is securely stored in Cloud Firestore. You have the right to access, update, export, or request permanent deletion of your personal data at any time.',
    },
    {
      'title': '8. Account Deletion Process',
      'content': 'You can request full account deletion via Profile > Account Settings > Delete Account. All associated personal records will be purged within 30 days.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy v1.0',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _topics.length,
        itemBuilder: (context, index) {
          final item = _topics[index];
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item['content']!,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
