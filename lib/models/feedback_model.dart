import 'package:cloud_firestore/cloud_firestore.dart';

/// Category a piece of feedback belongs to.
enum FeedbackCategory { task, course, service }

extension FeedbackCategoryX on FeedbackCategory {
  String get label {
    switch (this) {
      case FeedbackCategory.task:
        return 'Task';
      case FeedbackCategory.course:
        return 'Course';
      case FeedbackCategory.service:
        return 'Service';
    }
  }

  static FeedbackCategory fromString(String value) {
    return FeedbackCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FeedbackCategory.task,
    );
  }
}

enum FeedbackStatus { pending, reviewed, resolved }

extension FeedbackStatusX on FeedbackStatus {
  String get label {
    switch (this) {
      case FeedbackStatus.pending:
        return 'Pending';
      case FeedbackStatus.reviewed:
        return 'Reviewed';
      case FeedbackStatus.resolved:
        return 'Resolved';
    }
  }

  static FeedbackStatus fromString(String value) {
    return FeedbackStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FeedbackStatus.pending,
    );
  }
}

class FeedbackModel {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String message;
  final double rating; // 1..5
  final FeedbackCategory category;
  final FeedbackStatus status;
  final DateTime createdAt;
  final String? adminReply;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.message,
    required this.rating,
    required this.category,
    this.status = FeedbackStatus.pending,
    required this.createdAt,
    this.adminReply,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'title': title,
      'message': message,
      'rating': rating,
      'category': category.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'adminReply': adminReply,
    };
  }

  factory FeedbackModel.fromMap(String id, Map<String, dynamic> map) {
    return FeedbackModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      category: FeedbackCategoryX.fromString(map['category'] ?? 'task'),
      status: FeedbackStatusX.fromString(map['status'] ?? 'pending'),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      adminReply: map['adminReply'],
    );
  }
}

class AppUser {
  final String uid;
  final String name;
  final String email;
  final bool isAdmin;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'isAdmin': isAdmin,
      };

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
    );
  }
}
