import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hello! I\'m CityCare Assistant. How can I help you today?',
      isUser: false,
      time: 'Just now',
    ),
  ];
  
  final Map<String, String> _faqResponses = {
    'hello': 'Hello! Welcome to CityCare. How can I assist you today?',
    'hi': 'Hi there! How can I help you with city services?',
    'complaint': 'For complaints, please go to the "Report Issue" section and fill out the complaint form with details.',
    'report': 'You can report issues by clicking the "Report" button on the dashboard. Provide photos if possible.',
    'garbage': 'Garbage collection days: Monday & Thursday. Missed pickup? Report in the complaints section.',
    'water': 'Water supply issues? Contact the water department at 123-456-7890 or report via the app.',
    'electricity': 'Power outage? Call emergency line: 987-654-3210. For non-urgent issues, use the report section.',
    'road': 'Road maintenance complaints can be submitted with location photos in the report section.',
    'park': 'Park maintenance issues will be addressed within 48 hours of reporting.',
    'emergency': 'For emergencies, call 911 immediately.',
    'thanks': 'You\'re welcome! Is there anything else I can help you with?',
    'thank you': 'You\'re welcome! Happy to assist.',
    'bye': 'Goodbye! Stay safe and have a great day!',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'CityCare Assistant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          // Quick Action Chips
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildQuickChip('Report Issue'),
                _buildQuickChip('Complaint Status'),
                _buildQuickChip('Garbage Schedule'),
                _buildQuickChip('Emergency Contacts'),
                _buildQuickChip('Water Issues'),
              ],
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.face, color: Color(0xFF2196F3)),
                          onPressed: () => _showQuickOptions(),
                        ),
                      ),
                      onSubmitted: (value) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2196F3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
          
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: message.isUser ? 60 : 10,
                right: message.isUser ? 10 : 60,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF1A237E)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: message.isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.grey[800],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message.time,
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickChip(String text) {
    return GestureDetector(
      onTap: () => _handleQuickAction(text),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2196F3)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF2196F3),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    String userMessage = _messageController.text.trim();
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        time: _getCurrentTime(),
      ));
    });
    
    _messageController.clear();
    
    // Simulate bot response
    Future.delayed(const Duration(milliseconds: 500), () {
      String response = _getBotResponse(userMessage.toLowerCase());
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          time: _getCurrentTime(),
        ));
      });
    });
  }
  
  String _getBotResponse(String message) {
    for (var keyword in _faqResponses.keys) {
      if (message.contains(keyword)) {
        return _faqResponses[keyword]!;
      }
    }
    
    return "I understand you're asking about '$message'. For specific issues, please use the 'Report Issue' section or contact our support at support@citycare.com";
  }
  
  void _handleQuickAction(String action) {
    String response = '';
    switch (action) {
      case 'Report Issue':
        response = 'Please go to the main dashboard and click the "Report Issue" button. You can upload photos and describe the problem.';
        break;
      case 'Complaint Status':
        response = 'Check your complaint status in the "My Complaints" section. You\'ll see updates there.';
        break;
      case 'Garbage Schedule':
        response = 'Garbage collection: Monday & Thursday (8 AM - 4 PM). Recycling: Friday. Please separate waste.';
        break;
      case 'Emergency Contacts':
        response = 'Emergency: 911\nWater Dept: 123-456-7890\nElectricity: 987-654-3210\nCity Hall: 555-0123';
        break;
      case 'Water Issues':
        response = 'Water supply issues? Check if there\'s scheduled maintenance in your area. Report leaks immediately.';
        break;
    }
    
    setState(() {
      _messages.add(ChatMessage(
        text: action,
        isUser: true,
        time: _getCurrentTime(),
      ));
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        time: _getCurrentTime(),
      ));
    });
  }
  
  void _showQuickOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildOptionChip('How to report?'),
                _buildOptionChip('Garbage schedule'),
                _buildOptionChip('Water bill'),
                _buildOptionChip('Road repair'),
                _buildOptionChip('Park maintenance'),
                _buildOptionChip('Contact numbers'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionChip(String text) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _handleQuickAction(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F4FD),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF1A237E),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
  
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}