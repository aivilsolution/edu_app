import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'auth.dart';
import 'package:edu_app/shared/widgets/auth_components.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
      AuthSignInRequested(
        _emailController.text.trim(),
        _passwordController.text,
      ),
    );
  }

  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder:
          (context) => BlocProvider.value(
            value: BlocProvider.of<AuthBloc>(context),
            child: PasswordResetDialog(
              onResetRequested: (email) {
                context.read<AuthBloc>().add(AuthPasswordResetRequested(email));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Password reset email sent if account exists.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) context.go('/');
        if (state.hasError && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: theme.colorScheme.error,
            ),
          );
          context.read<AuthBloc>().add(AuthErrorCleared());
        }
      },
      builder: (context, state) {
        final isLoading = state.isAuthenticating;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Log In',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          AuthTextField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            enabled: !isLoading,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted:
                                (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_passwordFocusNode),
                          ),
                          AuthTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                            enabled: !isLoading,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submitForm(),
                            onToggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged:
                                            isLoading
                                                ? null
                                                : (value) {
                                                  setState(() {
                                                    _rememberMe =
                                                        value ?? false;
                                                  });
                                                },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap:
                                          isLoading
                                              ? null
                                              : () {
                                                setState(() {
                                                  _rememberMe = !_rememberMe;
                                                });
                                              },
                                      child: Text(
                                        'Remember me',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed:
                                      isLoading
                                          ? null
                                          : _showPasswordResetDialog,
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                  ),
                                  child: const Text('Forgot Password?'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AuthButton(
                            label: 'Log In',
                            isLoading: isLoading,
                            onPressed: _submitForm,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                          ),
                          const AuthDivider(
                            text: 'OR',
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                          ),
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
                            prompt: 'Don\'t have an account?',
                            action: 'Sign Up',
                            onAction:
                                () => context.pushReplacementNamed('signup'),
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

class PasswordResetDialog extends StatefulWidget {
  final Function(String) onResetRequested;

  const PasswordResetDialog({super.key, required this.onResetRequested});

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      widget.onResetRequested(_emailController.text.trim());

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Reset Password', style: theme.textTheme.titleLarge),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter your email address and we\'ll send you instructions to reset your password.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                ).hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitForm(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child:
              _isSubmitting
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                  : const Text('Send Reset Link'),
        ),
      ],
    );
  }
}
