// Gesture Recognition & Smart Features - Making WhiteVault Intelligent
import 'dart:math';
import 'package:flutter/material.dart';

class GestureRecognitionEngine {
  // 🎯 SHAPE DETECTION FROM DRAWINGS
  static ShapeType detectShape(List<Offset> points) {
    if (points.length < 10) return ShapeType.unknown;

    final boundingBox = _calculateBoundingBox(points);
    final aspectRatio = boundingBox.width / boundingBox.height;

    // Calculate if it's a closed shape
    final startPoint = points.first;
    final endPoint = points.last;
    final distance = (endPoint - startPoint).distance;
    final isClosed = distance < 30;

    if (isClosed) {
      // Detect circles vs squares/rectangles
      final circularity = _calculateCircularity(points, boundingBox);

      if (circularity > 0.8) {
        return ShapeType.circle;
      } else if (aspectRatio > 0.8 && aspectRatio < 1.2) {
        return ShapeType.square;
      } else {
        return ShapeType.rectangle;
      }
    } else {
      // Detect lines and arrows
      if (_isLine(points)) {
        if (_hasArrowHead(points)) {
          return ShapeType.arrow;
        }
        return ShapeType.line;
      }
    }

    return ShapeType.freehand;
  }

  // ✋ GESTURE COMMANDS
  static GestureCommand detectGesture(List<Offset> points) {
    if (points.length < 5) return GestureCommand.none;

    final gestureVector = _calculateGestureVector(points);
    final gestureLength = _calculateGestureLength(points);

    // Detect specific gestures
    if (_isCheckMark(points)) return GestureCommand.confirm;
    if (_isX(points)) return GestureCommand.delete;
    if (_isCircle(points)) return GestureCommand.select;
    if (_isZigZag(points)) return GestureCommand.erase;
    if (_isDoubleTab(points)) return GestureCommand.duplicate;

    // Direction-based gestures
    if (gestureLength > 100) {
      final angle = atan2(gestureVector.dy, gestureVector.dx);
      if (angle > -pi / 4 && angle < pi / 4) return GestureCommand.moveRight;
      if (angle > pi / 4 && angle < 3 * pi / 4) return GestureCommand.moveDown;
      if (angle > 3 * pi / 4 || angle < -3 * pi / 4) {
        return GestureCommand.moveLeft;
      }
      if (angle > -3 * pi / 4 && angle < -pi / 4) return GestureCommand.moveUp;
    }

    return GestureCommand.none;
  }

  // 🔍 TEXT RECOGNITION (PLACEHOLDER FOR OCR)
  static String recognizeText(List<Offset> handwritingPoints) {
    // This would integrate with a handwriting recognition API
    // For now, return placeholder
    return 'Recognized text would appear here';
  }

  // 🎨 AUTO-BEAUTIFY DRAWINGS
  static List<Offset> beautifyShape(
    List<Offset> originalPoints,
    ShapeType detectedShape,
  ) {
    switch (detectedShape) {
      case ShapeType.circle:
        return _createPerfectCircle(originalPoints);
      case ShapeType.square:
        return _createPerfectSquare(originalPoints);
      case ShapeType.rectangle:
        return _createPerfectRectangle(originalPoints);
      case ShapeType.line:
        return _createPerfectLine(originalPoints);
      case ShapeType.arrow:
        return _createPerfectArrow(originalPoints);
      default:
        return originalPoints;
    }
  }

  // Private helper methods
  static Rect _calculateBoundingBox(List<Offset> points) {
    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (final point in points) {
      if (point.dx < minX) minX = point.dx;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dy > maxY) maxY = point.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  static double _calculateCircularity(List<Offset> points, Rect boundingBox) {
    final center = boundingBox.center;
    final radius = min(boundingBox.width, boundingBox.height) / 2;

    double totalDeviation = 0;
    for (final point in points) {
      final distance = (point - center).distance;
      totalDeviation += (distance - radius).abs();
    }

    final averageDeviation = totalDeviation / points.length;
    return 1.0 - (averageDeviation / radius).clamp(0.0, 1.0);
  }

  static bool _isLine(List<Offset> points) {
    if (points.length < 3) return true;

    final start = points.first;
    final end = points.last;

    double totalDeviation = 0;
    for (final point in points) {
      final distanceToLine = _pointToLineDistance(point, start, end);
      totalDeviation += distanceToLine;
    }

    final averageDeviation = totalDeviation / points.length;
    return averageDeviation < 15; // Threshold for line detection
  }

  static double _pointToLineDistance(
    Offset point,
    Offset lineStart,
    Offset lineEnd,
  ) {
    final A = point.dx - lineStart.dx;
    final B = point.dy - lineStart.dy;
    final C = lineEnd.dx - lineStart.dx;
    final D = lineEnd.dy - lineStart.dy;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;

    if (lenSq == 0) return (point - lineStart).distance;

    final param = dot / lenSq;

    Offset xx;
    if (param < 0) {
      xx = lineStart;
    } else if (param > 1) {
      xx = lineEnd;
    } else {
      xx = Offset(lineStart.dx + param * C, lineStart.dy + param * D);
    }

    return (point - xx).distance;
  }

  static bool _hasArrowHead(List<Offset> points) {
    if (points.length < 10) return false;

    // Check if the last few points form an arrow head pattern
    final lastPoints = points.sublist(points.length - 10);

    // Simple arrow head detection - check for sudden direction changes
    for (int i = 1; i < lastPoints.length - 1; i++) {
      final prev = lastPoints[i - 1];
      final curr = lastPoints[i];
      final next = lastPoints[i + 1];

      final angle1 = atan2(curr.dy - prev.dy, curr.dx - prev.dx);
      final angle2 = atan2(next.dy - curr.dy, next.dx - curr.dx);

      final angleDiff = (angle2 - angle1).abs();
      if (angleDiff > pi / 3 && angleDiff < 2 * pi / 3) {
        return true;
      }
    }

    return false;
  }

  static Offset _calculateGestureVector(List<Offset> points) {
    return points.last - points.first;
  }

  static double _calculateGestureLength(List<Offset> points) {
    double length = 0;
    for (int i = 1; i < points.length; i++) {
      length += (points[i] - points[i - 1]).distance;
    }
    return length;
  }

  static bool _isCheckMark(List<Offset> points) {
    // Simplified check mark detection
    if (points.length < 20) return false;

    final midIndex = points.length ~/ 2;
    final start = points.first;
    final mid = points[midIndex];
    final end = points.last;

    // Check if it forms a V shape (check mark)
    final firstHalfSlope = (mid.dy - start.dy) / (mid.dx - start.dx);
    final secondHalfSlope = (end.dy - mid.dy) / (end.dx - mid.dx);

    return firstHalfSlope > 0.5 && secondHalfSlope < -0.5;
  }

  static bool _isX(List<Offset> points) {
    // Simplified X detection - look for crossing pattern
    if (points.length < 30) return false;

    final boundingBox = _calculateBoundingBox(points);
    final center = boundingBox.center;

    // Check if points cross the center area multiple times
    int centerCrossings = 0;
    final tolerance = min(boundingBox.width, boundingBox.height) * 0.1;

    for (final point in points) {
      if ((point - center).distance < tolerance) {
        centerCrossings++;
      }
    }

    return centerCrossings > 3;
  }

  static bool _isCircle(List<Offset> points) {
    if (points.length < 20) return false;

    final boundingBox = _calculateBoundingBox(points);
    final circularity = _calculateCircularity(points, boundingBox);

    // Check if start and end points are close (closed shape)
    final closure = (points.last - points.first).distance;

    return circularity > 0.7 && closure < 30;
  }

  static bool _isZigZag(List<Offset> points) {
    if (points.length < 15) return false;

    int directionChanges = 0;
    double lastSlope = 0;

    for (int i = 2; i < points.length; i++) {
      final current = points[i];
      final prev = points[i - 1];

      if (prev.dx != current.dx) {
        final currentSlope = (current.dy - prev.dy) / (current.dx - prev.dx);

        if (i > 2 && (currentSlope > 0) != (lastSlope > 0)) {
          directionChanges++;
        }

        lastSlope = currentSlope;
      }
    }

    return directionChanges > 4;
  }

  static bool _isDoubleTab(List<Offset> points) {
    // This would be detected at a higher level based on timing and position
    // For now, detect rapid back-and-forth motion
    if (points.length < 10) return false;

    final start = points.first;
    final end = points.last;
    final distance = (end - start).distance;

    return distance < 20; // Very small movement indicates a tap
  }

  // Shape beautification methods
  static List<Offset> _createPerfectCircle(List<Offset> originalPoints) {
    final boundingBox = _calculateBoundingBox(originalPoints);
    final center = boundingBox.center;
    final radius = min(boundingBox.width, boundingBox.height) / 2;

    final perfectCircle = <Offset>[];
    const steps = 64;

    for (int i = 0; i < steps; i++) {
      final angle = (i / steps) * 2 * pi;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      perfectCircle.add(Offset(x, y));
    }

    return perfectCircle;
  }

  static List<Offset> _createPerfectSquare(List<Offset> originalPoints) {
    final boundingBox = _calculateBoundingBox(originalPoints);
    final size = min(boundingBox.width, boundingBox.height);
    final center = boundingBox.center;
    final halfSize = size / 2;

    return [
      Offset(center.dx - halfSize, center.dy - halfSize), // Top-left
      Offset(center.dx + halfSize, center.dy - halfSize), // Top-right
      Offset(center.dx + halfSize, center.dy + halfSize), // Bottom-right
      Offset(center.dx - halfSize, center.dy + halfSize), // Bottom-left
      Offset(center.dx - halfSize, center.dy - halfSize), // Close the square
    ];
  }

  static List<Offset> _createPerfectRectangle(List<Offset> originalPoints) {
    final boundingBox = _calculateBoundingBox(originalPoints);

    return [
      boundingBox.topLeft,
      boundingBox.topRight,
      boundingBox.bottomRight,
      boundingBox.bottomLeft,
      boundingBox.topLeft, // Close the rectangle
    ];
  }

  static List<Offset> _createPerfectLine(List<Offset> originalPoints) {
    final start = originalPoints.first;
    final end = originalPoints.last;

    return [start, end];
  }

  static List<Offset> _createPerfectArrow(List<Offset> originalPoints) {
    final perfectLine = _createPerfectLine(originalPoints);
    final start = perfectLine.first;
    final end = perfectLine.last;

    // Calculate arrow head
    final direction = (end - start);
    final angle = atan2(direction.dy, direction.dx);
    const arrowLength = 20.0;
    const arrowAngle = pi / 6; // 30 degrees

    final arrowHead1 = Offset(
      end.dx - arrowLength * cos(angle - arrowAngle),
      end.dy - arrowLength * sin(angle - arrowAngle),
    );

    final arrowHead2 = Offset(
      end.dx - arrowLength * cos(angle + arrowAngle),
      end.dy - arrowLength * sin(angle + arrowAngle),
    );

    return [start, end, arrowHead1, end, arrowHead2];
  }
}

// Enums
enum ShapeType {
  unknown,
  circle,
  square,
  rectangle,
  line,
  arrow,
  triangle,
  freehand,
}

enum GestureCommand {
  none,
  confirm,
  delete,
  select,
  erase,
  duplicate,
  moveUp,
  moveDown,
  moveLeft,
  moveRight,
}

// Smart Canvas with Gesture Recognition
class SmartGestureCanvas extends StatefulWidget {
  final Function(ShapeType, List<Offset>)? onShapeDetected;
  final Function(GestureCommand)? onGestureDetected;
  final bool autoBeautify;

  const SmartGestureCanvas({
    super.key,
    this.onShapeDetected,
    this.onGestureDetected,
    this.autoBeautify = true,
  });

  @override
  State<SmartGestureCanvas> createState() => _SmartGestureCanvasState();
}

class _SmartGestureCanvasState extends State<SmartGestureCanvas> {
  List<Offset> _currentStroke = [];
  final List<List<Offset>> _strokes = [];
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: CustomPaint(
          painter: SmartCanvasPainter(_strokes, _currentStroke),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _currentStroke = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDrawing) {
      setState(() {
        _currentStroke.add(details.localPosition);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isDrawing && _currentStroke.isNotEmpty) {
      _processStroke(_currentStroke);

      setState(() {
        _strokes.add(_currentStroke);
        _currentStroke = [];
        _isDrawing = false;
      });
    }
  }

  void _processStroke(List<Offset> stroke) {
    // Detect shape
    final detectedShape = GestureRecognitionEngine.detectShape(stroke);

    // Detect gesture
    final detectedGesture = GestureRecognitionEngine.detectGesture(stroke);

    // Auto-beautify if enabled
    List<Offset> finalStroke = stroke;
    if (widget.autoBeautify && detectedShape != ShapeType.freehand) {
      finalStroke = GestureRecognitionEngine.beautifyShape(
        stroke,
        detectedShape,
      );
    }

    // Notify callbacks
    if (widget.onShapeDetected != null) {
      widget.onShapeDetected!(detectedShape, finalStroke);
    }

    if (widget.onGestureDetected != null &&
        detectedGesture != GestureCommand.none) {
      widget.onGestureDetected!(detectedGesture);
    }

    // Update the stroke with beautified version
    if (widget.autoBeautify && finalStroke != stroke) {
      _currentStroke = finalStroke;
    }
  }
}

// Custom painter for the smart canvas
class SmartCanvasPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  SmartCanvasPainter(this.strokes, this.currentStroke);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }

    // Draw current stroke
    if (currentStroke.isNotEmpty) {
      final currentPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      _drawStroke(canvas, currentStroke, currentPaint);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> stroke, Paint paint) {
    if (stroke.length < 2) return;

    final path = Path();
    path.moveTo(stroke[0].dx, stroke[0].dy);

    for (int i = 1; i < stroke.length; i++) {
      path.lineTo(stroke[i].dx, stroke[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SmartCanvasPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke;
  }
}

// Gesture Feedback Widget
class GestureFeedbackWidget extends StatefulWidget {
  final GestureCommand? lastGesture;
  final ShapeType? lastShape;

  const GestureFeedbackWidget({super.key, this.lastGesture, this.lastShape});

  @override
  State<GestureFeedbackWidget> createState() => _GestureFeedbackWidgetState();
}

class _GestureFeedbackWidgetState extends State<GestureFeedbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(GestureFeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastGesture != oldWidget.lastGesture ||
        widget.lastShape != oldWidget.lastShape) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lastGesture == null && widget.lastShape == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 50,
      right: 20,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getIconForFeedback(), color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _getTextForFeedback(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForFeedback() {
    if (widget.lastGesture != null) {
      switch (widget.lastGesture!) {
        case GestureCommand.confirm:
          return Icons.check;
        case GestureCommand.delete:
          return Icons.delete;
        case GestureCommand.select:
          return Icons.radio_button_checked;
        case GestureCommand.erase:
          return Icons.cleaning_services;
        case GestureCommand.duplicate:
          return Icons.content_copy;
        default:
          return Icons.touch_app;
      }
    }

    if (widget.lastShape != null) {
      switch (widget.lastShape!) {
        case ShapeType.circle:
          return Icons.circle_outlined;
        case ShapeType.square:
          return Icons.crop_square;
        case ShapeType.rectangle:
          return Icons.rectangle_outlined;
        case ShapeType.line:
          return Icons.remove;
        case ShapeType.arrow:
          return Icons.arrow_forward;
        default:
          return Icons.brush;
      }
    }

    return Icons.touch_app;
  }

  String _getTextForFeedback() {
    if (widget.lastGesture != null) {
      switch (widget.lastGesture!) {
        case GestureCommand.confirm:
          return 'Confirmed';
        case GestureCommand.delete:
          return 'Delete gesture';
        case GestureCommand.select:
          return 'Selected';
        case GestureCommand.erase:
          return 'Erase gesture';
        case GestureCommand.duplicate:
          return 'Duplicate';
        default:
          return 'Gesture detected';
      }
    }

    if (widget.lastShape != null) {
      switch (widget.lastShape!) {
        case ShapeType.circle:
          return 'Circle detected';
        case ShapeType.square:
          return 'Square detected';
        case ShapeType.rectangle:
          return 'Rectangle detected';
        case ShapeType.line:
          return 'Line detected';
        case ShapeType.arrow:
          return 'Arrow detected';
        default:
          return 'Shape detected';
      }
    }

    return '';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
