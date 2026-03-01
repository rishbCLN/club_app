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
        
        // Validate hardcoded credentials
        final username = _emailCtrl.text.trim();
        final password = _passwordCtrl.text.trim();
        UserRole? role;

        if (username == 'admin' && password == 'admin') {
          role = UserRole.admin;
        } else if (username == 'user' && password == 'user') {
          role = UserRole.user;
        } else {
          setState(() => _errorMessage = 'Invalid username or password. Try "user"/"user" or "admin"/"admin"');
          if (mounted) setState(() => _isLoading = false);
          return;
        }

        // Set login state and role
        ref.read(demoLoggedInProvider.notifier).state = true;
        ref.read(demoUserRoleProvider.notifier).state = role;

        // Navigate to appropriate home screen
        if (mounted) {
          if (role == UserRole.admin) {
            context.go('/admin/dashboard');
          } else {
            context.go('/home/explore');
          }
        }
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
                  const SizedBox(height: 60),

                  // Heading
                  Text('NEXUS', style: NexusText.appBarTitle.copyWith(
                    color: NexusColors.cyan,
                    letterSpacing: 4,
                  ))
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, duration: 500.ms),

                  const SizedBox(height: 48),

                  Text('Sign in to\nyour account.', style: NexusText.heroTitle)
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, duration: 500.ms),

                  const SizedBox(height: 8),

                  Text(
                    'Admin: admin / Admin Password: admin\nUser: user / User Password: user',
                    style: NexusText.bodySmall.copyWith(
                      color: NexusColors.cyan.withOpacity(0.7),
                      height: 1.6,
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 56),

                  // Username field
                  NexusTextField(
                    controller: _emailCtrl,
                    label: 'Username',
                    hint: 'user or admin',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.text,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Username is required';
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
                      return null;
                    },
                  ).animate(delay: 280.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 28),

                  // Error message
                  if (_errorMessage != null) ...[
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
                    const SizedBox(height: 20),
                  ],

                  // Login button
                  GlowingButton(
                    label: 'Sign In',
                    onTap: _isLoading ? null : _login,
                    isLoading: _isLoading,
                    fullWidth: true,
                    icon: Icons.login,
                  ).animate(delay: 350.ms).fadeIn(duration: 400.ms),

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
