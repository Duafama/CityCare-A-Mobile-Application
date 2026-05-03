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
    'complaint': 'For complaints, please go to the "Submit" section on the bottom line and fill out the complaint form with details.',
    'submit': 'You can report issues by clicking the "Submit" button on the dashboard. Provide photos if possible.',
    'garbage': 'Garbage collection days: Monday & Thursday. Missed pickup? Report in the complaints section.',
    'water': 'Water supply issues? Contact the water department at 123-456-7890 or report via the app.',
    'electricity': 'Power outage? Call emergency line: 987-654-3210. For non-urgent issues, use the report section.',
    'road': 'Road maintenance complaints can be submitted with location photos in the report section.',
    'park': 'Park maintenance issues will be addressed within 48 hours of reporting.',
    'emergency': 'For emergencies, call 911 immediately.',
    'thanks': 'You\'re welcome! Is there anything else I can help you with?',
    'thank you': 'You\'re welcome! Happy to assist.',
    'bye': 'Goodbye! Stay safe and have a great day!',
     
  // Category to Department Mapping
  'street light': 'Broken street lights fall under the Electricity Department. Please report it through the Submit tab with clear photos of the pole number and location.',
  'broken street light': 'Street light issues are handled by the Electricity Department. Go to Submit, select Electricity category, mention the pole number, and upload a photo.',
  'loud noise': 'Noise complaints go to the City Police Department. For construction noise during prohibited hours (10 PM - 7 AM), select Others category and mention the timing.',
  'illegal dumping': 'Illegal garbage dumping is managed by the Sanitation Department. Take photos of the license plate if possible and report in Garbage category.',
  'stray animals': 'Stray animal issues (dogs/cows) are handled by the Municipal Corporation. Please call animal control at 555-6789 immediately.',
  'sewage smell': 'Sewage or drainage issues belong to the Water & Sewerage Department. Report immediately as this can be a health hazard.',
  'tree cutting': 'Unauthorized tree cutting comes under the Parks & Horticulture Department. Take photos and report in Parks category.',
  'traffic signal': 'Broken traffic signals are managed by the Traffic Police Department. For urgent issues, call 911 first.',
  'corruption': 'Corruption complaints go to the Anti-Corruption Department. You can submit an anonymous report through the app by selecting Others category.',
  
  // Don't know category helper
  'which department': 'If you are unsure which department handles your issue, simply select "Others" category while reporting. The admin will review and assign it to the correct department for you.',
  'not sure category': 'Don\'t worry! If you\'re unsure about the category, just select "Others". Your complaint will be reviewed by the admin and assigned to the right department.',
  'what to select': 'When in doubt, choose "Others" category. Our admin team will make sure your complaint reaches the correct department.',

  'photo': 'To upload photos while reporting a complaint:\n1. Go to Submit tab\n2. Fill complaint details\n3. Tap on "Upload Images"\n4. Select photos from gallery or camera\n5. Wait for upload to complete\n6. You can upload multiple photos\n\nPhotos help the department understand the issue better!',
  'upload': 'To upload photos: Tap the "Upload Images" button in Submit screen, select up to 5 photos from gallery or take new ones, and they will be automatically uploaded.',
  'image': 'You can upload images by clicking the cloud icon in the complaint form. Select from gallery or take a photo. Images help verify the complaint.',

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
                 _buildQuickChip('Others'),  
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
  // 🔥 STEP 1: PEHLE SPECIFIC QUERIES CHECK KARO (MOST SPECIFIC FIRST)
  
  // ============ COMPLAINT STATUS & TRACKING (Most Important) ============
  if (message.contains('complaint status') || message.contains('status of my complaint') || 
      message.contains('track my complaint') || message.contains('complaint tracking')) {
    return '📊 To check your complaint status:\n\n1. Go to "My Complaints" tab at the bottom\n2. You will see all your complaints\n3. Each complaint shows status: Pending / Approved / In-Progress / Resolved / Rejected\n4. Tap "View Details" for more information\n5. You can also see submission date and last update\n\nStatus updates are real-time. You will get notifications when status changes.';
  }
  
  if (message.contains('how long') || message.contains('timeline') || message.contains('when will') || 
      message.contains('resolution time') || message.contains('how many days')) {
    return '⏰ Complaint Resolution Timeline:\n\n• Pending: Reviewed within 24 hours\n• Approved: Department assigned in 2-3 days\n• In-Progress: Active work, takes 5-7 days\n• Resolved: Complaint closed\n\nTimeline depends on issue type and department workload. Check exact status in "My Complaints" section.';
  }
  
  if (message.contains('rejected') || message.contains('rejected') || message.contains('not approved')) {
    return '⚠️ Why was your complaint rejected?\n\nCommon reasons:\n• Incomplete or unclear description\n• Invalid or incorrect location\n• Duplicate complaint (already reported)\n• Against guidelines (fake/promotional)\n\nWhat to do:\n1. Go to "My Complaints"\n2. Tap on rejected complaint\n3. Click "Edit" to modify\n4. Add better description/photos\n5. Resubmit\n\n.';
  }
   // 🔥 YAHAN YEH ADD KARO (Comment deleted ke liye)
  if (message.contains('comment deleted') || message.contains('my comment removed') || 
      message.contains('why comment deleted') || message.contains('comment not showing') ||
      message.contains('delete my comment')) {
    return '💬 Why was your comment deleted?\n\nReasons for comment deletion:\n• Using inappropriate or offensive language\n• Spam or promotional content\n• False or misleading information\n• Harassing other users\n• Off-topic or irrelevant comments\n\nCityCare maintains a respectful community. Please keep comments:\n✅ Constructive and helpful\n✅ Respectful to others\n✅ Related to the complaint\n\nYour comment will be restored if you edit it to follow guidelines. Contact support@citycare.com if you believe this was a mistake.';
  }
  // ============ NOTIFICATIONS ============
  if (message.contains('notification') || message.contains('not getting notification') || 
      message.contains('no notification') || message.contains('alert')) {
    return '🔔 **Notifications in CityCare**\n\nYou will receive notifications for:\n• Complaint status changes (Approved/Rejected/Resolved)\n• Officer assigned to your complaint\n• New updates on your complaint\n• Replies to your comments\n• Garbage schedule reminders\n\n**How to enable notifications:**\n1. Go to Profile tab\n2. Tap Settings (⚙️ icon)\n3. Click Notifications\n4. Toggle ON the notifications you want\n5. Also check phone Settings → Apps → CityCare → Notifications → Allow\n\nHaving trouble? Contact support@citycare.com';
  }
  
  if (message.contains('mute notification') || message.contains('turn off notification') || 
      message.contains('disable notification') || message.contains('stop notification')) {
    return '🔕 **How to mute/disable notifications:**\n\n**Method 1 - In App:**\n1. Go to Profile → Settings\n2. Tap on Notifications\n3. Toggle OFF specific notifications:\n   • Complaint updates\n   • Promotional alerts\n   • Garbage reminders\n\n**Method 2 - Phone Settings:**\n1. Open Phone Settings\n2. Go to Apps → CityCare\n3. Tap Notifications\n4. Turn OFF all notifications\n\nYou can always turn them back ON anytime. Muted notifications won\'t disturb you but you might miss important updates!';
  }
  
  if (message.contains('too many notification') || message.contains('getting many notification')) {
    return '📱 **Too many notifications?**\n\nYou can customize which notifications you receive:\n\n1. Go to Profile → Settings → Notifications\n2. Uncheck categories you don\'t want:\n   • ❌ Promotional offers\n   • ❌ Garbage reminders  \n   • ✅ Complaint updates (recommended)\n   • ✅ Status changes (recommended)\n\nThis way you only get important updates about your complaints!';
  }
  
  // ============ DELAYED COMPLAINT STATUS ============
  if (message.contains('pending for long') || message.contains('still pending') || 
      message.contains('why not starting') || message.contains('no action yet') ||
      message.contains('not working on my complaint') ||message.contains('not progressed')|| message.contains('delayed complaint')) {
    return '⏳ **Why is your complaint still pending?**\n\nPossible reasons for delay:\n• High volume of complaints in your area\n• Waiting for department assignment\n• Need additional verification\n• Technical review in progress\n• Weekend/holiday delay\n\n**What you can do:**\n1. **Check details:** Go to My Complaints → View Details → Verify information is correct\n2. **Add more info:** Edit complaint to add better photos/description\n3. **Follow up:** Comment on your complaint asking for update\n4. **Contact support:** Email support@citycare.com with your complaint ID\n\n**Average resolution time:** 5-7 working days. Your complaint ID is important for tracking. We appreciate your patience! 🙏';
  }
  
  if (message.contains('how to escalate') || message.contains('complaint ignored') || 
      message.contains('no response') || message.contains('take too long')) {
    return '📢 **How to escalate a delayed complaint:**\n\n**Step 1 - Add comment:**\nGo to My Complaints → View Details → Add a comment asking for status update\n\n**Step 2 - Contact support:**\nEmail: support@citycare.com\nInclude: Your complaint ID and submission date\n\n**Step 3 - Escalate to supervisor:**\nCall city helpline: 555-0123\nMention your complaint ID and ask to speak with a supervisor\n\n**Step 4 - Re-submit (if needed):**\nIf no response after 14 days, create a new complaint with "URGENT" in description\n\nWe take all complaints seriously and try our best to resolve quickly!';
  }
  if (message.contains('not showing') || message.contains('public feed') || message.contains('cannot see')) {
    return '🔍 Why is your complaint not showing in public feed?\n\nComplaints appear in public feed only when:\n• Complaint is "Approved" by admin\n• It is not "Rejected"\n• It is "In-Progress" or "Resolved"\n\nPending complaints are private to you. Once approved, it becomes visible to everyone. Check "My Complaints" to see your complaint status.';
  }
  
  if (message.contains('not showing') || message.contains('public feed') || message.contains('cannot see')) {
    return '🔍 Why is your complaint not showing in public feed?\n\nComplaints appear in public feed only when:\n• Complaint is "Approved" by admin\n• It is not "Rejected"\n• It is "In-Progress" or "Resolved"\n\nPending complaints are private to you. Once approved, it becomes visible to everyone. Check "My Complaints" to see your complaint status.';
  }
  
  if (message.contains('status update') || message.contains('notification about complaint')) {
    return '🔔 Complaint Status Updates:\n\nYou will receive automatic notifications when:\n• Complaint is reviewed\n• Status changes (Approved/Rejected)\n• Officer is assigned\n• Work is In-Progress\n• Complaint is Resolved\n\nEnable notifications in Profile → Settings to get real-time updates!';
  }
  
  // ============ PHOTOS/UPLOAD ============
  if (message.contains('photo') || message.contains('upload') || message.contains('image')) {
    return '📸 How to upload photos:\n\n1. Go to Submit tab\n2. Fill complaint details\n3. Tap "Upload Images" area\n4. Select from gallery or take new photo\n5. Images upload automatically to Cloudinary\n6. Add up to 5 photos\n\nPhotos help resolve complaints faster!';
  }
  
  // ============ DEPARTMENT MAPPING ============
  if (message.contains('street light') || (message.contains('light') && message.contains('broken'))) {
    return '💡 Broken street lights are handled by the Electricity Department. Please report through Submit tab with Electricity category. Mention the pole number if visible.';
  }
  
  if (message.contains('which department') || message.contains('who handles')) {
    return '🏢 Not sure which department? Don\'t worry! Simply select "Others" category while reporting. The admin will review and assign your complaint to the correct department automatically.';
  }
  
  // ============ GREETINGS ============
  if (message.contains('hello') || message.contains('hi')) {
    return 'Hello! 👋 Welcome to CityCare Assistant. How can I help you with city services today?';
  }
  
  if (message.contains('how are you')) {
    return 'I\'m doing great, thank you for asking! 🌟 I\'m ready to help you with complaints, status tracking, and city services. What do you need?';
  }
  
  if (message.contains('thank')) {
    return 'You\'re most welcome! 😊 I\'m glad I could help. Is there anything else you\'d like to know?';
  }
  
  if (message.contains('bye')) {
    return 'Goodbye! 👋 Stay safe and don\'t hesitate to reach out if you need help with city services. Have a great day!';
  }
  
  // ============ COMPLAINT SUBMISSION (Generic - After Status) ============
  if (message.contains('complaint') || message.contains('report')) {
    return '📝 To report a complaint:\n\n1. Go to Submit tab (bottom navigation)\n2. Select a category (Garbage/Water/Electricity/Roads)\n3. Write detailed description\n4. Select location on map\n5. Upload photos\n6. Click "Submit Complaint"\n\nYour complaint will be reviewed within 24 hours. Need help with any step?';
  }
  
  // ============ CITY SERVICES ============
  if (message.contains('garbage') || message.contains('trash')) {
    return '🗑️ Garbage collection: Monday & Thursday (8 AM - 4 PM). Recycling: Friday. Report missed pickup in the app.';
  }
  
  if (message.contains('water')) {
    return '💧 Water issues? Emergency: 123-456-7890. Or report through app with Water category.';
  }
  
  if (message.contains('electricity') || message.contains('power')) {
    return '⚡ Power outage? Emergency: 987-654-3210. Report through app with Electricity category.';
  }
  
  if (message.contains('emergency')) {
    return '🚨 EMERGENCY CONTACTS:\n\nPolice/Medical/Fire: 911\nWater Dept: 123-456-7890\nElectricity: 987-654-3210\nCity Helpline: 555-0123\n\nFor life-threatening emergencies, ALWAYS call 911 first!';
  }
  
  // ============ PROFILE ============
  if (message.contains('phone') || message.contains('update profile') || message.contains('change number')) {
    return '📱 To update your phone number:\n\n1. Go to Profile tab\n2. Tap "Edit Profile"\n3. Change your phone number\n4. Click "Save Changes"\n\nYour number will be updated immediately and you will receive an SMS confirmation.';
  }
  
  if (message.contains('registration fee') || message.contains('refund')) {
    return '💰 Registration fee withdrawal:\n\n1. Go to Profile → Settings\n2. Click "Request Withdrawal"\n3. Enter bank details\n4. Submit\n\nProcessing takes 5-7 business days. Fee refundable within 30 days of registration.';
  }
  
  // ============ OUT OF DOMAIN ============
  if (message.contains('weather') || message.contains('news') || message.contains('sports') || message.contains('movie')) {
    return '🤔 I\'m CityCare Assistant, specialized in city services and complaints. I can help with reporting issues, checking status, and emergency contacts. For weather/news/sports, please check other apps!';
  }
  
  // ============ DEFAULT ============
  return "I understand you're asking about '$message'.\n\nI can help you with:\n✅ Reporting complaints (garbage/water/electricity/roads)\n✅ Checking complaint status\n✅ Understanding resolution timeline\n✅ Emergency contacts\n✅ Updating your profile\n\nCould you please rephrase your question? I'm here to help! 😊";
}
  
  void _handleQuickAction(String action) {
    String response = '';
    switch (action) {
      case 'Submit Issue':
        response = 'Please go to the main dashboard and click the "Submit" button. You can upload photos and describe the problem.';
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
      case 'Others':  // 🔥 YEH ADD KARO
      response = 'If you are unsure which category to select for your complaint, simply choose "Others". The admin will review your complaint and assign it to the correct department. This ensures your issue reaches the right people even if you\'re not sure about the department.';
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
                 _buildOptionChip('Which department?'),  // 🔥 YEH ADD KARO
  _buildOptionChip('Not sure category'), 
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