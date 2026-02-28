import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/glowing_button.dart';
import '../../../shared/widgets/nexus_text_field.dart';
import '../../../shared/widgets/particle_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _rollCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kDemoMode) {
        await Future.delayed(const Duration(milliseconds: 800));
        ref.read(demoLoggedInProvider.notifier).state = true;
        if (mounted) context.go('/home/explore');
        return;
      }
      // --- production path ---
      if (mounted) context.go('/home/explore');
    } catch (e) {
      setState(() => _errorMessage = 'Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.bg,
      body: ParticleField(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: () => context.go('/auth/login'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: NexusColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NexusColors.border),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: NexusColors.textSecondary, size: 20),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text('Join\nNEXUS.', style: NexusText.heroTitle)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'Create your account and connect with your campus clubs.',
                    style: NexusText.body,
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 36),

                  NexusTextField(
                    controller: _nameCtrl,
                    label: 'Display Name',
                    hint: 'How you appear in chats',
                    prefixIcon: Icons.badge_outlined,
                    accentColor: NexusColors.violet,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Name is required';
                      if (v.trim().length < 2) return 'Name too short';
                      return null;
                    },
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 14),

                  NexusTextField(
                    controller: _emailCtrl,
                    label: 'College Email',
                    hint: 'you@college.edu',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    accentColor: NexusColors.violet,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ).animate(delay: 260.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 14),

                  NexusTextField(
                    controller: _rollCtrl,
                    label: 'Roll Number',
                    hint: 'e.g. 21CS001',
                    prefixIcon: Icons.numbers_outlined,
                    accentColor: NexusColors.violet,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Roll number is required';
                      return null;
                    },
                  ).animate(delay: 320.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 14),

                  NexusTextField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    accentColor: NexusColors.violet,
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: NexusColors.textMuted,
                        size: 20,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ).animate(delay: 380.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 14),

                  NexusTextField(
                    controller: _confirmCtrl,
                    label: 'Confirm Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirm,
                    accentColor: NexusColors.violet,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _signup(),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      child: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: NexusColors.textMuted,
                        size: 20,
                      ),
                    ),
                    validator: (v) {
                      if (v != _passwordCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ).animate(delay: 440.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NexusColors.rose.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: NexusColors.rose.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: NexusColors.rose, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: NexusText.bodySmall.copyWith(color: NexusColors.rose),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).shakeX(),
                  ],

                  const SizedBox(height: 28),

                  GlowingButton(
                    label: 'Create Account',
                    onTap: _isLoading ? null : _signup,
                    isLoading: _isLoading,
                    fullWidth: true,
                    color1: NexusColors.violet,
                    color2: NexusColors.rose,
                    icon: Icons.person_add_outlined,
                  ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/auth/login'),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: NexusText.bodySmall,
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: NexusText.bodySmall.copyWith(
                                color: NexusColors.cyan,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
