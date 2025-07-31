import 'package:flutter/material.dart';
import 'dart:math' as math;

class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final Color cursorColor;
  final bool isOnline;
  final DateTime lastSeen;
  final Map<String, dynamic> preferences;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.cursorColor = Colors.blue,
    this.isOnline = false,
    required this.lastSeen,
    this.preferences = const {},
  });

  // Copy constructor for updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    Color? cursorColor,
    bool? isOnline,
    DateTime? lastSeen,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      cursorColor: cursorColor ?? this.cursorColor,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      preferences: preferences ?? Map<String, dynamic>.from(this.preferences),
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'cursorColor': cursorColor.toARGB32(),
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'preferences': preferences,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'] ?? '',
      cursorColor: Color(json['cursorColor'] ?? Colors.blue.toARGB32()),
      isOnline: json['isOnline'] ?? false,
      lastSeen: DateTime.parse(json['lastSeen']),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  // Helper methods
  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
          .toUpperCase();
    } else {
      return displayName
          .substring(0, math.min(2, displayName.length))
          .toUpperCase();
    }
  }

  bool get hasAvatar => avatarUrl.isNotEmpty;

  // Status helpers
  String get statusText {
    if (isOnline) return 'Online';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 5) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return 'Offline';
  }

  Color get statusColor {
    if (isOnline) return Colors.green;

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 30) return Colors.orange;
    return Colors.grey;
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// User presence information for collaboration
class UserPresence {
  final User user;
  final Offset? cursorPosition;
  final String? currentTool;
  final DateTime lastActivity;
  final bool isActive;

  const UserPresence({
    required this.user,
    this.cursorPosition,
    this.currentTool,
    required this.lastActivity,
    this.isActive = true,
  });

  UserPresence copyWith({
    User? user,
    Offset? cursorPosition,
    String? currentTool,
    DateTime? lastActivity,
    bool? isActive,
  }) {
    return UserPresence(
      user: user ?? this.user,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      currentTool: currentTool ?? this.currentTool,
      lastActivity: lastActivity ?? this.lastActivity,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'cursorPosition': cursorPosition != null
          ? {'dx': cursorPosition!.dx, 'dy': cursorPosition!.dy}
          : null,
      'currentTool': currentTool,
      'lastActivity': lastActivity.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory UserPresence.fromJson(Map<String, dynamic> json) {
    return UserPresence(
      user: User.fromJson(json['user']),
      cursorPosition: json['cursorPosition'] != null
          ? Offset(
              json['cursorPosition']['dx'].toDouble(),
              json['cursorPosition']['dy'].toDouble(),
            )
          : null,
      currentTool: json['currentTool'],
      lastActivity: DateTime.parse(json['lastActivity']),
      isActive: json['isActive'] ?? true,
    );
  }

  bool get isRecent {
    final now = DateTime.now();
    return now.difference(lastActivity).inSeconds < 30;
  }

  @override
  String toString() {
    return 'UserPresence(user: ${user.name}, isActive: $isActive, tool: $currentTool)';
  }
}

// Comment model for collaboration
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final Offset position;
  final DateTime timestamp;
  final List<String> replies;
  final bool isResolved;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.position,
    required this.timestamp,
    this.replies = const [],
    this.isResolved = false,
  });

  Comment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? text,
    Offset? position,
    DateTime? timestamp,
    List<String>? replies,
    bool? isResolved,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      position: position ?? this.position,
      timestamp: timestamp ?? this.timestamp,
      replies: replies ?? List<String>.from(this.replies),
      isResolved: isResolved ?? this.isResolved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'text': text,
      'position': {'dx': position.dx, 'dy': position.dy},
      'timestamp': timestamp.toIso8601String(),
      'replies': replies,
      'isResolved': isResolved,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      text: json['text'],
      position: Offset(
        json['position']['dx'].toDouble(),
        json['position']['dy'].toDouble(),
      ),
      timestamp: DateTime.parse(json['timestamp']),
      replies: List<String>.from(json['replies'] ?? []),
      isResolved: json['isResolved'] ?? false,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, user: $userName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
