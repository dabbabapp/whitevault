// Advanced Creative Tools - Making WhiteVault a Creative Powerhouse
import 'dart:math';
import 'package:flutter/material.dart';

class AdvancedDrawingTools {
  // 🎨 BRUSH SYSTEMS
  static List<BrushType> availableBrushes = [
    BrushType.pencil,
    BrushType.marker,
    BrushType.watercolor,
    BrushType.spray,
    BrushType.calligraphy,
    BrushType.neon,
    BrushType.eraser,
  ];

  // 🌈 DYNAMIC COLOR PALETTES
  static List<ColorPalette> colorPalettes = [
    ColorPalette.creative,
    ColorPalette.business,
    ColorPalette.nature,
    ColorPalette.ocean,
    ColorPalette.sunset,
    ColorPalette.monochrome,
  ];

  // ✨ SPECIAL EFFECTS
  static List<Effect> effects = [
    Effect.glow,
    Effect.shadow,
    Effect.blur,
    Effect.rainbow,
    Effect.particle,
  ];
}

enum BrushType { pencil, marker, watercolor, spray, calligraphy, neon, eraser }

enum ColorPalette { creative, business, nature, ocean, sunset, monochrome }

enum Effect { glow, shadow, blur, rainbow, particle }

// Advanced Drawing Canvas with Multiple Brush Types
class AdvancedDrawCanvas extends StatefulWidget {
  final List<DrawingStroke>? initialStrokes;
  final Function(List<DrawingStroke>)? onStrokesChanged;
  final BrushType selectedBrush;
  final Color selectedColor;
  final double brushSize;
  final Effect? selectedEffect;

  const AdvancedDrawCanvas({
    super.key,
    this.initialStrokes,
    this.onStrokesChanged,
    this.selectedBrush = BrushType.pencil,
    this.selectedColor = Colors.black,
    this.brushSize = 3.0,
    this.selectedEffect,
  });

  @override
  State<AdvancedDrawCanvas> createState() => _AdvancedDrawCanvasState();
}

class _AdvancedDrawCanvasState extends State<AdvancedDrawCanvas> {
  List<DrawingStroke> _strokes = [];
  DrawingStroke? _currentStroke;

  @override
  void initState() {
    super.initState();
    _strokes = widget.initialStrokes ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(
          painter: AdvancedDrawingPainter(_strokes, _currentStroke),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    _currentStroke = DrawingStroke(
      points: [localPosition],
      brush: widget.selectedBrush,
      color: widget.selectedColor,
      size: widget.brushSize,
      effect: widget.selectedEffect,
      timestamp: DateTime.now(),
    );
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentStroke != null) {
      final renderBox = context.findRenderObject() as RenderBox;
      final localPosition = renderBox.globalToLocal(details.globalPosition);

      setState(() {
        _currentStroke!.points.add(localPosition);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke != null) {
      setState(() {
        _strokes.add(_currentStroke!);
        _currentStroke = null;
      });

      if (widget.onStrokesChanged != null) {
        widget.onStrokesChanged!(_strokes);
      }
    }
  }
}

// Data model for drawing strokes
class DrawingStroke {
  final List<Offset> points;
  final BrushType brush;
  final Color color;
  final double size;
  final Effect? effect;
  final DateTime timestamp;

  DrawingStroke({
    required this.points,
    required this.brush,
    required this.color,
    required this.size,
    this.effect,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'brush': brush.toString(),
      'color': color.toARGB32(),
      'size': size,
      'effect': effect?.toString(),
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    return DrawingStroke(
      points: (json['points'] as List)
          .map((p) => Offset(p['x']?.toDouble() ?? 0, p['y']?.toDouble() ?? 0))
          .toList(),
      brush: BrushType.values.firstWhere(
        (b) => b.toString() == json['brush'],
        orElse: () => BrushType.pencil,
      ),
      color: Color(json['color'] ?? 0xFF000000),
      size: json['size']?.toDouble() ?? 3.0,
      effect: json['effect'] != null
          ? Effect.values.firstWhere(
              (e) => e.toString() == json['effect'],
              orElse: () => Effect.glow,
            )
          : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
    );
  }
}

// Advanced painter with multiple brush types and effects
class AdvancedDrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;

  AdvancedDrawingPainter(this.strokes, this.currentStroke);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Draw current stroke
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = _createPaintForBrush(stroke);
    final path = _createPathFromPoints(stroke.points, stroke.brush);

    // Apply effects
    if (stroke.effect != null) {
      _applyEffect(canvas, path, paint, stroke.effect!);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  Paint _createPaintForBrush(DrawingStroke stroke) {
    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.size
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (stroke.brush) {
      case BrushType.pencil:
        paint.strokeWidth = stroke.size * 0.8;
        break;
      case BrushType.marker:
        paint.strokeWidth = stroke.size * 1.5;
        paint.color = stroke.color.withValues(alpha: 0.7);
        break;
      case BrushType.watercolor:
        paint.strokeWidth = stroke.size * 2.0;
        paint.color = stroke.color.withValues(alpha: 0.3);
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
        break;
      case BrushType.spray:
        paint.strokeWidth = stroke.size * 0.5;
        paint.color = stroke.color.withValues(alpha: 0.6);
        break;
      case BrushType.calligraphy:
        paint.strokeWidth = stroke.size;
        paint.strokeCap = StrokeCap.square;
        break;
      case BrushType.neon:
        paint.color = stroke.color;
        paint.strokeWidth = stroke.size;
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
        break;
      case BrushType.eraser:
        paint.blendMode = BlendMode.clear;
        paint.strokeWidth = stroke.size * 2.0;
        break;
    }

    return paint;
  }

  Path _createPathFromPoints(List<Offset> points, BrushType brush) {
    final path = Path();

    if (points.isEmpty) return path;

    switch (brush) {
      case BrushType.calligraphy:
        return _createCalligraphyPath(points);
      case BrushType.spray:
        return _createSprayPath(points);
      default:
        return _createSmoothPath(points);
    }
  }

  Path _createSmoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlPoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(
        current.dx,
        current.dy,
        controlPoint.dx,
        controlPoint.dy,
      );
    }

    if (points.length > 1) {
      path.lineTo(points.last.dx, points.last.dy);
    }

    return path;
  }

  Path _createCalligraphyPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;

    // Create variable width stroke for calligraphy effect
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      // Calculate pressure simulation based on speed
      final distance = (next - current).distance;
      final pressure = (1.0 - (distance / 50.0)).clamp(0.3, 1.0);

      final rect = Rect.fromPoints(
        current - Offset(pressure * 2, pressure),
        next + Offset(pressure * 2, pressure),
      );
      path.addOval(rect);
    }

    return path;
  }

  Path _createSprayPath(List<Offset> points) {
    final path = Path();
    final random = Random();

    for (final point in points) {
      // Create spray effect with random dots around the main point
      for (int i = 0; i < 5; i++) {
        final offset = Offset(
          point.dx + (random.nextDouble() - 0.5) * 20,
          point.dy + (random.nextDouble() - 0.5) * 20,
        );
        path.addOval(Rect.fromCircle(center: offset, radius: 1.0));
      }
    }

    return path;
  }

  void _applyEffect(Canvas canvas, Path path, Paint paint, Effect effect) {
    switch (effect) {
      case Effect.glow:
        // Draw glow effect
        final glowPaint = Paint()
          ..color = paint.color.withValues(alpha: 0.3)
          ..strokeWidth = paint.strokeWidth * 3
          ..style = paint.style
          ..strokeCap = paint.strokeCap
          ..strokeJoin = paint.strokeJoin
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
        canvas.drawPath(path, glowPaint);
        canvas.drawPath(path, paint);
        break;

      case Effect.shadow:
        // Draw shadow effect
        final shadowPaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..strokeWidth = paint.strokeWidth
          ..style = paint.style
          ..strokeCap = paint.strokeCap
          ..strokeJoin = paint.strokeJoin;

        canvas.save();
        canvas.translate(3, 3);
        canvas.drawPath(path, shadowPaint);
        canvas.restore();
        canvas.drawPath(path, paint);
        break;

      case Effect.blur:
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
        canvas.drawPath(path, paint);
        break;

      case Effect.rainbow:
        _drawRainbowPath(canvas, path, paint);
        break;

      case Effect.particle:
        _drawParticlePath(canvas, path, paint);
        break;
    }
  }

  void _drawRainbowPath(Canvas canvas, Path path, Paint basePaint) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i].withValues(alpha: 0.7)
        ..strokeWidth = basePaint.strokeWidth * (1.0 - i * 0.1)
        ..style = basePaint.style
        ..strokeCap = basePaint.strokeCap
        ..strokeJoin = basePaint.strokeJoin;

      canvas.save();
      canvas.translate(i * 1.0, 0);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  void _drawParticlePath(Canvas canvas, Path path, Paint basePaint) {
    final random = Random();
    final particlePaint = Paint()
      ..color = basePaint.color
      ..style = PaintingStyle.fill;

    // Extract points from path and add particles
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      for (double distance = 0; distance < metric.length; distance += 10) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final point = tangent.position;

          // Add random particles around the stroke
          for (int i = 0; i < 3; i++) {
            final particleOffset = Offset(
              point.dx + (random.nextDouble() - 0.5) * 15,
              point.dy + (random.nextDouble() - 0.5) * 15,
            );

            canvas.drawCircle(
              particleOffset,
              random.nextDouble() * 2 + 1,
              particlePaint,
            );
          }
        }
      }
    }

    // Draw the main path
    canvas.drawPath(path, basePaint);
  }

  @override
  bool shouldRepaint(AdvancedDrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke;
  }
}

// Advanced Drawing Tools Panel
class AdvancedDrawingToolsPanel extends StatefulWidget {
  final BrushType selectedBrush;
  final Color selectedColor;
  final double brushSize;
  final Effect? selectedEffect;
  final Function(BrushType) onBrushChanged;
  final Function(Color) onColorChanged;
  final Function(double) onBrushSizeChanged;
  final Function(Effect?) onEffectChanged;

  const AdvancedDrawingToolsPanel({
    super.key,
    required this.selectedBrush,
    required this.selectedColor,
    required this.brushSize,
    this.selectedEffect,
    required this.onBrushChanged,
    required this.onColorChanged,
    required this.onBrushSizeChanged,
    required this.onEffectChanged,
  });

  @override
  State<AdvancedDrawingToolsPanel> createState() =>
      _AdvancedDrawingToolsPanelState();
}

class _AdvancedDrawingToolsPanelState extends State<AdvancedDrawingToolsPanel> {
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
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Brush Selection
          const Text('Brushes', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: AdvancedDrawingTools.availableBrushes.map((brush) {
              return GestureDetector(
                onTap: () => widget.onBrushChanged(brush),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.selectedBrush == brush
                        ? Colors.blue
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getBrushIcon(brush),
                    color: widget.selectedBrush == brush
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Brush Size Slider
          const Text(
            'Brush Size',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: widget.brushSize,
            min: 1.0,
            max: 20.0,
            divisions: 19,
            label: widget.brushSize.round().toString(),
            onChanged: widget.onBrushSizeChanged,
          ),

          const SizedBox(height: 16),

          // Color Palette
          const Text('Colors', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildColorPalette(),

          const SizedBox(height: 16),

          // Effects
          const Text('Effects', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              GestureDetector(
                onTap: () => widget.onEffectChanged(null),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.selectedEffect == null
                        ? Colors.blue
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('None'),
                ),
              ),
              ...AdvancedDrawingTools.effects.map((effect) {
                return GestureDetector(
                  onTap: () => widget.onEffectChanged(effect),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.selectedEffect == effect
                          ? Colors.blue
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      effect.toString().split('.').last,
                      style: TextStyle(
                        color: widget.selectedEffect == effect
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPalette() {
    final colors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.brown,
      Colors.grey,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => widget.onColorChanged(color),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.selectedColor == color
                    ? Colors.blue
                    : Colors.grey,
                width: widget.selectedColor == color ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getBrushIcon(BrushType brush) {
    switch (brush) {
      case BrushType.pencil:
        return Icons.edit;
      case BrushType.marker:
        return Icons.brush;
      case BrushType.watercolor:
        return Icons.water_drop;
      case BrushType.spray:
        return Icons.scatter_plot;
      case BrushType.calligraphy:
        return Icons.text_fields;
      case BrushType.neon:
        return Icons.lightbulb;
      case BrushType.eraser:
        return Icons.cleaning_services;
    }
  }
}
