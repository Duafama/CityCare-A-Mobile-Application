import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> sendNotification({
    required String userId,
    required String complaintId,
    required String title,
    required String description,
    required String type,
    required IconData icon,
    required Color color,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'notificationId': DateTime.now().millisecondsSinceEpoch.toString(),
        'userId': userId,
        'complaintId': complaintId,
        'title': title,
        'description': description,
        'type': type,
        'icon': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
        'colorValue': color.value,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Notification sent to $userId');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }
 // lib/services/notification_service.dart mein ye function hona chahiye:
static Future<void> notifyCommentFlagged({
  required String userId,
  required String complaintId,
  required String commentText,
}) async {
  await sendNotification(
    userId: userId,
    complaintId: complaintId,
    title: 'Comment Flagged ⚠️',
    description: 'Your comment "$commentText" has been flagged for inappropriate content. Please review our community guidelines.',
    type: 'flagged',
    icon: Icons.flag,
    color: Colors.red,
  );
}
  static Future<void> notifyStatusChange({
    required String userId,
    required String complaintId,
    required String complaintTitle,
    required String oldStatus,
    required String newStatus,
  }) async {
    String title = '';
    String description = '';
    String type = '';
    IconData icon = Icons.info_outline;
    Color color = Colors.blue;

    switch (newStatus) {
      case 'Approved':
        title = '✅ Complaint Approved';
        description = 'Your complaint "$complaintTitle" has been approved and assigned to department.';
        type = 'approved';
        icon = Icons.check_circle;
        color = Colors.green;
        break;
        
      case 'In-Progress':
        title = '🔧 Work In Progress';
        description = 'Work has started on your complaint "$complaintTitle". Department is addressing the issue.';
        type = 'progress';
        icon = Icons.build_circle;
        color = Colors.orange;
        break;
        
      case 'Resolved':
        title = '🎉 Complaint Resolved';
        description = 'Your complaint "$complaintTitle" has been resolved. Thank you for your patience!';
        type = 'resolved';
        icon = Icons.verified;
        color = Colors.teal;
        break;
        
      case 'Rejected':
        title = '❌ Complaint Rejected';
        description = 'Your complaint "$complaintTitle" was rejected. Please check details and resubmit.';
        type = 'rejected';
        icon = Icons.cancel;
        color = Colors.red;
        break;
        
      default:
        title = '📢 Status Updated';
        description = 'Your complaint "$complaintTitle" status has been updated to $newStatus.';
        type = 'update';
        icon = Icons.update;
        color = Colors.blue;
    }

    await sendNotification(
      userId: userId,
      complaintId: complaintId,
      title: title,
      description: description,
      type: type,
      icon: icon,
      color: color,
    );
  }
}