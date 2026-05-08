/// Shared tab helpers — dark theme.
library;

import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';

// ── Filter bar ────────────────────────────────────────────────────────────────

class TabFilterBar extends StatelessWidget {
  final List<String?> options;
  final List<String> labels;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const TabFilterBar({
    super.key,
    required this.options,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SizedBox(
        height: 34,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: options.length,
          itemBuilder: (_, i) {
            final sel = selected == options[i];
            return GestureDetector(
              onTap: () => onSelect(options[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primaryPurple
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                      color: sel
                          ? AppColors.primaryPurple
                          : AppColors.border,
                      width: 1),
                ),
                child: Text(labels[i],
                    style: AppTypography.labelSmall.copyWith(
                      color: sel
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                    )),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Quick stats row ───────────────────────────────────────────────────────────

class QuickStatItem {
  final String label, value;
  final Color color;
  const QuickStatItem(this.label, this.value, this.color);
}

class QuickStatsRow extends StatelessWidget {
  final List<QuickStatItem> items;
  const QuickStatsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: items.map((item) => Expanded(
          child: Column(children: [
            Text(item.value,
                style: AppTypography.labelMedium.copyWith(color: item.color)),
            const SizedBox(height: 2),
            Text(item.label, style: AppTypography.caption),
          ]),
        )).toList(),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class TabEmpty extends StatelessWidget {
  final String label;
  const TabEmpty({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.inbox_outlined,
              color: AppColors.primaryPurple, size: 32),
        ),
        const SizedBox(height: 16),
        Text(label, style: AppTypography.h3),
        const SizedBox(height: 6),
        Text('Nothing to show here yet', style: AppTypography.bodySmall),
      ]),
    );
  }
}
