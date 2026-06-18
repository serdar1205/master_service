import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../data/order_mapper.dart';
import '../../domain/order_models.dart';

class OrderDetailsInfoCard extends StatelessWidget {
  const OrderDetailsInfoCard({
    required this.details,
    required this.localizations,
    super.key,
  });

  final JobDetailsData details;
  final AppLocalizations localizations;

  static const _brandColor = AppColors.brand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5E7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (details.category.isNotEmpty)
                _CategoryPill(label: details.category),
              if (details.category.isNotEmpty) const SizedBox(width: 8),
              _StatusPill(label: localizations.text(details.statusKey)),
            ],
          ),
          if (details.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              details.description,
              style: theme.bodyLarge?.copyWith(
                color: const Color(0xFF11191C),
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.person_outline,
            label: localizations.text('customer'),
            value: details.clientName,
          ),
          if (details.clientPhone.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: localizations.text('phoneNumber'),
              value: details.clientPhone,
              onTap: () => PhoneLauncher.call(
                context,
                details.clientPhone,
                unavailableMessage: localizations.text('phoneUnavailable'),
                failedMessage: localizations.text('callFailed'),
              ),
            ),
          ],
          if (details.address.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: localizations.text('address'),
              value: details.address,
            ),
          ],
          if (details.finalPriceText != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAFBFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    color: _brandColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localizations.text('finalPrice'),
                    style: theme.labelLarge?.copyWith(
                      color: const Color(0xFF4290A3),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    details.finalPriceText!,
                    style: theme.titleMedium?.copyWith(
                      color: _brandColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          _TimelineSection(details: details, localizations: localizations),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.details, required this.localizations});

  final JobDetailsData details;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final entries = <({String label, String value})>[
      if (details.createdAt != null && details.createdAt!.isNotEmpty)
        (
          label: localizations.text('orderCreatedAt'),
          value: OrderMapper.formatDisplayDate(details.createdAt),
        ),
      if (details.assignedAt != null && details.assignedAt!.isNotEmpty)
        (
          label: localizations.text('orderAssignedAt'),
          value: OrderMapper.formatDisplayDate(details.assignedAt),
        ),
      if (details.startedAt != null && details.startedAt!.isNotEmpty)
        (
          label: localizations.text('orderStartedAt'),
          value: OrderMapper.formatDisplayDate(details.startedAt),
        ),
      if (details.completedAt != null && details.completedAt!.isNotEmpty)
        (
          label: localizations.text('orderCompletedAt'),
          value: OrderMapper.formatDisplayDate(details.completedAt),
        ),
    ];

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.text('orderTimeline'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFF526168),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < entries.length; i++) ...[
          _TimelineRow(label: entries[i].label, value: entries[i].value),
          if (i != entries.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.schedule_outlined, size: 16, color: Color(0xFF6D7A82)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF526168),
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6D7A82)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF8A969C),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onTap == null
                      ? const Color(0xFF293237)
                      : AppColors.brand,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  decoration: onTap == null ? null : TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          const Icon(Icons.call_outlined, size: 18, color: AppColors.brand),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAFBFF),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF4290A3),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE7FBF5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF426A63),
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}
