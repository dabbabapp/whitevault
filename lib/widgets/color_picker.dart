import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  static const List<Color> predefinedColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey,
    Colors.cyan,
    Colors.lime,
    Colors.indigo,
    Colors.teal,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Colors',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: predefinedColors.map((color) {
              return ColorButton(
                color: color,
                isSelected: selectedColor == color,
                onPressed: () => onColorSelected(color),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onPressed;
  final double size;

  const ColorButton({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onPressed,
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
        child: color == Colors.white
            ? Icon(Icons.circle, color: Colors.grey[300], size: size * 0.6)
            : null,
      ),
    );
  }
}

class HSVColorPicker extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const HSVColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<HSVColorPicker> createState() => _HSVColorPickerState();
}

class _HSVColorPickerState extends State<HSVColorPicker> {
  late HSVColor _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = HSVColor.fromColor(widget.initialColor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color preview
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: _currentColor.toColor(),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
          const SizedBox(height: 16),

          // Hue slider
          _buildSlider('Hue', _currentColor.hue, 0, 360, (value) {
            setState(() {
              _currentColor = _currentColor.withHue(value);
            });
            widget.onColorChanged(_currentColor.toColor());
          }),

          // Saturation slider
          _buildSlider('Saturation', _currentColor.saturation * 100, 0, 100, (
            value,
          ) {
            setState(() {
              _currentColor = _currentColor.withSaturation(value / 100);
            });
            widget.onColorChanged(_currentColor.toColor());
          }),

          // Value slider
          _buildSlider('Brightness', _currentColor.value * 100, 0, 100, (
            value,
          ) {
            setState(() {
              _currentColor = _currentColor.withValue(value / 100);
            });
            widget.onColorChanged(_currentColor.toColor());
          }),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.round()}', style: const TextStyle(fontSize: 14)),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: _currentColor.toColor(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class CompactColorPicker extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const CompactColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ColorPicker.predefinedColors.take(8).map((color) {
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: ColorButton(
            color: color,
            isSelected: selectedColor == color,
            onPressed: () => onColorSelected(color),
            size: 24,
          ),
        );
      }).toList(),
    );
  }
}
