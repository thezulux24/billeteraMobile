import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/widgets/glass_text_field.dart';
import 'package:mobile/shared/widgets/glass_button.dart';
import 'package:mobile/features/categories/providers/category_notifier.dart';
import 'package:mobile/features/categories/models/category.dart';

class AddCategoryBottomSheet extends ConsumerStatefulWidget {
  final CategoryKind kind;

  const AddCategoryBottomSheet({super.key, required this.kind});

  @override
  ConsumerState<AddCategoryBottomSheet> createState() =>
      _AddCategoryBottomSheetState();
}

class _AddCategoryBottomSheetState
    extends ConsumerState<AddCategoryBottomSheet> {
  final _nameController = TextEditingController();
  Color _selectedColor = const Color(0xff4f46e5);
  String _selectedIcon = 'category';

  final List<Color> _presetColors = [
    const Color(0xffef4444), // Red
    const Color(0xfff59e0b), // Amber
    const Color(0xff10b981), // Emerald
    const Color(0xff3b82f6), // Blue
    const Color(0xff6366f1), // Indigo
    const Color(0xff8b5cf6), // Violet
    const Color(0xffec4899), // Pink
    const Color(0xff64748b), // Slate
  ];

  final List<Map<String, dynamic>> _presetIcons = [
    {'name': 'category', 'icon': Icons.category_rounded},
    {'name': 'shopping', 'icon': Icons.shopping_bag_rounded},
    {'name': 'food', 'icon': Icons.restaurant_rounded},
    {'name': 'transport', 'icon': Icons.directions_car_rounded},
    {'name': 'home', 'icon': Icons.home_rounded},
    {'name': 'health', 'icon': Icons.medical_services_rounded},
    {'name': 'entertainment', 'icon': Icons.confirmation_number_rounded},
    {'name': 'other', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    final success = await ref
        .read(categoryNotifierProvider)
        .createCategory(
          name: name,
          kind: widget.kind,
          color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
          icon: _selectedIcon,
        );

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        final error = ref.read(categoryNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create category: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.5)
            : Colors.white.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Category',
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: onSurface.withOpacity(0.5),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GlassTextField(
                  controller: _nameController,
                  label: 'Category Name',
                  isPremium: true,
                  prefixIcon: Icons.label_important_rounded,
                ),
                const SizedBox(height: 24),

                // Color Picker
                Text(
                  'Color',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetColors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final color = _presetColors[index];
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? onSurface
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Icon Picker
                Text(
                  'Icon',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetIcons.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = _presetIcons[index];
                      final isSelected = _selectedIcon == item['name'];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedIcon = item['name']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _selectedColor
                                : onSurface.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item['icon'],
                            color: isSelected
                                ? Colors.white
                                : onSurface.withOpacity(0.4),
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                GlassButton(
                  label: 'Create Category',
                  isPremium: true,
                  onPressed: _createCategory,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
