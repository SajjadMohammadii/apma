import 'package:apma_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      senderName: 'علی احمدی',
      message: 'درخواست مرخصی از تاریخ 1403/09/10 تا 1403/09/12 دارم',
      time: '09:32',
      date: '1403/09/05',
      isFromMe: false,
      hasReply: false,
      messageType: MessageType.leaveRequest,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'پیام ها',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Vazir',
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body:
            _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildChatBubble(_messages[index]);
                  },
                ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'پیامی وجود ندارد',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontSize: 16,
              fontFamily: 'Vazir',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            message.isFromMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          if (!message.isFromMe)
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 4),
              child: Text(
                message.senderName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                message.isFromMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isFromMe) ...[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryPurple.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        message.isFromMe
                            ? const LinearGradient(
                              colors: [
                                AppColors.primaryPurple,
                                Color(0xFF8882B2),
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            )
                            : null,
                    color: message.isFromMe ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft:
                          message.isFromMe
                              ? const Radius.circular(16)
                              : const Radius.circular(4),
                      bottomRight:
                          message.isFromMe
                              ? const Radius.circular(4)
                              : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.messageType != MessageType.normal)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color:
                                message.isFromMe
                                    ? Colors.white.withOpacity(0.3)
                                    : AppColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getMessageIcon(message.messageType),
                                size: 14,
                                color:
                                    message.isFromMe
                                        ? Colors.white
                                        : AppColors.primaryGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getMessageTypeLabel(message.messageType),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      message.isFromMe
                                          ? Colors.white
                                          : AppColors.primaryGreen,
                                  fontFamily: 'Vazir',
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        message.message,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              message.isFromMe
                                  ? Colors.white
                                  : AppColors.textPrimary,
                          fontFamily: 'Vazir',
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color:
                                message.isFromMe
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${message.time} - ${message.date}',
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  message.isFromMe
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                              fontFamily: 'Vazir',
                            ),
                          ),
                        ],
                      ),
                      if (!message.isFromMe && !message.hasReply) ...[
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Colors.grey),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _openChatPage(message),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryPurple,
                                  Color(0xFF8882B2),
                                ],
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.reply,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'پاسخ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Vazir',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (message.isFromMe) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMessageIcon(MessageType type) {
    switch (type) {
      case MessageType.leaveRequest:
        return Icons.event_busy;
      default:
        return Icons.message;
    }
  }

  String _getMessageTypeLabel(MessageType type) {
    switch (type) {
      case MessageType.leaveRequest:
        return 'درخواست مرخصی';
      default:
        return '';
    }
  }

  void _openChatPage(ChatMessage message) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDetailPage(message: message)),
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final ChatMessage message;

  const ChatDetailPage({super.key, required this.message});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];

  @override
  void initState() {
    super.initState();
    _chatMessages.add(widget.message);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _chatMessages.add(
        ChatMessage(
          senderName: 'شما',
          message: _messageController.text,
          time: TimeOfDay.now().format(context),
          date: '1403/09/05',
          isFromMe: true,
          hasReply: false,
          messageType: MessageType.normal,
        ),
      );
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.3),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.senderName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Vazir',
                      ),
                    ),
                    Text(
                      _getMessageTypeLabel(widget.message.messageType),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                        fontFamily: 'Vazir',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  return _buildChatBubble(_chatMessages[index]);
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isFromMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryPurple.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: AppColors.primaryPurple,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                gradient:
                    message.isFromMe
                        ? const LinearGradient(
                          colors: [AppColors.primaryPurple, Color(0xFF8882B2)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        )
                        : null,
                color: message.isFromMe ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      message.isFromMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                  bottomRight:
                      message.isFromMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          message.isFromMe
                              ? Colors.white
                              : AppColors.textPrimary,
                      fontFamily: 'Vazir',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.time,
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          message.isFromMe
                              ? Colors.white70
                              : AppColors.textSecondary,
                      fontFamily: 'Vazir',
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isFromMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: AppColors.primaryGreen,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'پیام خود را بنویسید...',
                    hintStyle: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Vazir', fontSize: 14),
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryPurple, Color(0xFF8882B2)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMessageTypeLabel(MessageType type) {
    switch (type) {
      case MessageType.leaveRequest:
        return 'درخواست مرخصی';
      default:
        return '';
    }
  }
}

enum MessageType { normal, leaveRequest }

class ChatMessage {
  final String senderName;
  final String message;
  final String time;
  final String date;
  final bool isFromMe;
  final bool hasReply;
  final MessageType messageType;

  ChatMessage({
    required this.senderName,
    required this.message,
    required this.time,
    required this.date,
    required this.isFromMe,
    required this.hasReply,
    required this.messageType,
  });
}
