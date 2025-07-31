import 'package:flutter/material.dart';

class ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;
  final Color? color;
  final double size;
  final String? tooltip;

  const ToolButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isSelected = false,
    this.color,
    this.size = 24.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = isSelected
        ? Theme.of(context).primaryColor
        : (color ?? Colors.grey[600]);

    return Tooltip(
      message: tooltip ?? label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Theme.of(context).primaryColor, width: 1)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: buttonColor, size: size),
                if (label.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: buttonColor,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IconToolButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isSelected;
  final Color? color;
  final double size;
  final String? tooltip;

  const IconToolButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isSelected = false,
    this.color,
    this.size = 24.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return ToolButton(
      icon: icon,
      label: '',
      onPressed: onPressed,
      isSelected: isSelected,
      color: color,
      size: size,
      tooltip: tooltip,
    );
  }
}

class ColorToolButton extends StatelessWidget {
  final Color color;
  final VoidCallback onPressed;
  final bool isSelected;
  final double size;

  const ColorToolButton({
    super.key,
    required this.color,
    required this.onPressed,
    this.isSelected = false,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

class StrokeWidthButton extends StatelessWidget {
  final double strokeWidth;
  final VoidCallback onPressed;
  final bool isSelected;
  final Color color;

  const StrokeWidthButton({
    super.key,
    required this.strokeWidth,
    required this.onPressed,
    this.isSelected = false,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Center(
          child: Container(
            width: strokeWidth.clamp(2, 16),
            height: strokeWidth.clamp(2, 16),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
