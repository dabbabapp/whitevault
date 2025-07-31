// Advanced Collaboration Features - Stub Implementation (No Firebase)
import 'dart:async';
import '../models/canvas_element.dart';

// Stub class for collaboration comment
class CollabComment {
  final String userId;
  final String text;
  final DateTime timestamp;

  CollabComment({
    required this.userId,
    required this.text,
    required this.timestamp,
  });
}

class CollaborationService {
  static const int maxUsersPerCanvas = 10;

  // Static stream controllers for stub implementation
  static final StreamController<List<CollabComment>> _commentsController =
      StreamController<List<CollabComment>>.broadcast();

  static Stream<List<CollabComment>> get commentsStream =>
      _commentsController.stream;

  static Future<void> joinCanvas(String canvasId) async {
    // Stub implementation - just print for now
    print('User joined canvas $canvasId');
  }

  static Future<void> leaveCanvas() async {
    // Stub implementation
    print('User left canvas');
  }

  static Future<void> updateCanvas(List<CanvasElement> elements) async {
    // Stub implementation - could save to local storage instead
    print('Canvas updated with ${elements.length} elements');
  }

  static Future<void> addComment(String canvasId, String text) async {
    final comment = CollabComment(
      userId: 'Anonymous',
      text: text,
      timestamp: DateTime.now(),
    );

    // For now, just add to a local list (in real implementation, would save to Firestore)
    print('Comment added: ${comment.text}');
  }

  static void dispose() {
    _commentsController.close();
  }
}
