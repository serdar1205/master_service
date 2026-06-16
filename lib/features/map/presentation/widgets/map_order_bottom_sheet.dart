import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_repositories.dart';
import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/app_error_view.dart';
import '../../../../core/utils/app_status.dart';
import '../../../jobs/application/job_details_cubit.dart';
import '../../../jobs/presentation/widgets/order_details_info_card.dart';

class MapOrderBottomSheet extends StatelessWidget {
  const MapOrderBottomSheet({
    super.key,
    required this.orderId,
    required this.actionKey,
  });

  final String orderId;
  final String actionKey;

  static Future<void> show(
    BuildContext context, {
    required String orderId,
    required String actionKey,
  }) {
    final repositories = AppRepositoriesScope.of(context);

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider(
        create: (_) =>
            JobDetailsCubit(repositories.ordersRepository)..load(orderId),
        child: MapOrderBottomSheet(orderId: orderId, actionKey: actionKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return BlocBuilder<JobDetailsCubit, JobDetailsState>(
      builder: (context, state) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  localizations.text('orderNumber').replaceAll('{id}', orderId),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.brand,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                if (state.status == AppStatus.loading && state.data == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.status == AppStatus.failure &&
                    state.data == null)
                  AppErrorView(
                    message:
                        state.errorMessage ??
                        localizations.text('errorDefaultMessage'),
                    onRetry: () =>
                        context.read<JobDetailsCubit>().load(orderId),
                  )
                else if (state.data != null) ...[
                  OrderDetailsInfoCard(
                    details: state.data!,
                    localizations: localizations,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(AppRoutes.jobDetailsPath(orderId));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.buttonTeal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(localizations.text(actionKey)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
