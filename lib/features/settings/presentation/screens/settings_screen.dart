import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/app_error_view.dart';
import '../../../../app/widgets/app_refresh_indicator.dart';
import '../../../../app/widgets/locale_badge.dart';
import '../../../../app/widgets/locale_change_listener.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/app_status.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/application/auth_cubit.dart';
import '../../../../app/di/app_repositories.dart';
import '../../../categories/domain/service_category.dart';
import '../widgets/profile_categories_section.dart';
import '../../application/profile_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _brandColor = AppColors.brand;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final repositories = AppRepositoriesScope.of(context);

    return BlocProvider(
      create: (_) => ProfileCubit(repositories.profileRepository)..load(),
      child: Builder(
        builder: (context) {
          return LocaleChangeListener(
            onLocaleChanged: () => context.read<ProfileCubit>().load(),
            child: BlocListener<ProfileCubit, ProfileState>(
              listenWhen: (previous, current) =>
                  previous.errorMessage != current.errorMessage &&
                  current.errorMessage != null &&
                  !current.isUpdatingAvailability,
              listener: (context, state) {
                final message = state.errorMessage;
                if (message != null) {
                  AppToast.showError(message);
                }
              },
              child: Scaffold(
                backgroundColor: const Color(0xFFF4FBFB),
                body: SafeArea(
                  child: Column(
                    children: [
                      _ProfileHeader(localizations: localizations),
                      Expanded(
                        child: BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, state) {
                            Future<void> refreshProfile() =>
                                context.read<ProfileCubit>().load();

                            if (state.status == AppStatus.loading &&
                                state.data == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state.status == AppStatus.failure) {
                              return AppRefreshableBody(
                                onRefresh: refreshProfile,
                                child: AppErrorView(
                                  message:
                                      state.errorMessage ??
                                      localizations.text('errorDefaultMessage'),
                                  onRetry: refreshProfile,
                                ),
                              );
                            }

                            final profile = state.data;
                            if (profile == null) {
                              return const SizedBox.shrink();
                            }

                            return AppRefreshIndicator(
                              onRefresh: refreshProfile,
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  16,
                                ),
                                children: [
                                  _ProfileCard(
                                    localizations: localizations,
                                    fullName: profile.fullName,
                                    categories: profile.categories,
                                    onEditTap: () =>
                                        context.push(AppRoutes.editProfile),
                                  ),
                                  const SizedBox(height: 12),
                                  _AvailabilityCard(
                                    localizations: localizations,
                                    isAvailable: profile.isAvailable,
                                    isUpdating: state.isUpdatingAvailability,
                                    onChanged: (value) => context
                                        .read<ProfileCubit>()
                                        .setAvailability(value),
                                  ),
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 18),
                                    child: Text(
                                      localizations.text('accountSettings'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: const Color(0xFF9AA7AD),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 3.2,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _SettingsMenu(
                                    localizations: localizations,
                                    menuItemKeys: profile.menuItemKeys,
                                    onAccountTap: () =>
                                        context.push(AppRoutes.accountSettings),
                                    // onPaymentTap: () =>
                                    //     context.push(AppRoutes.paymentHistory),
                                    onSupportTap: () =>
                                        context.push(AppRoutes.supportCenter),
                                  ),
                                  const SizedBox(height: 18),
                                  _SignOutButton(localizations: localizations),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: SettingsScreen._brandColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizations.text('appTitle'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: SettingsScreen._brandColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const LocaleBadge(brandColor: SettingsScreen._brandColor),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.localizations,
    required this.fullName,
    required this.categories,
    required this.onEditTap,
  });

  final AppLocalizations localizations;
  final String fullName;
  final List<ServiceCategory> categories;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            right: 26,
            top: 0,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onEditTap,
                customBorder: const CircleBorder(),
                child: Ink(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE7EEF0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF9AA7AD),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              const _ProfileAvatar(),
              const SizedBox(height: 12),
              Text(
                fullName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF242B2F),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF849198),
                    size: 19,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    localizations.text('profileLocation'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF6D7A82),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ProfileCategoriesSection(
                localizations: localizations,
                categories: categories,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1F2933), Color(0xFF0B1117)],
            ),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 44),
        ),
        Positioned(
          right: 0,
          bottom: 6,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: SettingsScreen._brandColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.verified, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.localizations,
    required this.isAvailable,
    required this.isUpdating,
    required this.onChanged,
  });

  final AppLocalizations localizations;
  final bool isAvailable;
  final bool isUpdating;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SwitchListTile(
        value: isAvailable,
        onChanged: isUpdating ? null : onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: SettingsScreen._brandColor,
        title: Text(
          localizations.text('workAvailability'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF242B2F),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          localizations.text('workAvailabilityHint'),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A82)),
        ),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isAvailable
                ? const Color(0xFFE8F8F6)
                : const Color(0xFFF4F8F9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isAvailable ? Icons.work_outline : Icons.work_off_outlined,
            color: isAvailable
                ? SettingsScreen._brandColor
                : const Color(0xFF9AA7AD),
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _SettingsMenu extends StatelessWidget {
  const _SettingsMenu({
    required this.localizations,
    required this.menuItemKeys,
    required this.onAccountTap,
    // required this.onPaymentTap,
    required this.onSupportTap,
  });

  final AppLocalizations localizations;
  final List<String> menuItemKeys;
  final VoidCallback onAccountTap;
  // final VoidCallback onPaymentTap;
  final VoidCallback onSupportTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.settings_outlined,
            title: localizations.text(menuItemKeys[0]),
            onTap: onAccountTap,
          ),
          // const Divider(height: 1, color: Color(0xFFF0F3F4)),
          // _SettingsTile(
          //   icon: Icons.payments_outlined,
          //   title: localizations.text(menuItemKeys[1]),
          //   onTap: onPaymentTap,
          // ),
          const Divider(height: 1, color: Color(0xFFF0F3F4)),
          _SettingsTile(
            icon: Icons.support_agent_outlined,
            title: localizations.text(menuItemKeys[2]),
            onTap: onSupportTap,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 10,
      leading: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xFFF4F8F9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF66767D), size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: const Color(0xFF242B2F),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFFD0D8DC),
        size: 24,
      ),
      onTap: onTap,
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.localizations});

  final AppLocalizations localizations;

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.text('signOutConfirmTitle')),
        content: Text(localizations.text('signOutConfirmMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.text('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.text('signOut')),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _confirmSignOut(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFB3262E),
        backgroundColor: Colors.white,
        minimumSize: const Size(0, 62),
        side: const BorderSide(color: Color(0xFFF0D9DC)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      icon: const Icon(Icons.logout, size: 22),
      label: Text(localizations.text('signOut')),
    );
  }
}
