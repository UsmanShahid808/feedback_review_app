import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';

/// Handles all Firestore reads/writes for the `feedback` collection.
/// Everything here streams in real time so both the user's list and the
/// admin dashboard update live as new feedback comes in.
class FeedbackService {
  final CollectionReference _col =
      FirebaseFirestore.instance.collection('feedback');

  Future<void> submitFeedback(FeedbackModel feedback) async {
    await _col.add(feedback.toMap());
  }

  /// Live stream of feedback submitted by a specific user.
  Stream<List<FeedbackModel>> streamUserFeedback(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FeedbackModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  /// Live stream of ALL feedback, for the admin dashboard.
  Stream<List<FeedbackModel>> streamAllFeedback() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
        (snap) => snap.docs
            .map((d) => FeedbackModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> updateStatus(String feedbackId, FeedbackStatus status) async {
    // Flip seenByUser to false so the author notices their status
    // changed, mirroring what happens on a reply below.
    await _col.doc(feedbackId).update({
      'status': status.name,
      'seenByUser': false,
    });
  }

  Future<void> addAdminReply(String feedbackId, String reply) async {
    await _col.doc(feedbackId).update({
      'adminReply': reply,
      'status': FeedbackStatus.reviewed.name,
      'seenByUser': false,
    });
  }

  /// Called when the author opens a feedback item that has an unseen
  /// admin update, so the "New" badge clears.
  Future<void> markSeen(String feedbackId) async {
    await _col.doc(feedbackId).update({'seenByUser': true});
  }

  Future<void> deleteFeedback(String feedbackId) async {
    await _col.doc(feedbackId).delete();
  }

  /// Lets the original author edit their own feedback (title/message/
  /// rating/category) - only allowed while it's still Pending, both here
  /// and enforced server-side in firestore.rules.
  Future<void> updateFeedback({
    required String feedbackId,
    required String title,
    required String message,
    required double rating,
    required FeedbackCategory category,
  }) async {
    await _col.doc(feedbackId).update({
      'title': title,
      'message': message,
      'rating': rating,
      'category': category.name,
    });
  }
}
