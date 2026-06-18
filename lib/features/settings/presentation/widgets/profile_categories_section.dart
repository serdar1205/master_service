import 'package:flutter/material.dart';

import '../../../categories/domain/service_category.dart';
import '../../../categories/presentation/widgets/category_icon.dart';
import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';

class ProfileCategoriesSection extends StatefulWidget {
  const ProfileCategoriesSection({
    required this.localizations,
    required this.categories,
    this.collapsedPreviewCount = 2,
    super.key,
  });

  final AppLocalizations localizations;
  final List<ServiceCategory> categories;
  final int collapsedPreviewCount;

  @override
  State<ProfileCategoriesSection> createState() =>
      _ProfileCategoriesSectionState();
}

class _ProfileCategoriesSectionState extends State<ProfileCategoriesSection> {
  static const _brandColor = AppColors.brand;

  bool _expanded = false;

  static const _accentColors = <Color>[
    Color(0xFFEAF3FF),
    Color(0xFFE5FCF8),
    Color(0xFFEFF5FF),
    Color(0xFFE6FAF8),
    Color(0xFFEAFBFF),
    Color(0xFFE3F3F3),
  ];

  static const _iconColors = <Color>[
    Color(0xFF4F79A3),
    _brandColor,
    Color(0xFF2F79A7),
    Color(0xFF4290A3),
    Color(0xFF3B629B),
    Color(0xFF4777A6),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final canExpand = widget.categories.length > widget.collapsedPreviewCount;
    final visibleCategories = _expanded || !canExpand
        ? widget.categories
        : widget.categories.take(widget.collapsedPreviewCount).toList();
    final hiddenCount = widget.categories.length - visibleCategories.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EEF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: canExpand
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      color: _brandColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.localizations.text('categorySetupTitle'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF242B2F),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE1E7E9)),
                    ),
                    child: Text(
                      '${widget.categories.length}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _brandColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (canExpand) ...[
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF849198),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                if (_expanded || !canExpand)
                  ...List.generate(visibleCategories.length, (index) {
                    final category = visibleCategories[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == visibleCategories.length - 1 ? 0 : 8,
                      ),
                      child: _CategoryRow(
                        category: category,
                        backgroundColor:
                            _accentColors[index % _accentColors.length],
                        iconColor: _iconColors[index % _iconColors.length],
                      ),
                    );
                  })
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: [
                      ...visibleCategories.map(
                        (category) => _CategoryChip(category: category),
                      ),
                      if (hiddenCount > 0)
                        _MoreCategoriesChip(
                          label: widget.localizations
                              .text('categoriesMoreCount')
                              .replaceAll('{count}', '$hiddenCount'),
                          onTap: () => setState(() => _expanded = true),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          if (canExpand && _expanded) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _expanded = false),
              style: TextButton.styleFrom(
                foregroundColor: _brandColor,
                textStyle: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              child: Text(widget.localizations.text('showLessCategories')),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.backgroundColor,
    required this.iconColor,
  });

  final ServiceCategory category;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9F0F2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CategoryIcon(
                category: category,
                size: 20,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFF242B2F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(
            Icons.verified_outlined,
            color: Color(0xFFBCC9CD),
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final ServiceCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE5E7)),
      ),
      child: Text(
        category.name,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: const Color(0xFF4F79A3),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MoreCategoriesChip extends StatelessWidget {
  const _MoreCategoriesChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAF3FF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.brand,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.brand,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
