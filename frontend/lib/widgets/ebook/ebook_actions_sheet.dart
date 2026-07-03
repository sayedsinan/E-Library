import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class EbookActionsSheet extends StatelessWidget {
  final String title;
  final VoidCallback onRead;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const EbookActionsSheet({
    super.key,
    required this.title,
    required this.onRead,
    required this.onDownload,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required VoidCallback onRead,
    required VoidCallback onDownload,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (ctx) => EbookActionsSheet(
        title: title,
        onRead: () {
          Navigator.pop(ctx);
          onRead();
        },
        onDownload: () {
          Navigator.pop(ctx);
          onDownload();
        },
        onDelete: () {
          Navigator.pop(ctx);
          onDelete();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _ActionTile(
              icon: Icons.menu_book_rounded,
              label: 'Read',
              color: AppColors.primary,
              onTap: onRead,
            ),
            _ActionTile(
              icon: Icons.download_rounded,
              label: 'Download',
              color: AppColors.accent,
              onTap: onDownload,
            ),
            _ActionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: AppColors.error,
              onTap: onDelete,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
