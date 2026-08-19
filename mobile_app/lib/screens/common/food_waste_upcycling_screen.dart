import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class FoodWasteUpcyclingScreen extends StatefulWidget {
  const FoodWasteUpcyclingScreen({super.key});

  @override
  State<FoodWasteUpcyclingScreen> createState() => _FoodWasteUpcyclingScreenState();
}

class _FoodWasteUpcyclingScreenState extends State<FoodWasteUpcyclingScreen> {
  final _quantityController = TextEditingController(text: '35');
  String _upcycleCategory = 'Biogas Generation';
  bool _isSubmitted = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _submitUpcyclingRequest() {
    setState(() => _isSubmitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unusable Food Upcycling Dispatch Request Created! Sent to local Biogas facility.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Zero-Waste Upcycling Pathway',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF15803D), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.recycling_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        '100% Landfill Diversion Guarantee',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Unusable & Expired Food Upcycling',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Food unsafe for human consumption is automatically routed to Biogas Plants, Compost Units, and Bio-Fertilizer Processors.',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // UPCYCLING PATHWAYS SELECTION
            const Text(
              'Select Industrial Upcycling Destination',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Biogas Energy Generation (Anaerobic Digestion)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Converts food waste into clean methane gas for domestic cooking energy.', style: TextStyle(fontSize: 11)),
                    leading: Icon(
                      _upcycleCategory == 'Biogas Generation' ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: AppColors.success,
                    ),
                    onTap: () => setState(() => _upcycleCategory = 'Biogas Generation'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Organic Composting Facility', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Transforms organic waste into nutrient-dense soil compost within 14 days.', style: TextStyle(fontSize: 11)),
                    leading: Icon(
                      _upcycleCategory == 'Organic Compost' ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: AppColors.success,
                    ),
                    onTap: () => setState(() => _upcycleCategory = 'Organic Compost'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Bio-Fertilizer Processing Unit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Processes raw nutrients for local sustainable agriculture farms.', style: TextStyle(fontSize: 11)),
                    leading: Icon(
                      _upcycleCategory == 'Bio-Fertilizer' ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: AppColors.success,
                    ),
                    onTap: () => setState(() => _upcycleCategory = 'Bio-Fertilizer'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // QUANTITY & ACTION FORM
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spoiled / Unusable Food Quantity (kg)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '35',
                      suffixText: 'kg',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Methane Offset Potential', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('~14.2 m³ Clean Gas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success)),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSubmitted ? null : _submitUpcyclingRequest,
                        icon: Icon(_isSubmitted ? Icons.check_circle_rounded : Icons.local_shipping_rounded, color: Colors.white),
                        label: Text(_isSubmitted ? 'Dispatched' : 'Dispatch for Upcycling', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
