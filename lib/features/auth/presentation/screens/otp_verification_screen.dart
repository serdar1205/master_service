import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../application/auth_cubit.dart';

const _otpLength = 6;
const _otpBoxSpacing = 6.0;

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });
    _otpController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = AppColors.brand;

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAFA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: brandColor,
                  onPressed: () => context.read<AuthCubit>().backToLogin(),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return _OtpCard(
                        state: state,
                        brandColor: brandColor,
                        otpController: _otpController,
                        otpFocusNode: _otpFocusNode,
                        onSubmit: () => _submit(context),
                        onResend: () => context.read<AuthCubit>().resendOtp(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_otpController.text.length < _otpLength) {
      return;
    }

    context.read<AuthCubit>().verifyOtp(_otpController.text);
  }
}

class _OtpCard extends StatelessWidget {
  const _OtpCard({
    required this.state,
    required this.brandColor,
    required this.otpController,
    required this.otpFocusNode,
    required this.onSubmit,
    required this.onResend,
  });

  final AuthState state;
  final Color brandColor;
  final TextEditingController otpController;
  final FocusNode otpFocusNode;
  final VoidCallback onSubmit;
  final VoidCallback onResend;

  bool get _canVerify =>
      !state.isLoading && otpController.text.length >= _otpLength;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final phoneNumber = state.phoneNumber;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: const BorderSide(color: Color(0xFFE7EEF0)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFE5FCF8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: brandColor.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Icon(Icons.sms_outlined, color: brandColor, size: 32),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.text('otpTitle'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF171717),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.text('otpSubtitle'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF424C52),
                height: 1.45,
              ),
            ),
            if (phoneNumber != null) ...[
              const SizedBox(height: 8),
              Text(
                PhoneFormatter.toDisplayE164(phoneNumber),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: brandColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: _OtpPinInput(
                controller: otpController,
                focusNode: otpFocusNode,
                length: _otpLength,
                enabled: !state.isLoading,
                brandColor: brandColor,
                onCompleted: onSubmit,
              ),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canVerify ? onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonTeal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.buttonTeal.withValues(
                    alpha: 0.45,
                  ),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.9),
                  elevation: 8,
                  shadowColor: AppColors.buttonTeal.withValues(alpha: 0.18),
                  minimumSize: const Size(0, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.isLoading) ...[
                      const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(localizations.text('verify')),
                    if (!state.isLoading) ...[
                      const SizedBox(width: 9),
                      const Icon(Icons.check_rounded, size: 21),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: state.isLoading ? null : onResend,
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: state.isLoading ? null : brandColor,
              ),
              label: Text(
                localizations.text('resendOtp'),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: brandColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpPinInput extends StatefulWidget {
  const _OtpPinInput({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.enabled,
    required this.brandColor,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final bool enabled;
  final Color brandColor;
  final VoidCallback onCompleted;

  @override
  State<_OtpPinInput> createState() => _OtpPinInputState();
}

class _OtpPinInputState extends State<_OtpPinInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleStateChange);
    widget.focusNode.addListener(_handleStateChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleStateChange);
    widget.focusNode.removeListener(_handleStateChange);
    super.dispose();
  }

  void _handleStateChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final code = widget.controller.text;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize =
            (constraints.maxWidth - _otpBoxSpacing * (widget.length - 1)) /
            widget.length;

        return SizedBox(
          width: constraints.maxWidth,
          height: boxSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: widget.length,
                  autofocus: true,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 1,
                  ),
                  cursorColor: Colors.transparent,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    if (value.length >= widget.length) {
                      widget.onCompleted();
                    }
                  },
                  onSubmitted: (_) => widget.onCompleted(),
                ),
              ),
              IgnorePointer(
                child: Row(
                  children: List.generate(widget.length, (index) {
                    final hasValue = index < code.length;
                    final isActive =
                        widget.focusNode.hasFocus && index == code.length;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : _otpBoxSpacing,
                        ),
                        child: _OtpDigitBox(
                          digit: hasValue ? code[index] : '',
                          isActive: isActive,
                          brandColor: widget.brandColor,
                          size: boxSize,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    required this.digit,
    required this.isActive,
    required this.brandColor,
    required this.size,
  });

  final String digit;
  final bool isActive;
  final Color brandColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasDigit = digit.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: hasDigit ? const Color(0xFFF4FBFB) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? brandColor
              : hasDigit
              ? brandColor.withValues(alpha: 0.35)
              : const Color(0xFFDCE5E7),
          width: isActive ? 2 : 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: brandColor.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Text(
        digit,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: const Color(0xFF172025),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
