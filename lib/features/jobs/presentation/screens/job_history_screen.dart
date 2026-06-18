import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_repositories.dart';
import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/widgets/app_empty_view.dart';
import '../../../../app/widgets/app_error_view.dart';
import '../../../../app/widgets/app_refresh_indicator.dart';
import '../../../../core/utils/app_status.dart';
import '../../domain/order_models.dart';
import '../../domain/orders_repository.dart';

class JobHistoryScreen extends StatelessWidget {
  const JobHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final repositories = AppRepositoriesScope.of(context);

    return BlocProvider(
      create: (_) => _HistoryCubit(repositories.ordersRepository)..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(localizations.text('history'))),
        body: BlocBuilder<_HistoryCubit, _HistoryState>(
          builder: (context, state) {
            Future<void> refreshHistory() =>
                context.read<_HistoryCubit>().load();

            if (state.status == AppStatus.loading && state.jobs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == AppStatus.failure) {
              return AppRefreshableBody(
                onRefresh: refreshHistory,
                child: AppErrorView(
                  message:
                      state.errorMessage ??
                      localizations.text('errorDefaultMessage'),
                  onRetry: refreshHistory,
                ),
              );
            }

            final jobs = state.jobs;
            if (jobs.isEmpty) {
              return AppRefreshableBody(
                onRefresh: refreshHistory,
                child: AppEmptyView(
                  title: localizations.text('emptyHistoryTitle'),
                  message: localizations.text('emptyHistoryMessage'),
                  icon: Icons.history_rounded,
                ),
              );
            }

            return AppRefreshIndicator(
              onRefresh: refreshHistory,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: jobs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFD7E0E3)),
                    ),
                    title: Text(job.title),
                    subtitle: Text('${job.category} • ${job.address}'),
                    trailing: Text(job.distanceText),
                    onTap: () => context.go(AppRoutes.jobDetailsPath(job.id)),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryState {
  const _HistoryState({
    required this.status,
    this.jobs = const [],
    this.errorMessage,
  });

  const _HistoryState.initial() : this(status: AppStatus.idle);

  final AppStatus status;
  final List<JobListItem> jobs;
  final String? errorMessage;

  _HistoryState copyWith({
    AppStatus? status,
    List<JobListItem>? jobs,
    String? errorMessage,
  }) {
    return _HistoryState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class _HistoryCubit extends Cubit<_HistoryState> {
  _HistoryCubit(this._repository) : super(const _HistoryState.initial());

  final OrdersRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final jobs = await _repository.fetchHistory();
      emit(state.copyWith(status: AppStatus.success, jobs: jobs));
    } on Object {
      emit(state.copyWith(status: AppStatus.failure));
    }
  }
}
