import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class AdminAuditLogScreen extends ConsumerStatefulWidget {
  const AdminAuditLogScreen({super.key});

  @override
  ConsumerState<AdminAuditLogScreen> createState() => _AdminAuditLogScreenState();
}

class _AdminAuditLogScreenState extends ConsumerState<AdminAuditLogScreen> {
  String _selectedTab = 'Security Logs'; // Security Logs, AI Health, System Reports

  void _exportReport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating & Exporting System Audit Report ($format format)...'),
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
          'Admin AI & Audit Control Center',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Audit Reports',
            onSelected: _exportReport,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'CSV', child: Text('Export CSV Report')),
              const PopupMenuItem(value: 'EXCEL', child: Text('Export Excel Sheet')),
              const PopupMenuItem(value: 'PDF', child: Text('Export PDF Document')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SYSTEM METRICS SUMMARY CARDS
            Row(
              children: [
                Expanded(child: _AdminMetricTile(title: 'Total Users', value: '12,450', color: AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(child: _AdminMetricTile(title: 'Meals Rescued', value: '345,000', color: AppColors.success)),
                const SizedBox(width: 8),
                Expanded(child: _AdminMetricTile(title: 'CO₂ Prevented', value: '14.8 Tons', color: Colors.amber)),
                const SizedBox(width: 8),
                Expanded(child: _AdminMetricTile(title: 'AI Accuracy', value: '98.4%', color: AppColors.info)),
              ],
            ),

            const SizedBox(height: 20),

            // TAB SELECTOR
            Row(
              children: ['Security Logs', 'AI Health', 'System Reports'].map((tab) {
                final isSelected = _selectedTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tab),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold),
                    onSelected: (_) => setState(() => _selectedTab = tab),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // CONTENT BASED ON SELECTED TAB
            if (_selectedTab == 'Security Logs') ...[
              const Text('Security Audit & Fraud Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              const _AuditLogRow(
                title: 'DUPLICATE_SCAN Blocked',
                subtitle: 'Attempted QR replay attack blocked on Donation #DONATION_987654',
                time: '12 mins ago',
                status: 'BLOCKED',
                color: AppColors.error,
              ),
              const _AuditLogRow(
                title: 'Role Upgrade Verified',
                subtitle: 'Home Cook User upgrade approved to Level 3 Trusted Home Cook',
                time: '45 mins ago',
                status: 'VERIFIED',
                color: AppColors.success,
              ),
              const _AuditLogRow(
                title: 'Payout Withdrawal Approved',
                subtitle: '₹900 withdrawal approved for Delivery Partner Rahul V.',
                time: '2 hours ago',
                status: 'COMPLETED',
                color: AppColors.primary,
              ),
            ] else if (_selectedTab == 'AI Health') ...[
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FastAPI AI Microservices Health', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    const _AiModuleHealthRow(name: 'Smart Donor-NGO Matching Engine', status: 'ONLINE', latency: '42ms', score: '98.6%'),
                    const Divider(height: 16),
                    const _AiModuleHealthRow(name: 'Food Demand Forecasting Model', status: 'ONLINE', latency: '65ms', score: '96.2%'),
                    const Divider(height: 16),
                    const _AiModuleHealthRow(name: 'OR-Tools Route Optimization', status: 'ONLINE', latency: '88ms', score: '99.1%'),
                    const Divider(height: 16),
                    const _AiModuleHealthRow(name: 'AI Fraud Anomaly Detector', status: 'ONLINE', latency: '35ms', score: '99.8%'),
                  ],
                ),
              ),
            ] else ...[
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Exportable System Compliance Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error),
                      title: const Text('Monthly CSR Sustainability & Carbon Impact Report'),
                      trailing: IconButton(
                        icon: const Icon(Icons.download_rounded),
                        onPressed: () => _exportReport('PDF'),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.table_chart_rounded, color: AppColors.success),
                      title: const Text('Financial Transactions & Delivery Earnings Ledger'),
                      trailing: IconButton(
                        icon: const Icon(Icons.download_rounded),
                        onPressed: () => _exportReport('EXCEL'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdminMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _AdminMetricTile({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(10),
      borderRadius: 14,
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary), textAlign: TextAlign.center, maxLines: 1),
        ],
      ),
    );
  }
}

class _AuditLogRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String status;
  final Color color;

  const _AuditLogRow({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.security_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}

class _AiModuleHealthRow extends StatelessWidget {
  final String name;
  final String status;
  final String latency;
  final String score;

  const _AiModuleHealthRow({required this.name, required this.status, required this.latency, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text('Latency: $latency • Accuracy: $score', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success)),
        ),
      ],
    );
  }
}
