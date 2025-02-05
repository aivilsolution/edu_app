import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputBorder? border;
  final Color? fillColor;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  const SearchTextField({
    super.key,
    this.hintText = 'Search',
    this.onChanged,
    this.onClear,
    this.controller,
    this.focusNode,
    this.border,
    this.fillColor,
    this.autofocus = false,
    this.textInputAction = TextInputAction.search,
    this.onSubmitted,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton = _controller.text.isNotEmpty;
    });
    widget.onChanged?.call(_controller.text);
  }

  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.colorScheme.primary.withOpacity(0.5),
        width: 1.5,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.colorScheme.primary,
        width: 2,
      ),
    );

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.fillColor ?? theme.colorScheme.surface,
        hintText: widget.hintText,
        prefixIcon: Icon(
          Icons.search,
          color: theme.hintColor,
        ),
        suffixIcon: _showClearButton
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: theme.hintColor,
                ),
                onPressed: _clearText,
              )
            : null,
        border: widget.border ?? defaultBorder,
        enabledBorder: widget.border ?? defaultBorder,
        focusedBorder: widget.border ?? focusedBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
