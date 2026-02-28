import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/colors.dart';

class NexusTextField extends StatefulWidget {
  const NexusTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.accentColor = NexusColors.cyan,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final Color accentColor;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<NexusTextField> createState() => _NexusTextFieldState();
}

class _NexusTextFieldState extends State<NexusTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                  )
                ]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          style: GoogleFonts.dmSans(
            color: NexusColors.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            labelStyle: GoogleFonts.dmSans(
              color: _isFocused
                  ? widget.accentColor
                  : NexusColors.textMuted,
              fontSize: 13,
            ),
            hintStyle: GoogleFonts.dmSans(
              color: NexusColors.textMuted.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused ? widget.accentColor : NexusColors.textMuted,
                    size: 20,
                  )
                : null,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: _isFocused
                ? NexusColors.surfaceElevated
                : NexusColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: NexusColors.border,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: NexusColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: widget.accentColor.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: NexusColors.rose,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: NexusColors.rose,
                width: 1.5,
              ),
            ),
            errorStyle: GoogleFonts.dmSans(
              color: NexusColors.rose,
              fontSize: 11,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}
