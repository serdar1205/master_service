import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/app_status.dart';
import '../../application/job_details_cubit.dart';
import '../../data/local_jobs_repository.dart';

const _brandColor = AppColors.brand;
const _buttonColor = AppColors.buttonTeal;

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final jobId = GoRouterState.of(context).pathParameters['jobId'] ?? 'job-2';

    return BlocProvider(
      create: (_) => JobDetailsCubit(const LocalJobsRepository())..load(jobId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FBFB),
        body: SafeArea(
          child: Column(
            children: [
              _DetailsHeader(localizations: localizations),
              Expanded(
                child: BlocBuilder<JobDetailsCubit, JobDetailsState>(
                  builder: (context, state) {
                    if (state.status == AppStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == AppStatus.failure) {
                      return Center(child: Text(state.errorMessage ?? ''));
                    }

                    final details = state.data;
                    if (details == null) {
                      return const SizedBox.shrink();
                    }

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      children: [
                        _PhotoSection(
                          title: localizations.text('before'),
                          icon: Icons.history,
                          children: [
                            _PhotoSlot(
                              label: '${localizations.text('photo')} 1',
                              imageUrl: details.beforePhotos.first,
                            ),
                            _PhotoSlot(
                              label: '${localizations.text('photo')} 2',
                              imageUrl: details.beforePhotos[1],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _PhotoSection(
                          title: localizations.text('after'),
                          icon: Icons.verified_outlined,
                          children: [
                            _PhotoSlot(imageUrl: details.afterPhotos.first),
                            _PhotoSlot(
                              label: localizations.text('addPhoto'),
                              imageUrl: details.afterPhotos[1],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _PriceConfirmationCard(localizations: localizations),
                        const SizedBox(height: 20),
                        _CompletionNote(localizations: localizations),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: _buttonColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
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
              localizations.text('completeOrderTitle'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _brandColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8F9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: _brandColor,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  'RU/TM',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF5D686E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _brandColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF293237),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({this.label, this.imageUrl});

  final String? label;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final imageUrl = this.imageUrl;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _brandColor.withValues(alpha: imageUrl == null ? 0.75 : 0),
            width: 1.4,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        foregroundDecoration: imageUrl == null
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _brandColor.withValues(alpha: 0.7),
                  width: 1.2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              )
            : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              const _PhotoPlaceholder()
            else
              const ColoredBox(color: Colors.white),
            if (imageUrl == null)
              CustomPaint(painter: _DashedBorderPainter(color: _brandColor)),
            if (imageUrl != null)
              ColoredBox(color: Colors.white.withValues(alpha: 0.62)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    color: _brandColor,
                    size: 27,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF6D7A82),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PhotoPlaceholderPainter());
  }
}

class _PhotoPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFC5D6D9);
    canvas.drawRect(Offset.zero & size, paint);

    final accent = Paint()..color = const Color(0xFF9DB2B6);
    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.4), 26, accent);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.2,
          size.height * 0.55,
          size.width * 0.5,
          size.height * 0.28,
        ),
        const Radius.circular(12),
      ),
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 5.0;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    final path = Path()..addRRect(rect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PriceConfirmationCard extends StatelessWidget {
  const _PriceConfirmationCard({required this.localizations});

  final AppLocalizations localizations;

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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _brandColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.text('priceConfirmationDescription'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF293237),
              height: 1.42,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: _buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
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
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF7A868C),
        height: 1.55,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
