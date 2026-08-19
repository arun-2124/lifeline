import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/glass_card.dart';
import 'package:mobile_app/widgets/responsive_layout.dart';

class LandingPageScreen extends ConsumerWidget {
  const LandingPageScreen({super.key});

  void _quickDemoLogin(BuildContext context, WidgetRef ref, String role) async {
    // Quick role login for hackathon judges demonstration
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.loginUser(
      email: '${role.toLowerCase().replaceAll(' ', '')}@lifeline.org',
      password: 'Password123!',
    );

    if (context.mounted) {
      final route = AppRouter.getHomeRouteForRole(role);
      Navigator.of(context).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // HACKATHON HERO BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber, width: 1.5),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'HACKATHON DEMO EDITION • LIFELINE 2.0',
                            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'LIFELINE',
                      style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2.0),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Surplus Food Rescue, Verified Home Cook & Zero-Waste Ecosystem',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRouter.loginRoute);
                          },
                          icon: const Icon(Icons.rocket_launch_rounded, color: Colors.white),
                          label: const Text('Launch Production Web App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRouter.upcyclingRoute);
                          },
                          icon: const Icon(Icons.recycling_rounded, color: AppColors.success),
                          label: const Text('Zero-Waste Upcycling Flow', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // LIVE IMPACT METRICS BAR
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(child: _MetricCard(title: 'Meals Rescued', value: '345,000+', icon: Icons.restaurant_rounded, color: AppColors.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: _MetricCard(title: 'Carbon Saved', value: '14.8 Tons', icon: Icons.eco_rounded, color: AppColors.success)),
                    const SizedBox(width: 10),
                    Expanded(child: _MetricCard(title: 'Verified Cooks', value: '1,240', icon: Icons.verified_rounded, color: Colors.amber)),
                  ],
                ),
              ),

              // HACKATHON JUDGE FLOW DEMONSTRATOR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.alt_route_rounded, color: AppColors.primary, size: 24),
                          SizedBox(width: 8),
                          Text('Complete End-to-End Hackathon Journey', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const _FlowStepTile(step: '1', title: 'Landing Page & Quick Authentication', subtitle: 'Select role below or log in with verified credentials'),
                      const _FlowStepTile(step: '2', title: 'Donor Portal & Create Surplus Food Donation', subtitle: '4-Step form with 5 mandatory food safety checklists'),
                      const _FlowStepTile(step: '3', title: 'FastAPI AI Smart Donor-NGO Matching Engine', subtitle: 'Real-time match priority score calculation based on distance & expiry'),
                      const _FlowStepTile(step: '4', title: 'Volunteer Delivery & SHA-256 QR Chain of Custody', subtitle: '3D Turn-by-turn map navigation & cryptographic QR handover'),
                      const _FlowStepTile(step: '5', title: 'Unusable Food Upcycling (Biogas / Compost)', subtitle: '100% landfill diversion route for expired food waste'),
                      const _FlowStepTile(step: '6', title: 'Impact Dashboard & Corporate ESG Certificates', subtitle: 'Downloadable CSR carbon reduction compliance reports'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ONE-CLICK QUICK ROLE SWITCHER FOR JUDGES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('One-Click Demo Role Portal Access (For Judges)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _RoleDemoButton(role: 'Donor', icon: Icons.volunteer_activism_rounded, color: AppColors.primary, onTap: () => _quickDemoLogin(context, ref, 'Donor')),
                        _RoleDemoButton(role: 'NGO', icon: Icons.business_rounded, color: AppColors.success, onTap: () => _quickDemoLogin(context, ref, 'NGO')),
                        _RoleDemoButton(role: 'Volunteer', icon: Icons.directions_bike_rounded, color: Colors.purple, onTap: () => _quickDemoLogin(context, ref, 'Volunteer')),
                        _RoleDemoButton(role: 'Community Home Cook', icon: Icons.soup_kitchen_rounded, color: Colors.amber, onTap: () => _quickDemoLogin(context, ref, 'Community Home Cook')),
                        _RoleDemoButton(role: 'Admin', icon: Icons.admin_panel_settings_rounded, color: AppColors.error, onTap: () => _quickDemoLogin(context, ref, 'Admin')),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _FlowStepTile extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;

  const _FlowStepTile({required this.step, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(step, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleDemoButton extends StatelessWidget {
  final String role;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleDemoButton({required this.role, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withValues(alpha: 0.4)),
        ),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(role, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
