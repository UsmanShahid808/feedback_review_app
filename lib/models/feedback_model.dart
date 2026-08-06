import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

/// Sort orders available on the History and Admin Dashboard lists.
enum FeedbackSort { newest, oldest, highestRating, lowestRating }

extension FeedbackSortX on FeedbackSort {
  String get label {
    switch (this) {
      case FeedbackSort.newest:
        return 'Newest';
      case FeedbackSort.oldest:
        return 'Oldest';
      case FeedbackSort.highestRating:
        return 'Highest rating';
      case FeedbackSort.lowestRating:
        return 'Lowest rating';
    }
  }

  IconData get icon {
    switch (this) {
      case FeedbackSort.newest:
        return Icons.arrow_downward_rounded;
      case FeedbackSort.oldest:
        return Icons.arrow_upward_rounded;
      case FeedbackSort.highestRating:
        return Icons.trending_up_rounded;
      case FeedbackSort.lowestRating:
        return Icons.trending_down_rounded;
    }
  }
}

/// Sorts a feedback list in place-safe fashion (returns a new list)
/// according to the chosen FeedbackSort order. Shared by History and
/// the Admin Dashboard so both stay consistent.
List<FeedbackModel> sortFeedbackList(List<FeedbackModel> items, FeedbackSort sort) {
  final list = List<FeedbackModel>.from(items);
  switch (sort) {
    case FeedbackSort.newest:
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case FeedbackSort.oldest:
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case FeedbackSort.highestRating:
      list.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case FeedbackSort.lowestRating:
      list.sort((a, b) => a.rating.compareTo(b.rating));
      break;
  }
  return list;
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
  final bool isAnonymous;
  // True once the author has opened this item after an admin action
  // (reply or status change). Older documents won't have this field, so
  // it defaults to true (nothing to flag) rather than false.
  final bool seenByUser;

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
    this.isAnonymous = false,
    this.seenByUser = true,
  });

  /// What to actually display for the author's name, respecting the
  /// anonymous flag no matter who is viewing (user or admin).
  String get displayName => isAnonymous ? 'Anonymous' : userName;

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
      'isAnonymous': isAnonymous,
      'seenByUser': seenByUser,
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
      isAnonymous: map['isAnonymous'] ?? false,
      seenByUser: map['seenByUser'] ?? true,
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
