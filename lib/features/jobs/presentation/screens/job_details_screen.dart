import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/localization/locale_cubit.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/media/image_pick_service.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/app_status.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../../../app/widgets/app_error_view.dart';
import '../../../../app/widgets/app_refresh_indicator.dart';
import '../../../../app/di/app_repositories.dart';
import '../../application/job_details_cubit.dart';
import '../../domain/order_models.dart';
import '../widgets/my_tasks_section.dart';
import '../widgets/order_details_info_card.dart';

const _brandColor = AppColors.brand;
const _buttonColor = AppColors.buttonTeal;

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final jobId = GoRouterState.of(context).pathParameters['jobId'] ?? 'job-2';

    final repositories = AppRepositoriesScope.of(context);

    return BlocProvider(
      create: (_) =>
          JobDetailsCubit(repositories.ordersRepository)..load(jobId),
      child: _JobDetailsContent(localizations: localizations, jobId: jobId),
    );
  }
}

class _JobDetailsContent extends StatefulWidget {
  const _JobDetailsContent({required this.localizations, required this.jobId});

  final AppLocalizations localizations;
  final String jobId;

  @override
  State<_JobDetailsContent> createState() => _JobDetailsContentState();
}

class _JobDetailsContentState extends State<_JobDetailsContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recoverLostImagePick();
    });
  }

  Future<void> _recoverLostImagePick() async {
    await ImagePickService.recoverLostData(
      onRecovered: (path) {
        if (!mounted) {
          return;
        }

        context.read<JobDetailsCubit>().addRecoveredTaskPhoto(path);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = widget.localizations;
    final jobId = widget.jobId;

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBFB),
      body: SafeArea(
        child: Column(
          children: [
            _DetailsHeader(localizations: localizations),
            Expanded(
              child: BlocBuilder<JobDetailsCubit, JobDetailsState>(
                builder: (context, state) {
                  Future<void> refreshDetails() =>
                      context.read<JobDetailsCubit>().load(jobId);

                  if (state.status == AppStatus.loading && state.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == AppStatus.failure) {
                    return AppRefreshableBody(
                      onRefresh: refreshDetails,
                      child: AppErrorView(
                        message:
                            state.errorMessage ??
                            localizations.text('errorDefaultMessage'),
                        onRetry: refreshDetails,
                      ),
                    );
                  }

                  final details = state.data;
                  if (details == null) {
                    return const SizedBox.shrink();
                  }

                  return AppRefreshIndicator(
                    onRefresh: refreshDetails,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      children: [
                        OrderDetailsInfoCard(
                          details: details,
                          localizations: localizations,
                        ),
                        const SizedBox(height: 18),
                        MyTasksSection(
                          tasks: details.tasks,
                          canEdit: details.isInProgress,
                          localizations: localizations,
                        ),
                        if (details.isInProgress) ...[
                          const SizedBox(height: 18),
                          _PriceConfirmationCard(
                            localizations: localizations,
                            details: details,
                          ),
                          const SizedBox(height: 20),
                          _CompletionNote(localizations: localizations),
                          const SizedBox(height: 14),
                          if (state.errorMessage != null) ...[
                            Text(
                              state.errorMessage!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 10),
                          ],
                          FilledButton.icon(
                            onPressed: state.isSubmitting
                                ? null
                                : () => _completeOrder(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: _buttonColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(localizations.text('complete')),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeOrder(BuildContext context) async {
    final cubit = context.read<JobDetailsCubit>();
    final completed = await cubit.completeOrder();
    if (!context.mounted) {
      return;
    }

    if (completed && context.mounted) {
      AppRepositoriesScope.of(
        context,
      ).ordersListRefreshNotifier.requestRefresh();
      context.go(AppRoutes.jobs);
    }
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobDetailsCubit, JobDetailsState>(
      builder: (context, state) {
        final orderId = state.data?.id;
        final title = orderId == null
            ? localizations.text('completeOrderTitle')
            : localizations.text('orderNumber').replaceAll('{id}', orderId);

        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (GoRouter.of(context).canPop()) {
                    context.pop();
                    return;
                  }

                  context.go(AppRoutes.jobs);
                },
                icon: const Icon(Icons.arrow_back, color: _brandColor),
              ),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _brandColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (state.data != null)
                _StatusChip(label: localizations.text(state.data!.statusKey))
              else
                const _LocaleBadgeChip(),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE7FBF5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: const Color(0xFF426A63),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LocaleBadgeChip extends StatelessWidget {
  const _LocaleBadgeChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined, color: _brandColor, size: 15),
          const SizedBox(width: 4),
          BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, state) {
              final label = state.locale.languageCode == 'ru' ? 'RU' : 'TM';

              return Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF5D686E),
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PriceConfirmationCard extends StatelessWidget {
  const _PriceConfirmationCard({
    required this.localizations,
    required this.details,
  });

  final AppLocalizations localizations;
  final JobDetailsData details;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F3F3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB5D9DA)),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFBFE7E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: _brandColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.text('priceConfirmation'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _brandColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (details.finalPriceText != null) ...[
            const SizedBox(height: 10),
            Text(
              details.finalPriceText!,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: _brandColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            localizations.text('priceConfirmationDescription'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF293237),
              height: 1.42,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => PhoneLauncher.call(
              context,
              AppConfig.supportPhone,
              unavailableMessage: localizations.text('phoneUnavailable'),
              failedMessage: localizations.text('callFailed'),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            icon: const Icon(Icons.phone_outlined),
            label: Text(localizations.text('callOperator')),
          ),
        ],
      ),
    );
  }
}

class _CompletionNote extends StatelessWidget {
  const _CompletionNote({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Text(
      localizations.text('completionNote'),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: const Color(0xFF7A868C),
        height: 1.55,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
