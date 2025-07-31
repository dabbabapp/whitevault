import 'package:flutter/material.dart';
import '../models/canvas_element.dart';

class DrawCanvas extends StatefulWidget {
  final List<CanvasElement> elements;
  final Color selectedColor;
  final double strokeWidth;
  final String selectedTool;
  final Function(List<CanvasElement>) onElementsChanged;

  const DrawCanvas({
    super.key,
    required this.elements,
    required this.selectedColor,
    required this.strokeWidth,
    required this.selectedTool,
    required this.onElementsChanged,
  });

  @override
  State<DrawCanvas> createState() => _DrawCanvasState();
}

class _DrawCanvasState extends State<DrawCanvas> {
  List<Offset> _currentDrawing = [];
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: DrawCanvasPainter(
          elements: widget.elements,
          currentDrawing: _currentDrawing,
          currentColor: widget.selectedColor,
          currentStrokeWidth: widget.strokeWidth,
          isDrawing: _isDrawing,
        ),
        size: Size.infinite,
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.selectedTool == 'pen' || widget.selectedTool == 'pencil') {
      setState(() {
        _isDrawing = true;
        _currentDrawing = [details.localPosition];
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDrawing &&
        (widget.selectedTool == 'pen' || widget.selectedTool == 'pencil')) {
      setState(() {
        _currentDrawing.add(details.localPosition);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isDrawing && _currentDrawing.isNotEmpty) {
      final newElement = CanvasElement.createDrawing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        points: _currentDrawing,
        color: widget.selectedColor,
        strokeWidth: widget.strokeWidth,
        userId: 'current_user', // You can pass this from parent
      );

      final updatedElements = [...widget.elements, newElement];
      widget.onElementsChanged(updatedElements);

      setState(() {
        _isDrawing = false;
        _currentDrawing = [];
      });
    }
  }
}

class DrawCanvasPainter extends CustomPainter {
  final List<CanvasElement> elements;
  final List<Offset> currentDrawing;
  final Color currentColor;
  final double currentStrokeWidth;
  final bool isDrawing;

  DrawCanvasPainter({
    required this.elements,
    required this.currentDrawing,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.isDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw existing elements
    for (final element in elements) {
      _drawElement(canvas, element);
    }

    // Draw current drawing
    if (isDrawing && currentDrawing.isNotEmpty) {
      _drawPoints(canvas, currentDrawing, currentColor, currentStrokeWidth);
    }
  }

  void _drawElement(Canvas canvas, CanvasElement element) {
    switch (element.type) {
      case ElementType.drawing:
        _drawPoints(canvas, element.points, element.color, element.strokeWidth);
        break;
      case ElementType.text:
        _drawText(canvas, element);
        break;
      case ElementType.shape:
        _drawShape(canvas, element);
        break;
      case ElementType.stickyNote:
        _drawStickyNote(canvas, element);
        break;
      default:
        break;
    }
  }

  void _drawPoints(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double strokeWidth,
  ) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, CanvasElement element) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: element.text,
        style: TextStyle(color: element.color, fontSize: element.fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, element.position);
  }

  void _drawShape(Canvas canvas, CanvasElement element) {
    final paint = Paint()
      ..color = element.color
      ..strokeWidth = element.strokeWidth
      ..style = element.filled ? PaintingStyle.fill : PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      element.position.dx,
      element.position.dy,
      element.size.width,
      element.size.height,
    );

    switch (element.shapeType) {
      case 'rectangle':
        canvas.drawRect(rect, paint);
        break;
      case 'circle':
        canvas.drawOval(rect, paint);
        break;
      case 'line':
        canvas.drawLine(
          element.position,
          Offset(
            element.position.dx + element.size.width,
            element.position.dy + element.size.height,
          ),
          paint,
        );
        break;
    }
  }

  void _drawStickyNote(Canvas canvas, CanvasElement element) {
    final rect = Rect.fromLTWH(
      element.position.dx,
      element.position.dy,
      element.size.width,
      element.size.height,
    );

    // Background
    final backgroundPaint = Paint()
      ..color = Color(element.properties['backgroundColor'] as int)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      backgroundPaint,
    );

    // Border
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      borderPaint,
    );

    // Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: element.text,
        style: TextStyle(
          color: Color(element.properties['textColor'] as int),
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    textPainter.layout(maxWidth: element.size.width - 16);
    textPainter.paint(
      canvas,
      Offset(element.position.dx + 8, element.position.dy + 8),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
