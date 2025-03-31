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
  final FocusNode? focusNode;
  final String? helperText;
  final TextInputAction? textInputAction;
  final InputDecoration? customDecoration;
  final EdgeInsetsGeometry padding;

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
    this.focusNode,
    this.helperText,
    this.textInputAction = TextInputAction.next,
    this.customDecoration,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        focusNode: focusNode,
        textInputAction: textInputAction,
        style: theme.textTheme.bodyLarge,
        decoration:
            customDecoration ??
            InputDecoration(
              labelText: label,
              helperText: helperText,
              prefixIcon: Icon(icon, color: theme.colorScheme.primary),
              suffixIcon:
                  onToggleVisibility != null
                      ? IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          semanticLabel:
                              obscureText ? 'Show password' : 'Hide password',
                        ),
                        onPressed: onToggleVisibility,
                        tooltip:
                            obscureText ? 'Show password' : 'Hide password',
                      )
                      : null,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: theme.colorScheme.error),
              ),
              filled: true,
              fillColor:
                  enabled
                      ? theme.colorScheme.surface
                      : theme.colorScheme.surfaceContainerHighest,
            ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Widget? icon;

  const AuthButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 50,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
    this.borderRadius,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, height),
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 2,
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: foregroundColor ?? theme.colorScheme.onPrimary,
                  ),
                )
                : icon != null
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon!,
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: foregroundColor ?? theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                : Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: foregroundColor ?? theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}

class SocialAuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final double height;
  final String label;
  final Widget icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  const SocialAuthButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
    this.height = 50,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  factory SocialAuthButton.google({
    Key? key,
    VoidCallback? onPressed,
    bool isLoading = false,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 8.0),
    double height = 50,
  }) {
    return SocialAuthButton(
      key: key,
      onPressed: onPressed,
      isLoading: isLoading,
      padding: padding,
      height: height,
      label: 'Continue with Google',
      icon: const Icon(Icons.g_mobiledata, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: OutlinedButton.icon(
        icon:
            isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.primary,
                  ),
                )
                : icon,
        label: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: foregroundColor ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, height),
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(
            color: borderColor ?? theme.colorScheme.outline,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  final String prompt;
  final String action;
  final VoidCallback onAction;
  final EdgeInsetsGeometry padding;
  final TextStyle? promptStyle;
  final TextStyle? actionStyle;

  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onAction,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
    this.promptStyle,
    this.actionStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(prompt, style: promptStyle ?? theme.textTheme.bodyMedium),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action,
              style:
                  actionStyle ??
                  TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordRequirementsIndicator extends StatelessWidget {
  final String password;
  final List<PasswordRequirement> requirements;
  final EdgeInsetsGeometry padding;

  const PasswordRequirementsIndicator({
    super.key,
    required this.password,
    required this.requirements,
    this.padding = const EdgeInsets.only(top: 4.0, bottom: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            requirements.map((requirement) {
              final isMet = requirement.validate(password);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Icon(
                      isMet ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color:
                          isMet
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      requirement.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            isMet
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

class PasswordRequirement {
  final String description;
  final bool Function(String) validate;

  const PasswordRequirement({
    required this.description,
    required this.validate,
  });

  static final minLength = PasswordRequirement(
    description: 'At least 8 characters',
    validate: (password) => password.length >= 8,
  );

  static final hasUppercase = PasswordRequirement(
    description: 'At least one uppercase letter',
    validate: (password) => password.contains(RegExp(r'[A-Z]')),
  );

  static final hasLowercase = PasswordRequirement(
    description: 'At least one lowercase letter',
    validate: (password) => password.contains(RegExp(r'[a-z]')),
  );

  static final hasNumber = PasswordRequirement(
    description: 'At least one number',
    validate: (password) => password.contains(RegExp(r'[0-9]')),
  );

  static final hasSpecialChar = PasswordRequirement(
    description: 'At least one special character',
    validate:
        (password) => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
  );

  static List<PasswordRequirement> get standard => [
    minLength,
    hasUppercase,
    hasLowercase,
    hasNumber,
  ];
}

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final EdgeInsetsGeometry padding;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.padding = const EdgeInsets.only(top: 4.0, bottom: 12.0),
  });

  int _calculateStrength() {
    if (password.isEmpty) return 0;

    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength > 5 ? 5 : strength;
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
        return 'Very Weak';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      case 5:
        return 'Very Strong';
      default:
        return '';
    }
  }

  Color _getStrengthColor(int strength, ThemeData theme) {
    switch (strength) {
      case 0:
      case 1:
        return theme.colorScheme.error;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.green;
      case 5:
        return Colors.green.shade700;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strength = _calculateStrength();
    final strengthText = _getStrengthText(strength);
    final strengthColor = _getStrengthColor(strength, theme);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: strength / 5,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: strengthColor,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                strengthText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: strengthColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const AuthDivider({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
        ],
      ),
    );
  }
}
