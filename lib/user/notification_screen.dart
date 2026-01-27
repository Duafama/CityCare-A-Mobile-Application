import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Complaint in Progress',
      description: 'Your "Broken Streetlight" complaint is being addressed by the related department.',
      time: '5 min ago',
      type: 'progress',
      isRead: false,
      icon: Icons.hourglass_bottom,
      color: Colors.orange,
    ),
    NotificationItem(
      title: 'Complaint Approved',
      description: 'Your "Water Leak" complaint has been approved by admin.',
      time: '13 min ago',
      type: 'approved',
      isRead: false,
      icon: Icons.check_circle,
      color: Colors.green,
    ),
    NotificationItem(
      title: 'Complaint Resolved',
      description: 'Your "Pothole on Main street" complaint has been resolved.',
      time: '1 hour ago',
      type: 'resolved',
      isRead: true,
      icon: Icons.verified,
      color: Colors.blue,
    ),
    NotificationItem(
      title: 'Complaint Assigned',
      description: 'Your "Overflowing Garbage" complaint assigned to sanitation department.',
      time: '3 hours ago',
      type: 'assigned',
      isRead: false,
      icon: Icons.assignment_turned_in,
      color: Colors.purple,
    ),
    NotificationItem(
      title: 'New Message',
      description: 'Department sent a message regarding complaint #CT-2024-789',
      time: '5 hours ago',
      type: 'message',
      isRead: true,
      icon: Icons.message,
      color: Colors.teal,
    ),
    NotificationItem(
      title: 'Weekly Report',
      description: 'Your weekly complaint summary: 3 complaints resolved.',
      time: '1 day ago',
      type: 'report',
      isRead: true,
      icon: Icons.summarize,
      color: Colors.indigo,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F1A3D),
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all, size: 22),
            tooltip: 'Mark all as read',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index]);
              },
            ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Material(
      color: notification.isRead ? Colors.white : const Color(0xFFf0f7ff),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _onNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade200
                  : const Color(0xFF4A6FFF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: notification.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    notification.icon,
                    color: notification.color,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                                  color: const Color(0xFF0F1A3D),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(left: 4, top: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A6FFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: notification.color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            notification.type.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: notification.color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          notification.time,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 45,
              color: Color(0xFF4A6FFF),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Notifications',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F1A3D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'All notifications marked as read',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF0F1A3D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class NotificationItem {
  String title;
  String description;
  String time;
  String type;
  bool isRead;
  IconData icon;
  Color color;

  NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    required this.isRead,
    required this.icon,
    required this.color,
  });
}