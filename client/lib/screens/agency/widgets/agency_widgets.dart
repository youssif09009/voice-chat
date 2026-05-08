/// Shared widgets — professional dark theme.
library;

import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';

// ── Shared card decoration ────────────────────────────────────────────────────
BoxDecoration kCardDecoration({Color? borderColor, Color? bg}) => BoxDecoration(
  color: bg ?? AppColors.surface,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: borderColor ?? AppColors.border, width: 1),
);

// ---------------------------------------------------------------------------
// Stat card
// ---------------------------------------------------------------------------

class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primaryPurple,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: kCardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          if (subtitle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(subtitle!,
                  style: AppTypography.micro.copyWith(color: color)),
            ),
        ]),
        const SizedBox(height: 14),
        Text(value, style: AppTypography.labelLarge),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.labelSmall),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Target row
// ---------------------------------------------------------------------------

class TargetRow extends StatelessWidget {
  final String metric;
  final double current, goal;
  final int progress;
  final Color color;

  const TargetRow({
    super.key,
    required this.metric,
    required this.current,
    required this.goal,
    required this.progress,
    this.color = AppColors.primaryPurple,
  });

  String get _label {
    switch (metric) {
      case 'invites':        return 'Invites';
      case 'active_hours':   return 'Active Hours';
      case 'coins_earned':   return 'Coins Earned';
      case 'gifts_received': return 'Gifts Received';
      default:               return metric;
    }
  }

  String get _emoji {
    switch (metric) {
      case 'invites':        return '👥';
      case 'active_hours':   return '⏱️';
      case 'coins_earned':   return '🪙';
      case 'gifts_received': return '🎁';
      default:               return '🎯';
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = progress >= 100;
    final barColor = done ? AppColors.green : color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: kCardDecoration(
          borderColor: done
              ? AppColors.green.withValues(alpha: 0.3)
              : AppColors.border),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(_emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(child: Text(_label, style: AppTypography.h3)),
          Text(
            '${current.toStringAsFixed(current == current.roundToDouble() ? 0 : 1)}'
            ' / ${goal.toStringAsFixed(goal == goal.roundToDouble() ? 0 : 1)}',
            style: AppTypography.labelSmall,
          ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            done ? '✅  Completed!' : '$progress% complete',
            style: AppTypography.caption.copyWith(
                color: done ? AppColors.green : AppColors.textHint),
          ),
          if (!done)
            Text(
              '${(goal - current).clamp(0, goal).toStringAsFixed(0)} remaining',
              style: AppTypography.caption,
            ),
        ]),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
      child: Row(children: [
        Text(title, style: AppTypography.h2),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w600)),
          ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  Color get _color {
    switch (status) {
      case 'active':               return AppColors.green;
      case 'pending':              return AppColors.amber;
      case 'suspended':
      case 'banned':               return AppColors.red;
      default:                     return AppColors.textSecondary;
    }
  }

  String get _label {
    switch (status) {
      case 'active':    return 'Active';
      case 'pending':   return 'Pending';
      case 'suspended': return 'Suspended';
      case 'banned':    return 'Banned';
      default:          return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(_label,
          style: AppTypography.micro.copyWith(
              color: _color, fontWeight: FontWeight.w700)),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading / error states
// ---------------------------------------------------------------------------

class LoadingPane extends StatelessWidget {
  const LoadingPane({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: 36, height: 36,
        child: CircularProgressIndicator(
          color: AppColors.primaryPurple,
          strokeWidth: 3,
          backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.15),
        ),
      ),
      const SizedBox(height: 16),
      Text('Loading…', style: AppTypography.bodySmall),
    ]),
  );
}

class ErrorPane extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorPane({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.red.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline_rounded,
              color: AppColors.red, size: 32),
        ),
        const SizedBox(height: 16),
        Text('Something went wrong', style: AppTypography.h3),
        const SizedBox(height: 6),
        Text(message, style: AppTypography.bodySmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text('Try Again', style: AppTypography.buttonSmall),
          ),
        ),
      ]),
    ));
  }
}

// ---------------------------------------------------------------------------
// Gradient button
// ---------------------------------------------------------------------------

class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool loading;
  final List<Color> colors;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.loading = false,
    this.colors = const [AppColors.primaryPurple, AppColors.pink],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(child: loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(label, style: AppTypography.button),
              ])),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Leaderboard row
// ---------------------------------------------------------------------------

class LeaderboardRow extends StatelessWidget {
  final int rank;
  final String username, primaryValue, primaryLabel,
      secondaryValue, secondaryLabel;

  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.username,
    required this.primaryValue,
    required this.primaryLabel,
    required this.secondaryValue,
    required this.secondaryLabel,
  });

  Color get _rankColor {
    if (rank == 1) return AppColors.gold;
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.textHint;
  }

  String get _rankLabel {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  @override
  Widget build(BuildContext context) {
    final isTop = rank <= 3;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: kCardDecoration(
          borderColor: isTop
              ? _rankColor.withValues(alpha: 0.35)
              : AppColors.border),
      child: Row(children: [
        SizedBox(
          width: 40,
          child: Text(_rankLabel,
              style: TextStyle(
                  color: _rankColor,
                  fontSize: isTop ? 20 : 13,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(username, style: AppTypography.labelMedium)),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(primaryValue, style: AppTypography.labelMedium),
          const SizedBox(height: 2),
          Text(primaryLabel, style: AppTypography.caption),
        ]),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(secondaryValue,
              style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primaryPurple)),
          const SizedBox(height: 2),
          Text(secondaryLabel, style: AppTypography.caption),
        ]),
      ]),
    );
  }
}
