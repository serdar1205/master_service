import 'package:flutter/material.dart';

import '../utils/phone_formatter.dart';
import '../utils/turkmen_phone_text_input_formatter.dart';

class TurkmenPhoneField extends StatelessWidget {
  const TurkmenPhoneField({
    required this.controller,
    this.focusNode,
    this.hintText = PhoneFormatter.localDisplayHint,
    this.focusedBorderColor,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final Color? focusedBorderColor;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      maxLength: PhoneFormatter.localDisplayLength,
      inputFormatters: const [TurkmenPhoneTextInputFormatter()],
      style: theme.textTheme.titleMedium?.copyWith(
        color: const Color(0xFF4B5960),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 18, right: 8),
          child: Align(
            widthFactor: 1,
            child: Text(
              PhoneFormatter.countryCode,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF4B5960),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8D989D)),
        filled: true,
        fillColor: const Color(0xFFF0F5F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 19,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBCC9CD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: focusedBorderColor ?? theme.colorScheme.primary,
            width: 1.4,
          ),
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
