import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedRole = 'user';
  bool _showPassword = false;

  final _roleData = {
    'user': {'label': 'Vehicle Owner', 'icon': Icons.person_rounded},
    'owner': {'label': 'Service Center', 'icon': Icons.business_rounded},
  };

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      role: _selectedRole,
    );
    if (success && mounted) {
      Navigator.pop(context);
    } else if (auth.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.error!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.04),
              ),
            ),
          ).animate().fadeIn(duration: 1.seconds),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create\nAccount',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                            height: 1,
                          ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),

                    const SizedBox(height: 12),

                    Text(
                      'Join GearUp network',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

                    const SizedBox(height: 32),

                    // Role Selection
                    Row(
                      children: _roleData.entries.map((entry) {
                        final isSelected = _selectedRole == entry.key;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRole = entry.key),
                            child: AnimatedContainer(
                              duration: 300.ms,
                              margin: EdgeInsets.only(
                                right: entry.key == 'user' ? 8 : 0,
                                left: entry.key == 'owner' ? 8 : 0,
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primary : Colors.white,
                                borderRadius: AppTheme.radiusMedium,
                                border: Border.all(
                                  color: isSelected ? AppTheme.primary : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                                boxShadow: isSelected ? AppTheme.glowShadow(AppTheme.primary) : AppTheme.softShadow,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    entry.value['icon'] as IconData,
                                    color: isSelected ? Colors.white : AppTheme.textMuted,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    entry.value['label'] as String,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                    const SizedBox(height: 32),

                    // Registration Form
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameCtrl,
                                  decoration: const InputDecoration(labelText: 'First Name'),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameCtrl,
                                  decoration: const InputDecoration(labelText: 'Last Name'),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 500.ms),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _usernameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.alternate_email_rounded),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            validator: (v) => v?.isEmpty == true ? 'Required' : null,
                          ).animate().fadeIn(delay: 600.ms),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            validator: (v) {
                              if (v?.isEmpty == true) return 'Required';
                              if (!v!.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ).animate().fadeIn(delay: 700.ms),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone_iphone_rounded),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            validator: (v) => v?.isEmpty == true ? 'Required' : null,
                          ).animate().fadeIn(delay: 800.ms),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_open_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: AppTheme.textMuted,
                                ),
                                onPressed: () => setState(() => _showPassword = !_showPassword),
                              ),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            validator: (v) {
                              if (v?.isEmpty == true) return 'Required';
                              if (v!.length < 6) return 'Min 6 characters';
                              return null;
                            },
                          ).animate().fadeIn(delay: 900.ms),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    GradientButton(
                      text: 'Create Account',
                      icon: Icons.person_add_rounded,
                      isLoading: auth.isLoading,
                      onPressed: _register,
                    ).animate().fadeIn(delay: 1.seconds).scale(),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1100.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
