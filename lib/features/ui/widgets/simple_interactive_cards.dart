import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../themes/app_theme.dart';

class SimpleInteractiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableHover;
  final double? elevation;
  final Color? backgroundColor;
  final Duration? animationDuration;

  const SimpleInteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.enableHover = true,
    this.elevation,
    this.backgroundColor,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animationDuration ?? const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor:
              enableHover ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(enableHover ? 1.05 : 1.0),
            child: Card(
              elevation: elevation ?? 4.0,
              shadowColor: Colors.black.withOpacity(0.2),
              color: backgroundColor ?? Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: enableHover
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : BorderSide.none,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleAnimatedCounter extends StatelessWidget {
  final int initialValue;
  final int targetValue;
  final Duration duration;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? label;
  final TextStyle? textStyle;
  final VoidCallback? onComplete;

  const SimpleAnimatedCounter({
    super.key,
    required this.initialValue,
    required this.targetValue,
    this.duration = const Duration(seconds: 2),
    this.activeColor,
    this.inactiveColor,
    this.label,
    this.textStyle,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: inactiveColor ?? Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activeColor ?? Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: textStyle ?? Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: activeColor ?? Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  initialValue.toString(),
                  style: TextStyle(
                    color: activeColor ?? Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${targetValue - initialValue} remaining',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SimplePulseAnimation extends StatelessWidget {
  final Widget child;
  final Color? pulseColor;
  final Duration duration;
  final double scale;

  const SimplePulseAnimation({
    super.key,
    required this.child,
    this.pulseColor,
    this.duration = const Duration(milliseconds: 1500),
    this.scale = 1.1,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOut,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: pulseColor ?? Theme.of(context).colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: (pulseColor ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}

class SimpleFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final double? size;
  final String? tooltip;

  const SimpleFloatingButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: elevation! * 0.5,
                  offset: Offset(0, elevation! * 0.3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: backgroundColor ?? Theme.of(context).colorScheme.primary,
        elevation: elevation ?? 6.0,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size != null ? size! / 2 : 20),
          child: Container(
            width: size != null ? size : 56,
            height: size != null ? size : 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleSearchBar extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSearch;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool enableSuggestions;
  final Duration? animationDuration;

  const SimpleSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.onSearch,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.enableSuggestions = false,
    this.animationDuration,
  });

  @override
  State<SimpleSearchBar> createState() => _SimpleSearchBarState();
}

class _SimpleSearchBarState extends State<SimpleSearchBar> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_textController.text);
    }
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          if (widget.prefixIcon != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: widget.prefixIcon!,
            ),
          ],
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          if (widget.onClear != null && _textController.text.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  _textController.clear();
                  widget.onClear!();
                },
                child: Icon(Icons.clear,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
          if (widget.onSearch != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: widget.onSearch != null
                    ? () => widget.onSearch!(_textController.text)
                    : null,
                child: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SimpleStatusBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;
  final VoidCallback? onTap;

  const SimpleStatusBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size ?? 8,
              height: size ?? 8,
              decoration: BoxDecoration(
                color: textColor ?? Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: size != null ? size! * 2 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor ?? Colors.white,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
