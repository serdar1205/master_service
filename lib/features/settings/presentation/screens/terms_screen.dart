import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/app_error_view.dart';
import '../../../../core/utils/app_status.dart';
import '../../../../core/utils/html_content_sanitizer.dart';
import '../../application/app_settings_cubit.dart';
import '../../domain/app_settings_repository.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key, required this.repository});

  final AppSettingsRepository repository;

  static const _brandColor = AppColors.brand;

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  late final AppSettingsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AppSettingsCubit(widget.repository)..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _cubit, child: const _TermsView());
  }
}

class _TermsView extends StatelessWidget {
  const _TermsView();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: TermsScreen._brandColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(localizations.text('termsTitle')),
      ),
      body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, state) {
          if (state.status == AppStatus.loading && state.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AppStatus.failure && state.data == null) {
            return AppErrorView(
              message:
                  state.errorMessage ?? localizations.text('termsLoadError'),
              onRetry: () => context.read<AppSettingsCubit>().load(),
            );
          }

          final content = state.data?.content.trim() ?? '';
          if (content.isEmpty) {
            return AppErrorView(
              message: localizations.text('termsEmpty'),
              onRetry: () => context.read<AppSettingsCubit>().load(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE7EEF0)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                child: Html(
                  data: sanitizeHtmlForDisplay(content),
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(15),
                      lineHeight: const LineHeight(1.5),
                      color: const Color(0xFF242B2F),
                    ),
                    'h1': Style(
                      fontSize: FontSize(22),
                      fontWeight: FontWeight.w700,
                      margin: Margins.only(bottom: 12),
                      color: TermsScreen._brandColor,
                    ),
                    'h2': Style(
                      fontSize: FontSize(18),
                      fontWeight: FontWeight.w700,
                      margin: Margins.only(top: 8, bottom: 8),
                      color: const Color(0xFF172025),
                    ),
                    'p': Style(margin: Margins.only(bottom: 10)),
                    'ul': Style(margin: Margins.only(bottom: 10)),
                    'ol': Style(margin: Margins.only(bottom: 10)),
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
