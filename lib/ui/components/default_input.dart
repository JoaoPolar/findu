import 'package:flutter/material.dart';
import 'package:findu/ui/theme/app_colors.dart';

// Instalar a extensão wings for flutter
Widget preview() {
  return DefaultInput(
    hintText: 'email@exemplo.com',
    keyboardType: TextInputType.emailAddress,
  );
}

class DefaultInput extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  const DefaultInput({
    super.key,
    required this.hintText,
    this.controller,
    required this.keyboardType,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.webNeutral400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: AppColors.webNeutral300,
            width: 2.0,

          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            // quando der usar o Theme.of(context).primaryColor, senão o AppColors.
            color: Theme.of(context).primaryColor,
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            // esse não tem no figma mas deduzi
            color: AppColors.webNeutral200,
            width: 2.0,
          ),
        ),

        // Borda quando há erro
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
