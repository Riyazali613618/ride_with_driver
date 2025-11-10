import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../components/media_uploader_widget.dart';
import '../../../constants/api_constants.dart';
import '../../../l10n/app_localizations.dart';

class MessagingScreen extends StatefulWidget {
  // final String userId;
  // final String cause;
  final String conversationId;
  final String chatId;
  final String name;
  final String image;
  final String otherPersonId;
  final String otherPersonUserId;

  const MessagingScreen({
    Key? key,
    // required this.userId,
    // required this.cause,
    required this.conversationId,
    required this.chatId,
    required this.name,
    required this.image,
    required this.otherPersonId,
    required this.otherPersonUserId,
  }) : super(key: key);

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen>
    with WidgetsBindingObserver {
  WebSocketChannel? _channel;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isConnected = false;
  bool _isTyping = false;
  bool _otherUserTyping = false;
  bool _otherUserOnline = false;
  DateTime? _otherUserLastSeen;
  Timer? _typingTimer;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool showMediaUploader = false;
  bool isSendingMedia = false;

  // Message status tracking
  final Map<String, String> _messageStatus = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadChatMessages();
    _connectWebSocket();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _typingTimer?.cancel();
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _connectWebSocket();
    } else if (state == AppLifecycleState.paused) {
      _disconnectWebSocket();
    }
  }

  void _connectWebSocket() async {
    try {
      // Close existing connection if any
      _disconnectWebSocket();

      final token = await TokenManager.getToken();
      final wsUrl =
          'wss://${ApiConstants.baseUrl.replaceFirst('https://', '')}/chat?chatId=${widget.chatId}&token=${token}';
      print('Connecting to WebSocket: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (message) {
          _handleWebSocketMessage(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleDisconnection();
        },
        onDone: () {
          print('WebSocket connection closed');
          _handleDisconnection();
        },
      );

      setState(() {
        _isConnected = true;
      });

      // Start heartbeat
      _startHeartbeat();
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      _handleDisconnection();
    }
  }

  void _disconnectWebSocket() {
    _heartbeatTimer?.cancel();
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }
    setState(() {
      _isConnected = false;
    });
  }

  void _handleDisconnection() {
    _disconnectWebSocket();

    // Try to reconnect after 3 seconds
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _connectWebSocket();
      }
    });
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      print('Received WebSocket message: $message');
      final data = json.decode(message);

      switch (data['type']) {
        case 'connection_established':
          setState(() {
            _isConnected = true;
          });
          break;
        case 'message_received':
          _handleNewMessage(data);
          break;
        case 'message_sent':
          _updateMessageStatus(data['messageId'], 'sent');
          break;
        case 'message_delivered':
          _updateMessageStatus(data['messageId'], 'delivered');
          break;
        case 'message_read':
          _updateMessageStatus(data['messageId'], 'read');
          break;
        case 'user_typing_start':
          if (data['userId'] == widget.otherPersonUserId) {
            setState(() {
              _otherUserTyping = true;
            });
          }
          break;
        case 'user_typing_stop':
          if (data['userId'] == widget.otherPersonUserId) {
            setState(() {
              _otherUserTyping = false;
            });
          }
          break;
        case 'user_online':
          if (data['userId'] == widget.otherPersonUserId) {
            setState(() {
              _otherUserOnline = true;
              _otherUserLastSeen = null;
            });
          }
          break;
        case 'user_offline':
          if (data['userId'] == widget.otherPersonUserId) {
            setState(() {
              _otherUserOnline = false;
              _otherUserLastSeen =
                  DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
            });
          }
          break;
        case 'heartbeat_ack':
          // Connection is alive
          break;
        case 'error':
          _showError(data['message']);
          break;
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    final message = ChatMessage(
      messageId: data['messageId'],
      message: data['message'],
      isSent: data['isSent'] ?? false,
      messageType: data['messageType'],
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? data['at']),
      senderId: data['senderId'],
    );

    setState(() {
      _messages.add(message);
    });

    _scrollToBottom();

    // Send read receipt
    _sendReadReceipt(data['messageId']);
  }

  void _updateMessageStatus(String messageId, String status) {
    setState(() {
      _messageStatus[messageId] = status;
    });
  }

  Future<void> _loadChatMessages() async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/user/chat/conversations/${widget.conversationId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final messages = data['data'] as List;
          setState(() {
            _messages.clear();
            _messages.addAll(messages.map((msg) => ChatMessage(
                  messageId: msg['messageId'],
                  message: msg['message'],
                  isSent: msg['isSent'],
                  messageType: msg['messageType'],
                  timestamp: DateTime.parse(msg['at']),
                  deliveryStatus: msg['deliveryStatus'],
                  isRead: msg['isRead'],
                )));
          });
          _scrollToBottom();
        }
      } else {
        _showError('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading messages: $e');
      _showError('Failed to load messages');
    }
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || !_isConnected) {
      if (!_isConnected) {
        _showError('Not connected to chat server');
      }
      return;
    }

    final messageData = {
      'type': 'message',
      'message': messageText,
      'recipientId': widget.otherPersonUserId,
      'messageType': 'TEXT',
    };

    try {
      _channel?.sink.add(json.encode(messageData));

      // Add message to UI optimistically
      final tempMessage = ChatMessage(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        message: messageText,
        isSent: true,
        messageType: 'TEXT',
        timestamp: DateTime.now(),
        deliveryStatus: 'sending',
      );

      setState(() {
        _messages.add(tempMessage);
      });

      _messageController.clear();
      _stopTyping();
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      _showError('Failed to send message');
    }
  }

  Future<void> _sendMediaMessage(String mediaUrl, String messageType) async {
    if (mediaUrl.isEmpty || isSendingMedia || !_isConnected) {
      if (!_isConnected) {
        _showError('Not connected to chat server');
      }
      return;
    }

    setState(() {
      isSendingMedia = true;
      showMediaUploader = false;
    });

    // Add message to UI optimistically
    final tempMessage = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      message: mediaUrl,
      isSent: true,
      messageType: messageType,
      timestamp: DateTime.now(),
      deliveryStatus: 'sending',
    );

    setState(() {
      _messages.add(tempMessage);
    });

    _scrollToBottom();

    // Prepare media message data
    final messageData = {
      'type': 'message',
      'message': mediaUrl,
      'recipientId': widget.otherPersonUserId,
      'messageType': messageType,
    };

    try {
      _channel?.sink.add(json.encode(messageData));
      setState(() {
        isSendingMedia = false;
      });
    } catch (e) {
      print('Error sending media message: $e');
      setState(() {
        isSendingMedia = false;
      });
      _showError('Failed to send media');
    }
  }

  String _determineMessageType(String url) {
    final extension = url.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'IMAGE';
    } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
      return 'VIDEO';
    }
    return 'DOCUMENT';
  }

  void _startTyping() {
    if (!_isTyping && _isConnected) {
      _isTyping = true;
      try {
        _channel?.sink.add(json.encode({
          'type': 'typing_start',
        }));
      } catch (e) {
        print('Error sending typing start: $e');
      }
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _stopTyping();
    });
  }

  void _stopTyping() {
    if (_isTyping && _isConnected) {
      _isTyping = false;
      try {
        _channel?.sink.add(json.encode({
          'type': 'typing_stop',
        }));
      } catch (e) {
        print('Error sending typing stop: $e');
      }
    }
    _typingTimer?.cancel();
  }

  void _sendReadReceipt(String messageId) {
    if (_isConnected) {
      try {
        _channel?.sink.add(json.encode({
          'type': 'message_read',
          'messageId': messageId,
        }));
      } catch (e) {
        print('Error sending read receipt: $e');
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel?.sink.add(json.encode({
            'type': 'heartbeat',
          }));
        } catch (e) {
          print('Error sending heartbeat: $e');
          _handleDisconnection();
        }
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getLastSeenText() {
    if (_otherUserOnline) {
      return 'Online';
    } else if (_otherUserLastSeen != null) {
      final difference = DateTime.now().difference(_otherUserLastSeen!);
      if (difference.inMinutes < 1) {
        return 'Last seen just now';
      } else if (difference.inHours < 1) {
        return 'Last seen ${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return 'Last seen ${difference.inHours}h ago';
      } else {
        return 'Last seen ${difference.inDays}d ago';
      }
    }
    return ' ';
  }

  Widget _buildMessageStatus(ChatMessage message) {
    if (!message.isSent) return const SizedBox.shrink();

    final status = _messageStatus[message.messageId] ??
        message.deliveryStatus ??
        'sending';

    switch (status) {
      case 'sending':
        return const Icon(Icons.access_time, size: 12, color: Colors.grey);
      case 'sent':
        return const Icon(Icons.done, size: 12, color: Colors.grey);
      case 'delivered':
        return const Icon(Icons.done_all, size: 12, color: Colors.grey);
      case 'read':
        return const Icon(Icons.done_all, size: 12, color: Colors.blue);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: CupertinoNavigationBarBackButton(
          color: ColorConstants.white,
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  widget.image.isNotEmpty ? NetworkImage(widget.image) : null,
              child: widget.image.isEmpty
                  ? Text(widget.name.isNotEmpty
                      ? widget.name[0].toUpperCase()
                      : '?')
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ColorConstants.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_otherUserTyping)
                    Text(
                      localizations.typing,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Text(
                      _getLastSeenText(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorConstants.white,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: ColorConstants.primaryColor,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Icon(
              _isConnected ? Icons.circle : Icons.circle_outlined,
              color: _isConnected ? Colors.green : Colors.red,
              size: 12,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (showMediaUploader) _buildMediaUploaderSection(),

          // Typing Indicator
          if (_otherUserTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: widget.image.isNotEmpty
                        ? NetworkImage(widget.image)
                        : null,
                    child: widget.image.isEmpty
                        ? Text(
                            widget.name.isNotEmpty
                                ? widget.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 10))
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTypingDot(0),
                              _buildTypingDot(1),
                              _buildTypingDot(2),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      showMediaUploader = !showMediaUploader;
                    });
                  },
                  icon: Icon(
                    showMediaUploader ? Icons.close : Icons.attach_file,
                    color: ColorConstants.primaryColor,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: localizations.type_message,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        _startTyping();
                      } else {
                        _stopTyping();
                      }
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isConnected
                          ? ColorConstants.primaryColor
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: isSendingMedia
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaUploaderSection() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.upload_media,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    showMediaUploader = false;
                  });
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          MediaUploader(
            label: localizations.select_media_source,
            kind: "CHAT",
            showPreview: true,
            useGallery: true,
            showDirectImage: true,
            showDottedBorder: false,
            initialUrl: null,
            onMediaUploaded: (url) {
              final messageType = _determineMessageType(url);
              _sendMediaMessage(url, messageType);
            },
            required: false,
            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'mp4', 'mov'],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            message.isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: GestureDetector(
              onTap: () {
                if (message.messageType != 'TEXT') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MediaViewScreen(message: message),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: message.isSent
                      ? ColorConstants.primaryColor
                      : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: Radius.circular(message.isSent ? 12 : 0),
                    bottomRight: Radius.circular(message.isSent ? 0 : 12),
                  ),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                    minWidth: MediaQuery.of(context).size.width * 0.2,
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, right: 10, left: 10, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (message.messageType == 'TEXT')
                              _buildTextMessageContent(message),
                            if (message.messageType == 'IMAGE')
                              _buildImageMessageContent(message),
                            if (message.messageType == 'VIDEO')
                              _buildVideoMessageContent(message),
                            if (message.messageType == 'DOCUMENT')
                              _buildDocumentMessageContent(message),
                          ],
                        ),
                      ),

                      // Time & Status (bottom right)
                      Positioned(
                        bottom: 4,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.timestamp),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            if (message.isSent) ...[
                              const SizedBox(width: 4),
                              _buildMessageStatus(message),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextMessageContent(ChatMessage message) {
    return Text(
      message.message,
      textAlign: TextAlign.start,
      style: TextStyle(
        color: message.isSent ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
    );
  }

  Widget _buildImageMessageContent(ChatMessage message) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: CachedNetworkImage(
        imageUrl: message.message,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoMessageContent(ChatMessage message) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          color: Colors.black,
          child: const Icon(Icons.videocam, size: 48, color: Colors.white),
        ),
        Positioned(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.play_arrow, size: 32, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentMessageContent(ChatMessage message) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isSent
                  ? Colors.white.withOpacity(0.2)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description,
              color: message.isSent ? Colors.white : Colors.grey[600],
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "document",
                  style: TextStyle(
                    color: message.isSent ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.message.split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: message.isSent ? Colors.white70 : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.download,
            color: message.isSent ? Colors.white70 : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? 'PM' : 'AM';

    // Convert to 12-hour format
    if (hour == 0) {
      hour = 12; // 12 AM
    } else if (hour > 12) {
      hour = hour - 12; // PM hours
    }

    return '${hour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildTypingDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        shape: BoxShape.circle,
      ),
    );
  }

// Widget _buildMessageBubble(ChatMessage message) {
//   return Container(
//     margin: const EdgeInsets.only(bottom: 12),
//     child: Row(
//       mainAxisAlignment:
//           message.isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         if (!message.isSent)
//           CircleAvatar(
//             radius: 12,
//             backgroundImage:
//                 widget.image.isNotEmpty ? NetworkImage(widget.image) : null,
//             child: widget.image.isEmpty
//                 ? Text(
//                     widget.name.isNotEmpty
//                         ? widget.name[0].toUpperCase()
//                         : '?',
//                     style: const TextStyle(fontSize: 10))
//                 : null,
//           ),
//         if (!message.isSent) const SizedBox(width: 8),
//         Flexible(
//           child: Container(
//             constraints: BoxConstraints(
//               maxWidth: MediaQuery.of(context).size.width *
//                   0.75, // 75% of screen width
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color: message.isSent
//                   ? ColorConstants.primaryColor
//                   : Colors.grey[200],
//               borderRadius: BorderRadius.only(
//                 topLeft: const Radius.circular(18),
//                 topRight: const Radius.circular(18),
//                 bottomLeft: Radius.circular(message.isSent ? 18 : 4),
//                 bottomRight: Radius.circular(message.isSent ? 4 : 18),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   message.message,
//                   style: TextStyle(
//                     color: message.isSent ? Colors.white : Colors.black87,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       _formatTime(message.timestamp),
//                       style: TextStyle(
//                         color: message.isSent
//                             ? Colors.white70
//                             : Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//
//                     // Text(
//                     //   '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
//                     //   style: TextStyle(
//                     //     color: message.isSent
//                     //         ? Colors.white70
//                     //         : Colors.grey[600],
//                     //     fontSize: 12,
//                     //   ),
//                     // ),
//                     if (message.isSent) ...[
//                       const SizedBox(width: 4),
//                       _buildMessageStatus(message),
//                     ],
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
}

class ChatMessage {
  final String messageId;
  final String message;
  final bool isSent;
  final String messageType;
  final DateTime timestamp;
  final String? senderId;

  final String? deliveryStatus;
  final bool? isRead;

  ChatMessage({
    required this.messageId,
    required this.message,
    required this.isSent,
    required this.messageType,
    required this.timestamp,
    this.senderId,
    this.deliveryStatus,
    this.isRead,
  });
}

class MediaViewScreen extends StatefulWidget {
  final ChatMessage message;

  const MediaViewScreen({Key? key, required this.message}) : super(key: key);

  @override
  State<MediaViewScreen> createState() => _MediaViewScreenState();
}

class _MediaViewScreenState extends State<MediaViewScreen>
    with WidgetsBindingObserver {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoLoading = false;
  bool _hasVideoError = false;
  String? _errorMessage;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.message.messageType == 'VIDEO') {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _isVideoLoading = true;
      _hasVideoError = false;
    });

    try {
      // Validate URL first
      final uri = Uri.tryParse(widget.message.message);
      if (uri == null || !uri.hasScheme) {
        throw Exception('Invalid video URL format');
      }

      _videoController = VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: false,
        ),
        httpHeaders: {
          'User-Agent': 'Flutter Video Player',
          'Accept': 'video/*',
        },
      );

      // Set up error listener before initialization
      _videoController!.addListener(_videoListener);

      // Initialize with timeout
      await _videoController!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Video loading timeout - please check your connection');
        },
      );

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isVideoLoading = false;
        });
        _startHideControlsTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasVideoError = true;
          _isVideoLoading = false;
          _errorMessage = _getErrorMessage(e);
        });
      }
      debugPrint('Error initializing video: $e');
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeout')) {
      return 'Video loading timeout. Please check your internet connection.';
    } else if (errorString.contains('source error') ||
        errorString.contains('exoplaybackexception')) {
      return 'Video format not supported or file is corrupted.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('permission') ||
        errorString.contains('access')) {
      return 'Cannot access video file. Permission denied.';
    } else if (errorString.contains('invalid') ||
        errorString.contains('format')) {
      return 'Invalid video URL or unsupported format.';
    } else {
      return 'Failed to load video. Please try again.';
    }
  }

  void _videoListener() {
    if (mounted && _videoController != null) {
      // Check for errors
      if (_videoController!.value.hasError) {
        setState(() {
          _hasVideoError = true;
          _isVideoLoading = false;
          _errorMessage = _getErrorMessage(
              _videoController!.value.errorDescription ??
                  'Unknown video error');
        });
        return;
      }

      setState(() {});
    }
  }

  void _togglePlayPause() {
    if (_videoController != null && _isVideoInitialized) {
      setState(() {
        _videoController!.value.isPlaying
            ? _videoController!.pause()
            : _videoController!.play();
      });
      _showControlsTemporarily();
    }
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _videoController?.value.isPlaying == true) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _seekTo(Duration position) {
    _videoController?.seekTo(position);
    _showControlsTemporarily();
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return '0:00';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _videoController?.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideControlsTimer?.cancel();
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.message.messageType == 'DOCUMENT')
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () => _downloadDocument(),
            ),
        ],
      ),
      body: Center(
        child: _buildMediaContent(),
      ),
    );
  }

  Widget _buildMediaContent() {
    switch (widget.message.messageType) {
      case 'IMAGE':
        return Hero(
          tag: 'image_${widget.message.messageId}',
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: CachedNetworkImage(
              imageUrl: widget.message.message,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (context, url, error) => const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.white, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );

      case 'VIDEO':
        return Hero(
          tag: 'video_${widget.message.messageId}',
          child: _buildVideoPlayer(),
        );

      case 'DOCUMENT':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 128, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Document',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _downloadDocument,
              icon: const Icon(Icons.download),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );

      default:
        return const Text(
          'Unsupported media type',
          style: TextStyle(color: Colors.white),
        );
    }
  }

  Widget _buildVideoPlayer() {
    if (_isVideoLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_hasVideoError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage ?? 'Failed to load video',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _initializeVideo,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _downloadDocument(),
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (!_isVideoInitialized || _videoController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: _showControlsTemporarily,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          if (_showControls) _buildVideoControls(),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    final isPlaying = _videoController?.value.isPlaying ?? false;
    final position = _videoController?.value.position ?? Duration.zero;
    final duration = _videoController?.value.duration ?? Duration.zero;
    final isBuffering = _videoController?.value.isBuffering ?? false;

    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Play/Pause button
            if (isBuffering)
              const CircularProgressIndicator(color: Colors.white)
            else
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),

            const Spacer(),

            // Progress bar and time
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white30,
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      trackHeight: 2,
                    ),
                    child: Slider(
                      value: duration.inMilliseconds > 0
                          ? position.inMilliseconds / duration.inMilliseconds
                          : 0.0,
                      onChanged: (value) {
                        final newPosition = Duration(
                          milliseconds:
                              (value * duration.inMilliseconds).round(),
                        );
                        _seekTo(newPosition);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        _formatDuration(duration),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadDocument() async {
    try {
      final uri = Uri.parse(widget.message.message);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open document'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error downloading document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download document'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
