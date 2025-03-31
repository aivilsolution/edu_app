import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'auth.dart';
import 'package:edu_app/shared/widgets/auth_components.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _formSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _submitForm() async {
    setState(() {
      _formSubmitted = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors above'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        _emailController.text.trim(),
        _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) context.go('/');
        if (state.status == AuthStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          context.read<AuthBloc>().add(AuthErrorCleared());
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.authenticating;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      autovalidateMode:
                          _formSubmitted
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign Up',
                            style: Theme.of(
                              context,
                            ).textTheme.displaySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          AuthTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            validator: _validateName,
                            enabled: !isLoading,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            enabled: !isLoading,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                            enabled: !isLoading,
                            textInputAction: TextInputAction.next,
                            onToggleVisibility: _togglePasswordVisibility,
                          ),
                          if (_passwordController.text.isNotEmpty)
                            PasswordStrengthIndicator(
                              password: _passwordController.text,
                            ),
                          if (_passwordController.text.isNotEmpty)
                            PasswordRequirementsIndicator(
                              password: _passwordController.text,
                              requirements: PasswordRequirement.standard,
                            ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            obscureText: _obscureConfirmPassword,
                            validator: _validateConfirmPassword,
                            enabled: !isLoading,
                            onFieldSubmitted: (_) => _submitForm(),
                            onToggleVisibility:
                                _toggleConfirmPasswordVisibility,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 24),
                          AuthButton(
                            label: 'Create Account',
                            isLoading: isLoading,
                            onPressed: _submitForm,
                          ),
                          const SizedBox(height: 24),
                          AuthDivider(text: 'OR'),
                          const SizedBox(height: 16),
                          SocialAuthButton.google(
                            onPressed:
                                isLoading
                                    ? null
                                    : () => context.read<AuthBloc>().add(
                                      AuthGoogleSignInRequested(),
                                    ),
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 32),
                          AuthFooterLink(
                            prompt: 'Already have an account?',
                            action: 'Log In',
                            onAction:
                                () => context.pushReplacementNamed('login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Name required';
    if (name.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email required';
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      return 'Valid email required';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password required';
    if (password.length < 6) return 'Minimum 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value ?? '';
    if (confirmPassword.isEmpty) return 'Confirm password required';
    if (confirmPassword != _passwordController.text) {
      return 'Passwords must match';
    }
    return null;
  }
}
