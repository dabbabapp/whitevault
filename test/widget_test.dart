// WhiteVault tests.
//
// Tests for the WhiteVault collaborative whiteboard application components.

import 'package:flutter_test/flutter_test.dart';
import 'package:whitevault/models/canvas_element.dart';
import 'package:flutter/material.dart';

void main() {
  group('CanvasElement', () {
    test('creates drawing element with required parameters', () {
      final element = CanvasElement.createDrawing(
        id: 'test-id',
        points: [const Offset(0, 0), const Offset(10, 10)],
        color: Colors.black,
        strokeWidth: 2.0,
        userId: 'test-user',
      );

      expect(element.id, equals('test-id'));
      expect(element.type, equals(ElementType.drawing));
      expect(element.points.length, equals(2));
    });

    test('creates text element with required parameters', () {
      final element = CanvasElement.createText(
        id: 'text-id',
        text: 'Test text',
        position: const Offset(10, 20),
        color: Colors.blue,
        fontSize: 16.0,
        userId: 'test-user',
      );

      expect(element.id, equals('text-id'));
      expect(element.type, equals(ElementType.text));
      expect(element.text, equals('Test text'));
      expect(element.position, equals(const Offset(10, 20)));
    });

    test('creates element from JSON', () {
      final json = {
        'id': 'test-id',
        'type': 0, // ElementType.drawing index
        'position': {'dx': 5.0, 'dy': 10.0},
        'rotation': 0.0,
        'scale': 1.0,
        'properties': {
          'points': [
            {'dx': 0.0, 'dy': 0.0},
            {'dx': 10.0, 'dy': 10.0},
          ],
          'color': Colors.black.toARGB32(),
          'strokeWidth': 2.0,
        },
        'timestamp': DateTime.now().toIso8601String(),
        'userId': 'test-user',
      };

      final element = CanvasElement.fromJson(json);
      expect(element.id, equals('test-id'));
      expect(element.type, equals(ElementType.drawing));
    });

    test('serializes and deserializes correctly', () {
      final original = CanvasElement.createShape(
        id: 'shape-id',
        shapeType: 'rectangle',
        position: const Offset(15, 25),
        size: const Size(100, 50),
        color: Colors.red,
        userId: 'test-user',
      );

      final json = original.toJson();
      final restored = CanvasElement.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.type, equals(original.type));
      expect(restored.position, equals(original.position));
      expect(restored.size, equals(original.size));
    });
  });
}
