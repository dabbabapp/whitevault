import 'package:flutter/material.dart';
import 'dart:math' as math;

enum ElementType { drawing, text, shape, image, stickyNote, voice, template }

class CanvasElement {
  final String id;
  final ElementType type;
  final Offset position;
  final double rotation;
  final double scale;
  final Map<String, dynamic> properties;
  final DateTime timestamp;
  final String userId;

  CanvasElement({
    required this.id,
    required this.type,
    required this.position,
    this.rotation = 0.0,
    this.scale = 1.0,
    required this.properties,
    required this.timestamp,
    required this.userId,
  });

  // Copy constructor for modifications
  CanvasElement copyWith({
    String? id,
    ElementType? type,
    Offset? position,
    double? rotation,
    double? scale,
    Map<String, dynamic>? properties,
    DateTime? timestamp,
    String? userId,
  }) {
    return CanvasElement(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      properties: properties ?? Map<String, dynamic>.from(this.properties),
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'position': {'dx': position.dx, 'dy': position.dy},
      'rotation': rotation,
      'scale': scale,
      'properties': properties,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  factory CanvasElement.fromJson(Map<String, dynamic> json) {
    return CanvasElement(
      id: json['id'],
      type: ElementType.values[json['type']],
      position: Offset(
        json['position']['dx'].toDouble(),
        json['position']['dy'].toDouble(),
      ),
      rotation: json['rotation']?.toDouble() ?? 0.0,
      scale: json['scale']?.toDouble() ?? 1.0,
      properties: Map<String, dynamic>.from(json['properties']),
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
    );
  }

  // Helper methods for specific element types
  static CanvasElement createDrawing({
    required String id,
    required List<Offset> points,
    required Color color,
    required double strokeWidth,
    required String userId,
    String brushType = 'pencil',
    String? effect,
  }) {
    return CanvasElement(
      id: id,
      type: ElementType.drawing,
      position: points.isNotEmpty ? points.first : Offset.zero,
      properties: {
        'points': points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
        'color': color.toARGB32(),
        'strokeWidth': strokeWidth,
        'brushType': brushType,
        'effect': effect,
      },
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  static CanvasElement createText({
    required String id,
    required String text,
    required Offset position,
    required Color color,
    required double fontSize,
    required String userId,
    String fontFamily = 'Default',
    bool isBold = false,
    bool isItalic = false,
  }) {
    return CanvasElement(
      id: id,
      type: ElementType.text,
      position: position,
      properties: {
        'text': text,
        'color': color.toARGB32(),
        'fontSize': fontSize,
        'fontFamily': fontFamily,
        'isBold': isBold,
        'isItalic': isItalic,
      },
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  static CanvasElement createShape({
    required String id,
    required String shapeType,
    required Offset position,
    required Size size,
    required Color color,
    required String userId,
    double strokeWidth = 2.0,
    bool filled = false,
  }) {
    return CanvasElement(
      id: id,
      type: ElementType.shape,
      position: position,
      properties: {
        'shapeType': shapeType,
        'size': {'width': size.width, 'height': size.height},
        'color': color.toARGB32(),
        'strokeWidth': strokeWidth,
        'filled': filled,
      },
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  static CanvasElement createStickyNote({
    required String id,
    required String text,
    required Offset position,
    required Color backgroundColor,
    required String userId,
    Size size = const Size(150, 150),
  }) {
    return CanvasElement(
      id: id,
      type: ElementType.stickyNote,
      position: position,
      properties: {
        'text': text,
        'backgroundColor': backgroundColor.toARGB32(),
        'size': {'width': size.width, 'height': size.height},
        'textColor': Colors.black.toARGB32(),
      },
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  // Getters for common properties
  Color get color {
    final colorValue = properties['color'] as int?;
    return colorValue != null ? Color(colorValue) : Colors.black;
  }

  String get text => properties['text'] as String? ?? '';

  List<Offset> get points {
    final pointsData = properties['points'] as List?;
    if (pointsData == null) return [];
    return pointsData
        .map((p) => Offset(p['dx'].toDouble(), p['dy'].toDouble()))
        .toList();
  }

  Size get size {
    final sizeData = properties['size'] as Map<String, dynamic>?;
    if (sizeData == null) return Size.zero;
    return Size(sizeData['width'].toDouble(), sizeData['height'].toDouble());
  }

  double get strokeWidth => properties['strokeWidth']?.toDouble() ?? 2.0;
  double get fontSize => properties['fontSize']?.toDouble() ?? 14.0;
  String get shapeType => properties['shapeType'] as String? ?? 'rectangle';
  String get brushType => properties['brushType'] as String? ?? 'pencil';
  String? get effect => properties['effect'] as String?;
  bool get filled => properties['filled'] as bool? ?? false;

  // Bounds calculation
  Rect get bounds {
    switch (type) {
      case ElementType.drawing:
        if (points.isEmpty) return Rect.zero;
        double minX = points.first.dx;
        double minY = points.first.dy;
        double maxX = points.first.dx;
        double maxY = points.first.dy;

        for (final point in points) {
          minX = math.min(minX, point.dx);
          minY = math.min(minY, point.dy);
          maxX = math.max(maxX, point.dx);
          maxY = math.max(maxY, point.dy);
        }

        return Rect.fromLTRB(minX, minY, maxX, maxY);

      case ElementType.text:
        // Approximate text bounds based on fontSize
        final textLength = text.length;
        final estimatedWidth = textLength * fontSize * 0.6;
        final estimatedHeight = fontSize * 1.2;
        return Rect.fromLTWH(
          position.dx,
          position.dy,
          estimatedWidth,
          estimatedHeight,
        );

      default:
        return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
    }
  }

  // Check if point is inside element
  bool containsPoint(Offset point) {
    return bounds.contains(point);
  }

  @override
  String toString() {
    return 'CanvasElement(id: $id, type: $type, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CanvasElement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
