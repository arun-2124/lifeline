import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/custom_button.dart';

class FilterBottomSheetWidget extends ConsumerStatefulWidget {
  const FilterBottomSheetWidget({super.key});

  @override
  ConsumerState<FilterBottomSheetWidget> createState() => _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends ConsumerState<FilterBottomSheetWidget> {
  late String _selectedCategory;
  late String _selectedFoodType;

  final List<Map<String, String>> _categories = [
    {'value': 'All', 'label': 'All Categories'},
    {'value': 'cooked_meal', 'label': 'Cooked Meals'},
    {'value': 'produce', 'label': 'Fresh Produce'},
    {'value': 'bakery', 'label': 'Bakery Items'},
    {'value': 'dairy', 'label': 'Dairy Products'},
    {'value': 'packaged', 'label': 'Packaged Food'},
    {'value': 'beverages', 'label': 'Beverages'},
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(ngoNotifierProvider);
    _selectedCategory = state.categoryFilter;
    _selectedFoodType = state.foodTypeFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Food Rescue Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Food Category',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat['value'];
              return ChoiceChip(
                label: Text(cat['label']!),
                selected: isSelected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategory = cat['value']!);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Dietary Preference',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['All', 'Veg', 'Non-Veg'].map((type) {
              final isSelected = _selectedFoodType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFoodType = type);
                    }
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'All';
                      _selectedFoodType = 'All';
                    });
                    ref.read(ngoNotifierProvider.notifier).setCategoryFilter('All');
                    ref.read(ngoNotifierProvider.notifier).setFoodTypeFilter('All');
                    Navigator.of(context).pop();
                  },
                  child: const Text('Reset Filters'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Apply Filters',
                  onPressed: () {
                    ref.read(ngoNotifierProvider.notifier).setCategoryFilter(_selectedCategory);
                    ref.read(ngoNotifierProvider.notifier).setFoodTypeFilter(_selectedFoodType);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
