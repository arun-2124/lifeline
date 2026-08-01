import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';

class RoleSelectorWidget extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleSelected;

  static const List<Map<String, dynamic>> roles = [
    {'title': 'Donor', 'icon': Icons.volunteer_activism, 'subtitle': 'Donate food & supplies'},
    {'title': 'Community Home Cook', 'icon': Icons.soup_kitchen_rounded, 'subtitle': 'Share home-cooked meals'},
    {'title': 'NGO', 'icon': Icons.business, 'subtitle': 'Distribute to those in need'},
    {'title': 'Volunteer', 'icon': Icons.handshake, 'subtitle': 'Assist in ground operations'},
    {'title': 'Delivery Partner', 'icon': Icons.local_shipping, 'subtitle': 'Transport food packages'},
    {'title': 'Beneficiary', 'icon': Icons.person_pin, 'subtitle': 'Receive food assistance'},
  ];

  const RoleSelectorWidget({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Role',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: roles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final role = roles[index];
            final title = role['title'] as String;
            final isSelected = selectedRole == title;

            return InkWell(
              onTap: () => onRoleSelected(title),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : const Color(0xFFDEE2E6),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      role['icon'] as IconData,
                      color: isSelected ? AppColors.primary : AppColors.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            role['subtitle'] as String,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.primary : AppColors.secondary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
