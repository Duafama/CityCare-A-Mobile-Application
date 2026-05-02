import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineEvent {
  String status;
  String message;
  DateTime timestamp;

  TimelineEvent({
    required this.status,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory TimelineEvent.fromMap(Map<String, dynamic> map) {
    return TimelineEvent(
      status: map['status'] as String? ?? '',
      message: map['message'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
