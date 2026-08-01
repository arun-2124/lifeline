import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class ImpactDashboardScreen extends ConsumerWidget {
  const ImpactDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(homeCookNotifierProvider).profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Community Impact Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Food Rescue Impact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  _MetricRow(label: 'Meals Shared', value: '${profile?.mealsShared ?? 340} meals', icon: Icons.fastfood_rounded, color: AppColors.primary),
                  const SizedBox(height: 12),
                  _MetricRow(label: 'People Helped', value: '${profile?.peopleHelped ?? 280} individuals', icon: Icons.groups_rounded, color: AppColors.success),
                  const SizedBox(height: 12),
                  _MetricRow(label: 'Food Waste Prevented', value: '${profile?.wastePreventedKg.toStringAsFixed(1) ?? 120.0} kg', icon: Icons.delete_outline_rounded, color: Colors.deepOrange),
                  const SizedBox(height: 12),
                  _MetricRow(label: 'Carbon Offset (CO2)', value: '${profile?.carbonSavedKg.toStringAsFixed(1) ?? 85.5} kg', icon: Icons.eco_rounded, color: AppColors.info),
                  const SizedBox(height: 12),
                  _MetricRow(label: 'Volunteer Time Contributed', value: '${profile?.volunteerHours ?? 45} hours', icon: Icons.timer_rounded, color: Colors.purple),
                  const Divider(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Monthly Community Growth', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      Text('+24% increase', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
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

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ],
    );
  }
}
