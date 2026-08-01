import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class TermsConditionsScreen extends StatefulWidget {
  final bool showAcceptButton;
  final VoidCallback? onAccept;

  const TermsConditionsScreen({
    super.key,
    this.showAcceptButton = false,
    this.onAccept,
  });

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _sections = const [
    {
      'title': '1. Introduction',
      'content': 'Welcome to Lifeline. Lifeline is a technology platform connecting food donors, NGOs, volunteers, and beneficiaries to prevent food waste and alleviate hunger.',
    },
    {
      'title': '2. User Responsibilities',
      'content': 'All users agree to provide accurate registration details, maintain secure password credentials, and adhere to community guidelines at all times.',
    },
    {
      'title': '3. Food Donation Guidelines',
      'content': 'Donors certify that all shared food is freshly prepared, stored in hygienic containers, and completely safe for human consumption.',
    },
    {
      'title': '4. Community Guidelines',
      'content': 'Lifeline maintains zero tolerance for harassment, discrimination, misuse of shared resources, or commercial reselling of donated food.',
    },
    {
      'title': '5. Delivery Partner Responsibilities',
      'content': 'Delivery partners agree to transport meals in clean insulated carriers, maintain real-time GPS telemetry, and deliver prompt assistance.',
    },
    {
      'title': '6. Platform Limitations',
      'content': 'Lifeline acts solely as a technological facilitator and disclaims liability for independent actions of platform users.',
    },
    {
      'title': '7. Privacy & Data Handling',
      'content': 'User personal data, location telemetry, and contact details are processed strictly in accordance with the Lifeline Privacy Policy.',
    },
    {
      'title': '8. Liability Disclaimer',
      'content': 'Lifeline shall not be held liable for damages, food spoilage during transit, or indirect losses arising from platform usage.',
    },
    {
      'title': '9. Account Suspension Policy',
      'content': 'Repeated safety violations, false declarations, or breach of community standards will result in immediate permanent account suspension.',
    },
    {
      'title': '10. Contact Information',
      'content': 'For questions, support, or policy inquiries, contact legal@lifeline.org or visit our support dashboard.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredSections {
    if (_searchQuery.isEmpty) return _sections;
    return _sections.where((sec) {
      return sec['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          sec['content']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions v1.0',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search terms (e.g., Donation, Hygiene, Privacy)...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Scrollable Sections
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredSections.length,
                itemBuilder: (context, index) {
                  final sec = _filteredSections[index];
                  return GlassCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.zero,
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        sec['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: Text(
                            sec['content']!,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            if (widget.showAcceptButton)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: widget.onAccept ?? () => Navigator.of(context).pop(true),
                    child: const Text(
                      'I Understand & Accept Terms v1.0',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
