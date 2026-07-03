import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/ebook_provider.dart';

class SortFilterBar extends StatelessWidget {
  final SortOrder sortOrder;
  final FileTypeFilter fileTypeFilter;
  final ValueChanged<SortOrder> onSortChanged;
  final ValueChanged<FileTypeFilter> onFilterChanged;

  const SortFilterBar({
    super.key,
    required this.sortOrder,
    required this.fileTypeFilter,
    required this.onSortChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _SortChip(
            label: 'Newest',
            selected: sortOrder == SortOrder.newest,
            icon: Icons.arrow_downward_rounded,
            onTap: () => onSortChanged(SortOrder.newest),
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: 'Oldest',
            selected: sortOrder == SortOrder.oldest,
            icon: Icons.arrow_upward_rounded,
            onTap: () => onSortChanged(SortOrder.oldest),
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: 'Title A–Z',
            selected: sortOrder == SortOrder.titleAZ,
            icon: Icons.sort_by_alpha_rounded,
            onTap: () => onSortChanged(SortOrder.titleAZ),
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: 'Author A–Z',
            selected: sortOrder == SortOrder.authorAZ,
            icon: Icons.person_outline_rounded,
            onTap: () => onSortChanged(SortOrder.authorAZ),
          ),
          const SizedBox(width: 12),
          const _Divider(),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'All',
            selected: fileTypeFilter == FileTypeFilter.all,
            onTap: () => onFilterChanged(FileTypeFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'PDF',
            selected: fileTypeFilter == FileTypeFilter.pdf,
            color: const Color(0xFFBF360C),
            onTap: () => onFilterChanged(FileTypeFilter.pdf),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'EPUB',
            selected: fileTypeFilter == FileTypeFilter.epub,
            color: const Color(0xFF01579B),
            onTap: () => onFilterChanged(FileTypeFilter.epub),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.accentLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? activeColor.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : AppColors.accentLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? activeColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.accentLight,
    );
  }
}
