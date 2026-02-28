import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/particle_field.dart';
import '../../../shared/widgets/glowing_button.dart';
import '../../../shared/widgets/nexus_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kDemoMode) {
        await Future.delayed(const Duration(milliseconds: 600));
        ref.read(demoLoggedInProvider.notifier).state = true;
        if (mounted) context.go('/home/explore');
        return;
      }
      // --- production path ---
      if (mounted) context.go('/home/explore');
    } catch (e) {
      setState(() => _errorMessage = 'Authentication failed. Please try again.');
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

                  // Back button
                  GestureDetector(
                    onTap: () => context.go('/home/explore'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: NexusColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NexusColors.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: NexusColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Heading
                  Text('Welcome\nback.', style: NexusText.heroTitle)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, duration: 500.ms),

                  const SizedBox(height: 8),

                  Text(
                    'Sign in to access your club chats and dashboard.',
                    style: NexusText.body,
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 40),

                  // Email field
                  NexusTextField(
                    controller: _emailCtrl,
                    label: 'College Email',
                    hint: 'you@college.edu',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // Password field
                  NexusTextField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: NexusColors.textMuted,
                        size: 20,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'Password too short';
                      return null;
                    },
                  ).animate(delay: 280.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 10),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: implement forgot password
                      },
                      child: Text(
                        'Forgot password?',
                        style: NexusText.bodySmall.copyWith(
                          color: NexusColors.cyan.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NexusColors.rose.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: NexusColors.rose.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: NexusColors.rose, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: NexusText.bodySmall
                                  .copyWith(color: NexusColors.rose),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).shakeX(),
                  ],

                  const SizedBox(height: 28),

                  // Login button
                  GlowingButton(
                    label: 'Sign In',
                    onTap: _isLoading ? null : _login,
                    isLoading: _isLoading,
                    fullWidth: true,
                    icon: Icons.login,
                  ).animate(delay: 350.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: NexusColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'No account yet?',
                          style: NexusText.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider(color: NexusColors.border)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sign up button
                  GlowingButton(
                    label: 'Create Account',
                    onTap: () => context.go('/auth/signup'),
                    isOutlined: true,
                    fullWidth: true,
                    color1: NexusColors.violet,
                    color2: NexusColors.violet,
                  ).animate(delay: 420.ms).fadeIn(duration: 400.ms),

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
