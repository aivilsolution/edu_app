import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final void Function(String)? onFieldSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.enabled = true,
    this.keyboardType,
    this.obscureText = false,
    this.onToggleVisibility,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon:
            onToggleVisibility != null
                ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: onToggleVisibility,
                )
                : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child:
          isLoading
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              )
              : Text(label),
    );
  }
}

class SocialAuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialAuthButton.google({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.g_mobiledata),
      label: const Text('Continue with Google'),
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  final String prompt;
  final String action;
  final VoidCallback onAction;

  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt),
        TextButton(onPressed: onAction, child: Text(action)),
      ],
    );
  }
}
