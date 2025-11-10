// import 'dart:async';
// import 'dart:convert';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:r_w_r/constants/color_constants.dart';
// import 'package:r_w_r/constants/token_manager.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:video_player/video_player.dart';
// import 'package:web_socket_channel/status.dart' as status;
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// import '../../../api/api_model/chat/chat_history_model.dart';
// import '../../../api/api_service/chat/chat_conversation_service.dart';
// import '../../../components/media_uploader_widget.dart';
// import '../../../constants/api_constants.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String userId;
//   final String cause;
//   final String conversationId;
//   final String chatId;
//   final String name;
//   final String image;
//   final String otherPersonId;
//   final String otherPersonUserId;
//
//   const ChatScreen({
//     super.key,
//     required this.userId,
//     required this.cause,
//     required this.conversationId,
//     required this.chatId,
//     required this.name,
//     required this.image,
//     required this.otherPersonId,
//     required this.otherPersonUserId,
//   });
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   List<ChatMessage> messages = [];
//   bool isLoading = true;
//   bool isSending = false;
//   String? errorMessage;
//   bool showMediaUploader = false;
//
//   // Socket related variables
//   WebSocketChannel? _channel;
//   bool _isConnected = false;
//   Timer? _reconnectTimer;
//   int _reconnectAttempts = 0;
//   static const int maxReconnectAttempts = 5;
//
//   // User status variables
//   bool _isOtherUserOnline = false;
//   DateTime? _lastSeen;
//   Timer? _lastSeenTimer;
//
//   // Message status tracking
//   final Map<String, MessageStatus> _messageStatus = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _loadChatHistory();
//     _connectSocket();
//     _startLastSeenTimer();
//   }
//
//   @override
//   void dispose() {
//     _reconnectTimer?.cancel();
//     _lastSeenTimer?.cancel();
//     _channel?.sink.close(status.goingAway);
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _startLastSeenTimer() {
//     _lastSeenTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       if (!_isOtherUserOnline && _lastSeen != null) {
//         setState(() {});
//       }
//     });
//   }
//
//   void _connectSocket() async {
//     try {
//       final token = await TokenManager.getToken();
//       final wsUrl =
//           'wss://${ApiConstants.baseUrl.substring(ApiConstants.baseUrl.indexOf("://") + 3)}/chat?userId=${widget.userId}&userRole=${widget.cause}';
//
//       _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
//
//       _channel!.stream.listen(
//         _onSocketMessage,
//         onError: _onSocketError,
//         onDone: _onSocketClosed,
//       );
//
//       setState(() {
//         _isConnected = true;
//         _reconnectAttempts = 0;
//       });
//
//       print('Socket connected successfully');
//     } catch (e) {
//       print('Socket connection error: $e');
//       _onSocketError(e);
//     }
//   }
//
//   void _onSocketMessage(dynamic message) {
//     try {
//       final data = json.decode(message);
//       print('Received Socket message: $data');
//
//       // Handle different types of messages
//       if (data['type'] == 'status_update') {
//         // Handle user status updates
//         _handleStatusUpdate(data);
//       } else if (data['type'] == 'message_status') {
//         // Handle message status updates (read/delivered)
//         _handleMessageStatusUpdate(data);
//       } else {
//         // Handle regular chat messages
//         _handleChatMessage(data);
//       }
//     } catch (e) {
//       print('Error parsing Socket message: $e');
//     }
//   }
//
//   void _handleStatusUpdate(Map<String, dynamic> data) {
//     if (data['userId'] == widget.otherPersonUserId) {
//       setState(() {
//         _isOtherUserOnline = data['isOnline'] ?? false;
//         if (!_isOtherUserOnline) {
//           _lastSeen = data['lastSeen'] != null
//               ? DateTime.fromMillisecondsSinceEpoch(data['lastSeen'])
//               : DateTime.now();
//         }
//       });
//     }
//   }
//
//   void _handleMessageStatusUpdate(Map<String, dynamic> data) {
//     final messageId = data['messageId'];
//     final status = data['status']; // 'delivered' or 'read'
//
//     if (messageId != null && status != null) {
//       setState(() {
//         _messageStatus[messageId] =
//             status == 'read' ? MessageStatus.read : MessageStatus.delivered;
//       });
//     }
//   }
//
//   void _handleChatMessage(Map<String, dynamic> data) {
//     final receivedMessage = ChatMessage(
//       isSent: data['isSent'] ?? false,
//       message: data['message'] ?? '',
//       messageId:
//           data['messageId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       messageType: data['messageType'] ?? 'TEXT',
//       at: data['at'] != null
//           ? DateTime.fromMillisecondsSinceEpoch(data['at']).toIso8601String()
//           : DateTime.now().toIso8601String(),
//     );
//
//     setState(() {
//       messages.add(receivedMessage);
//     });
//
//     _scrollToBottom();
//
//     // Send read receipt if this is our chat
//     if (!receivedMessage.isSent && _isConnected) {
//       _sendReadReceipt(receivedMessage.messageId);
//     }
//   }
//
//   void _sendReadReceipt(String messageId) {
//     if (_channel != null && _isConnected) {
//       final receipt = {
//         'type': 'read_receipt',
//         'messageId': messageId,
//         'chatId': widget.conversationId,
//         'senderId': widget.otherPersonUserId,
//       };
//
//       try {
//         _channel!.sink.add(json.encode(receipt));
//         print('Sent read receipt for message: $messageId');
//       } catch (e) {
//         print('Error sending read receipt: $e');
//       }
//     }
//   }
//
//   void _onSocketError(dynamic error) {
//     print('Socket error: $error');
//     setState(() {
//       _isConnected = false;
//     });
//     _attemptReconnect();
//   }
//
//   void _onSocketClosed() {
//     print('Socket connection closed');
//     setState(() {
//       _isConnected = false;
//     });
//     _attemptReconnect();
//   }
//
//   void _attemptReconnect() {
//     if (_reconnectAttempts < maxReconnectAttempts) {
//       _reconnectAttempts++;
//       final delay = Duration(seconds: _reconnectAttempts * 2);
//
//       print(
//           'Attempting to reconnect in ${delay.inSeconds} seconds... (Attempt $_reconnectAttempts/$maxReconnectAttempts)');
//
//       _reconnectTimer = Timer(delay, () {
//         if (mounted) {
//           _connectSocket();
//         }
//       });
//     } else {
//       print('Max reconnection attempts reached');
//       _showErrorSnackBar('Connection lost. Please restart the app.');
//     }
//   }
//
//   void _sendSocketMessage(String message, String messageType) {
//     if (_channel != null && _isConnected) {
//       final messageData = {
//         'chatId': widget.conversationId,
//         'message': message,
//         'recipientId': widget.otherPersonUserId,
//         'messageType': messageType,
//       };
//
//       try {
//         _channel!.sink.add(json.encode(messageData));
//         print('Sent Socket message: $messageData');
//
//         // Track the message as sent (pending delivery)
//         final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
//         setState(() {
//           _messageStatus[tempMessageId] = MessageStatus.sent;
//         });
//       } catch (e) {
//         print('Error sending Socket message: $e');
//         _showErrorSnackBar('Failed to send message');
//       }
//     } else {
//       print('Socket not connected, cannot send message');
//       _showErrorSnackBar('Not connected. Trying to reconnect...');
//       _connectSocket();
//     }
//   }
//
//   Future<void> _loadChatHistory() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });
//
//     try {
//       final response = await ChatService.getChatHistory(widget.conversationId);
//
//       if (response.status) {
//         setState(() {
//           messages = response.data;
//           isLoading = false;
//
//           // Mark all received messages as read
//           for (var message in messages) {
//             if (!message.isSent) {
//               _messageStatus[message.messageId] = MessageStatus.read;
//             }
//           }
//         });
//         _scrollToBottom();
//       } else {
//         setState(() {
//           errorMessage = response.message;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to load messages';
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _sendMessage() async {
//     final text = _messageController.text.trim();
//     if (text.isEmpty || isSending) return;
//
//     setState(() {
//       isSending = true;
//     });
//
//     // Add message to local list immediately
//     final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
//     final tempMessage = ChatMessage(
//       isSent: true,
//       message: text,
//       messageId: tempMessageId,
//       messageType: 'TEXT',
//       at: DateTime.now().toIso8601String(),
//     );
//
//     setState(() {
//       messages.add(tempMessage);
//       _messageStatus[tempMessageId] = MessageStatus.sent;
//     });
//
//     _messageController.clear();
//     _scrollToBottom();
//
//     // Send via Socket
//     _sendSocketMessage(text, 'TEXT');
//
//     setState(() {
//       isSending = false;
//     });
//   }
//
//   Future<void> _sendMediaMessage(String mediaUrl, String messageType) async {
//     if (mediaUrl.isEmpty || isSending) return;
//
//     setState(() {
//       isSending = true;
//     });
//
//     // Add message to local list immediately
//     final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
//     final tempMessage = ChatMessage(
//       isSent: true,
//       message: mediaUrl,
//       messageId: tempMessageId,
//       messageType: messageType,
//       at: DateTime.now().toIso8601String(),
//     );
//
//     setState(() {
//       messages.add(tempMessage);
//       _messageStatus[tempMessageId] = MessageStatus.sent;
//       showMediaUploader = false;
//     });
//
//     _scrollToBottom();
//
//     // Send via Socket
//     _sendSocketMessage(mediaUrl, messageType);
//
//     setState(() {
//       isSending = false;
//     });
//   }
//
//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
//
//   void _showMediaDialog(ChatMessage message) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MediaViewScreen(message: message),
//       ),
//     );
//   }
//
//   String _getDisplayName() {
//     if (widget.name != null && widget.name!.isNotEmpty) {
//       return widget.name!;
//     }
//     return widget.cause == "DRIVER" ? "Driver" : "User";
//   }
//
//   bool _isValidUrl(String? url) {
//     if (url == null || url.isEmpty) return false;
//     try {
//       final uri = Uri.parse(url);
//       return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
//     } catch (e) {
//       return false;
//     }
//   }
//
//   String _getFileExtension(String url) {
//     return url.split('.').last.toLowerCase();
//   }
//
//   String _determineMessageType(String url) {
//     final extension = _getFileExtension(url);
//     if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
//       return 'IMAGE';
//     } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
//       return 'VIDEO';
//     } else if (['pdf', 'doc', 'docx', 'txt'].contains(extension)) {
//       return 'DOCUMENT';
//     }
//     return 'DOCUMENT';
//   }
//
//   String _formatLastSeen() {
//     if (_isOtherUserOnline) return 'Online';
//     if (_lastSeen == null) return 'Offline';
//
//     final now = DateTime.now();
//     final difference = now.difference(_lastSeen!);
//
//     if (difference.inSeconds < 60) return 'Last seen just now';
//     if (difference.inMinutes < 60)
//       return 'Last seen ${difference.inMinutes} min ago';
//     if (difference.inHours < 24)
//       return 'Last seen ${difference.inHours} hours ago';
//     if (difference.inDays < 7) return 'Last seen ${difference.inDays} days ago';
//
//     return 'Last seen on ${_lastSeen!.day}/${_lastSeen!.month}/${_lastSeen!.year}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: ColorConstants.primaryColor,
//         leading: CupertinoNavigationBarBackButton(
//           color: ColorConstants.white,
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 36,
//               height: 36,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//               ),
//               child: ClipOval(
//                 child: _isValidUrl(widget.image)
//                     ? CachedNetworkImage(
//                         imageUrl: widget.image!,
//                         fit: BoxFit.cover,
//                         errorWidget: (context, error, stackTrace) {
//                           return _buildDefaultAvatar();
//                         },
//                         placeholder: (context, url) => _buildDefaultAvatar(),
//                       )
//                     : _buildDefaultAvatar(),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     _getDisplayName(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     _formatLastSeen(),
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline, color: Colors.white),
//             onPressed: () {
//               // Show user info or chat details
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(child: _buildMessagesList()),
//           if (showMediaUploader) _buildMediaUploaderSection(),
//           _buildInputArea(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDefaultAvatar() {
//     final displayChar = widget.name != null && widget.name!.isNotEmpty
//         ? widget.name![0].toUpperCase()
//         : (widget.cause == "DRIVER" ? "D" : "U");
//
//     return Container(
//       width: 36,
//       height: 36,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           colors: [
//             Colors.white.withOpacity(0.2),
//             Colors.white.withOpacity(0.1)
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Center(
//         child: Text(
//           displayChar,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMediaUploaderSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           top: BorderSide(color: Colors.grey, width: 0.5),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Upload Media',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () {
//                   setState(() {
//                     showMediaUploader = false;
//                   });
//                 },
//                 icon: const Icon(Icons.close),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           MediaUploader(
//             label: 'Select Media',
//             kind: "CHAT",
//             showPreview: true,
//             useGallery: true,
//             showDirectImage: true,
//             showDottedBorder: false,
//             initialUrl: null,
//             onMediaUploaded: (url) {
//               final messageType = _determineMessageType(url);
//               _sendMediaMessage(url, messageType);
//             },
//             required: false,
//             allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'mp4', 'mov'],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessagesList() {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error, size: 48, color: Colors.red[400]),
//             const SizedBox(height: 16),
//             Text(errorMessage!, style: const TextStyle(color: Colors.red)),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadChatHistory,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (messages.isEmpty) {
//       return const Center(
//         child: Text(
//           'No messages yet\nStart the conversation!',
//           textAlign: TextAlign.center,
//           style: TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//       );
//     }
//
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//         setState(() {
//           showMediaUploader = false;
//         });
//       },
//       child: ListView.builder(
//         controller: _scrollController,
//         padding: const EdgeInsets.all(16),
//         itemCount: messages.length,
//         itemBuilder: (context, index) {
//           return _buildMessageBubble(messages[index]);
//         },
//       ),
//     );
//   }
//
//   Widget _buildMessageBubble(ChatMessage message) {
//     final isMe = message.isSent;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment:
//             isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           Flexible(
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.7,
//               ),
//               decoration: BoxDecoration(
//                 color: isMe ? ColorConstants.greyLight : Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: _buildMessageContent(message),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageContent(ChatMessage message) {
//     final isMe = message.isSent;
//
//     switch (message.messageType) {
//       case 'TEXT':
//         return _buildTextMessage(message, isMe);
//       case 'IMAGE':
//         return _buildImageMessage(message, isMe);
//       case 'VIDEO':
//         return _buildVideoMessage(message, isMe);
//       case 'DOCUMENT':
//         return _buildDocumentMessage(message, isMe);
//       default:
//         return _buildTextMessage(message, isMe);
//     }
//   }
//
//   Widget _buildTextMessage(ChatMessage message, bool isMe) {
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             message.message,
//             style: TextStyle(
//                 color: isMe ? ColorConstants.black : Colors.black54,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 4),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 message.formattedTime,
//                 style: TextStyle(
//                     color: isMe ? ColorConstants.primaryColor : Colors.black54,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600),
//               ),
//               if (isMe) ...[
//                 const SizedBox(width: 4),
//                 _buildMessageStatusIcon(message),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImageMessage(ChatMessage message, bool isMe) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         GestureDetector(
//           onTap: () => _showMediaDialog(message),
//           child: Hero(
//             tag: 'image_${message.messageId}',
//             child: ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomLeft: Radius.circular(4),
//                 bottomRight: Radius.circular(4),
//               ),
//               child: _isValidUrl(message.message)
//                   ? CachedNetworkImage(
//                       imageUrl: message.message,
//                       height: 200,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) => Container(
//                         height: 200,
//                         color: Colors.grey[300],
//                         child: const Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                       ),
//                       errorWidget: (context, url, error) => Container(
//                         height: 200,
//                         color: Colors.grey[300],
//                         child: const Center(
//                           child: Icon(Icons.error, color: Colors.red),
//                         ),
//                       ),
//                     )
//                   : Container(
//                       height: 200,
//                       color: Colors.grey[300],
//                       child: const Center(
//                         child: Icon(Icons.image_not_supported),
//                       ),
//                     ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 message.formattedTime,
//                 style: TextStyle(
//                   color: isMe ? Colors.white70 : Colors.grey,
//                   fontSize: 12,
//                 ),
//               ),
//               if (isMe) ...[
//                 const SizedBox(width: 4),
//                 _buildMessageStatusIcon(message),
//               ],
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildVideoMessage(ChatMessage message, bool isMe) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         GestureDetector(
//           onTap: () => _showMediaDialog(message),
//           child: Hero(
//             tag: 'video_${message.messageId}',
//             child: Container(
//               height: 200,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(16),
//                   topRight: Radius.circular(16),
//                   bottomLeft: Radius.circular(4),
//                   bottomRight: Radius.circular(4),
//                 ),
//               ),
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   const Icon(Icons.video_library, size: 64, color: Colors.grey),
//                   Container(
//                     decoration: const BoxDecoration(
//                       color: Colors.black54,
//                       shape: BoxShape.circle,
//                     ),
//                     padding: const EdgeInsets.all(16),
//                     child: const Icon(
//                       Icons.play_arrow,
//                       color: Colors.white,
//                       size: 32,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               const Icon(Icons.videocam, size: 16, color: Colors.grey),
//               const SizedBox(width: 4),
//               Text(
//                 'Video',
//                 style: TextStyle(
//                   color: isMe ? Colors.white70 : Colors.grey,
//                   fontSize: 14,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 message.formattedTime,
//                 style: TextStyle(
//                   color: isMe ? Colors.white70 : Colors.grey,
//                   fontSize: 12,
//                 ),
//               ),
//               if (isMe) ...[
//                 const SizedBox(width: 4),
//                 _buildMessageStatusIcon(message),
//               ],
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDocumentMessage(ChatMessage message, bool isMe) {
//     return GestureDetector(
//       onTap: () => _showMediaDialog(message),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color:
//                         isMe ? Colors.white.withOpacity(0.2) : Colors.grey[100],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     Icons.description,
//                     color: isMe ? Colors.white : Colors.grey[600],
//                     size: 32,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Document',
//                         style: TextStyle(
//                           color: isMe ? Colors.white : Colors.black,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _getFileExtension(message.message).toUpperCase(),
//                         style: TextStyle(
//                           color: isMe ? Colors.white70 : Colors.grey,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Icon(
//                   Icons.download,
//                   color: isMe ? Colors.white70 : Colors.grey,
//                   size: 20,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Text(
//                   message.formattedTime,
//                   style: TextStyle(
//                     color: isMe ? Colors.white70 : Colors.grey,
//                     fontSize: 12,
//                   ),
//                 ),
//                 if (isMe) ...[
//                   const SizedBox(width: 4),
//                   _buildMessageStatusIcon(message),
//                 ],
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMessageStatusIcon(ChatMessage message) {
//     final status = _messageStatus[message.messageId] ?? MessageStatus.sent;
//     IconData icon;
//     Color color;
//
//     switch (status) {
//       case MessageStatus.read:
//         icon = Icons.done_all;
//         color = Colors.blue;
//         break;
//       case MessageStatus.delivered:
//         icon = Icons.done_all;
//         color = Colors.grey;
//         break;
//       case MessageStatus.sent:
//         icon = Icons.done;
//         color = Colors.grey;
//         break;
//       default:
//         icon = Icons.access_time;
//         color = Colors.orange;
//     }
//
//     return Icon(
//       icon,
//       size: 16,
//       color: color,
//     );
//   }
//
//   Widget _buildInputArea() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 4,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             IconButton(
//               onPressed: () {
//                 setState(() {
//                   showMediaUploader = !showMediaUploader;
//                 });
//               },
//               icon: Icon(
//                 showMediaUploader ? Icons.close : Icons.attach_file,
//                 color: ColorConstants.primaryColor,
//               ),
//             ),
//             Expanded(
//               child: TextField(
//                 controller: _messageController,
//                 decoration: InputDecoration(
//                   hintText: 'Type a message...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(24),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//                 onSubmitted: (_) => _sendMessage(),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               decoration: BoxDecoration(
//                 color: _isConnected ? ColorConstants.primaryColor : Colors.grey,
//                 shape: BoxShape.circle,
//               ),
//               child: IconButton(
//                 onPressed: (isSending || !_isConnected) ? null : _sendMessage,
//                 icon: isSending
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation(Colors.white),
//                         ),
//                       )
//                     : const Icon(Icons.send, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// enum MessageStatus {
//   sent,
//   delivered,
//   read,
// }
//
// // Media View Screen (same as before)
// class MediaViewScreen extends StatefulWidget {
//   final ChatMessage message;
//
//   const MediaViewScreen({Key? key, required this.message}) : super(key: key);
//
//   @override
//   State<MediaViewScreen> createState() => _MediaViewScreenState();
// }
//
// class _MediaViewScreenState extends State<MediaViewScreen>
//     with WidgetsBindingObserver {
//   VideoPlayerController? _videoController;
//   bool _isVideoInitialized = false;
//   bool _isVideoLoading = false;
//   bool _hasVideoError = false;
//   String? _errorMessage;
//   bool _showControls = true;
//   Timer? _hideControlsTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     if (widget.message.messageType == 'VIDEO') {
//       _initializeVideo();
//     }
//   }
//
//   Future<void> _initializeVideo() async {
//     setState(() {
//       _isVideoLoading = true;
//       _hasVideoError = false;
//     });
//
//     try {
//       // Validate URL first
//       final uri = Uri.tryParse(widget.message.message);
//       if (uri == null || !uri.hasScheme) {
//         throw Exception('Invalid video URL format');
//       }
//
//       _videoController = VideoPlayerController.networkUrl(
//         uri,
//         videoPlayerOptions: VideoPlayerOptions(
//           allowBackgroundPlayback: false,
//           mixWithOthers: false,
//         ),
//         httpHeaders: {
//           'User-Agent': 'Flutter Video Player',
//           'Accept': 'video/*',
//         },
//       );
//
//       // Set up error listener before initialization
//       _videoController!.addListener(_videoListener);
//
//       // Initialize with timeout
//       await _videoController!.initialize().timeout(
//         const Duration(seconds: 30),
//         onTimeout: () {
//           throw Exception(
//               'Video loading timeout - please check your connection');
//         },
//       );
//
//       if (mounted) {
//         setState(() {
//           _isVideoInitialized = true;
//           _isVideoLoading = false;
//         });
//         _startHideControlsTimer();
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _hasVideoError = true;
//           _isVideoLoading = false;
//           _errorMessage = _getErrorMessage(e);
//         });
//       }
//       debugPrint('Error initializing video: $e');
//     }
//   }
//
//   String _getErrorMessage(dynamic error) {
//     final errorString = error.toString().toLowerCase();
//
//     if (errorString.contains('timeout')) {
//       return 'Video loading timeout. Please check your internet connection.';
//     } else if (errorString.contains('source error') ||
//         errorString.contains('exoplaybackexception')) {
//       return 'Video format not supported or file is corrupted.';
//     } else if (errorString.contains('network') ||
//         errorString.contains('connection')) {
//       return 'Network error. Please check your internet connection.';
//     } else if (errorString.contains('permission') ||
//         errorString.contains('access')) {
//       return 'Cannot access video file. Permission denied.';
//     } else if (errorString.contains('invalid') ||
//         errorString.contains('format')) {
//       return 'Invalid video URL or unsupported format.';
//     } else {
//       return 'Failed to load video. Please try again.';
//     }
//   }
//
//   void _videoListener() {
//     if (mounted && _videoController != null) {
//       // Check for errors
//       if (_videoController!.value.hasError) {
//         setState(() {
//           _hasVideoError = true;
//           _isVideoLoading = false;
//           _errorMessage = _getErrorMessage(
//               _videoController!.value.errorDescription ??
//                   'Unknown video error');
//         });
//         return;
//       }
//
//       setState(() {});
//     }
//   }
//
//   void _togglePlayPause() {
//     if (_videoController != null && _isVideoInitialized) {
//       setState(() {
//         _videoController!.value.isPlaying
//             ? _videoController!.pause()
//             : _videoController!.play();
//       });
//       _showControlsTemporarily();
//     }
//   }
//
//   void _showControlsTemporarily() {
//     setState(() {
//       _showControls = true;
//     });
//     _startHideControlsTimer();
//   }
//
//   void _startHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     _hideControlsTimer = Timer(const Duration(seconds: 3), () {
//       if (mounted && _videoController?.value.isPlaying == true) {
//         setState(() {
//           _showControls = false;
//         });
//       }
//     });
//   }
//
//   void _seekTo(Duration position) {
//     _videoController?.seekTo(position);
//     _showControlsTemporarily();
//   }
//
//   String _formatDuration(Duration duration) {
//     if (duration == Duration.zero) return '0:00';
//
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     final seconds = duration.inSeconds.remainder(60);
//
//     if (hours > 0) {
//       return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//     } else {
//       return '${minutes}:${seconds.toString().padLeft(2, '0')}';
//     }
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.paused) {
//       _videoController?.pause();
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _hideControlsTimer?.cancel();
//     _videoController?.removeListener(_videoListener);
//     _videoController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           if (widget.message.messageType == 'DOCUMENT')
//             IconButton(
//               icon: const Icon(Icons.download, color: Colors.white),
//               onPressed: () => _downloadDocument(),
//             ),
//         ],
//       ),
//       body: Center(
//         child: _buildMediaContent(),
//       ),
//     );
//   }
//
//   Widget _buildMediaContent() {
//     switch (widget.message.messageType) {
//       case 'IMAGE':
//         return Hero(
//           tag: 'image_${widget.message.messageId}',
//           child: InteractiveViewer(
//             minScale: 0.5,
//             maxScale: 3.0,
//             child: CachedNetworkImage(
//               imageUrl: widget.message.message,
//               fit: BoxFit.contain,
//               placeholder: (context, url) => const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               ),
//               errorWidget: (context, url, error) => const Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error, color: Colors.white, size: 64),
//                   SizedBox(height: 16),
//                   Text(
//                     'Failed to load image',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//
//       case 'VIDEO':
//         return Hero(
//           tag: 'video_${widget.message.messageId}',
//           child: _buildVideoPlayer(),
//         );
//
//       case 'DOCUMENT':
//         return Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.description, size: 128, color: Colors.white),
//             const SizedBox(height: 16),
//             const Text(
//               'Document',
//               style: TextStyle(color: Colors.white, fontSize: 24),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton.icon(
//               onPressed: _downloadDocument,
//               icon: const Icon(Icons.download),
//               label: const Text('Download'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: ColorConstants.primaryColor,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         );
//
//       default:
//         return const Text(
//           'Unsupported media type',
//           style: TextStyle(color: Colors.white),
//         );
//     }
//   }
//
//   Widget _buildVideoPlayer() {
//     if (_isVideoLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.white),
//             SizedBox(height: 16),
//             Text(
//               'Loading video...',
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (_hasVideoError) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error, size: 64, color: Colors.white),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: Text(
//                 _errorMessage ?? 'Failed to load video',
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _initializeVideo,
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Retry'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: ColorConstants.primaryColor,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 ElevatedButton.icon(
//                   onPressed: () => _downloadDocument(),
//                   icon: const Icon(Icons.download),
//                   label: const Text('Download'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[700],
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (!_isVideoInitialized || _videoController == null) {
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.white),
//       );
//     }
//
//     return GestureDetector(
//       onTap: _showControlsTemporarily,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           AspectRatio(
//             aspectRatio: _videoController!.value.aspectRatio,
//             child: VideoPlayer(_videoController!),
//           ),
//           if (_showControls) _buildVideoControls(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildVideoControls() {
//     final isPlaying = _videoController?.value.isPlaying ?? false;
//     final position = _videoController?.value.position ?? Duration.zero;
//     final duration = _videoController?.value.duration ?? Duration.zero;
//     final isBuffering = _videoController?.value.isBuffering ?? false;
//
//     return AnimatedOpacity(
//       opacity: _showControls ? 1.0 : 0.0,
//       duration: const Duration(milliseconds: 300),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.black.withOpacity(0.7),
//               Colors.transparent,
//               Colors.black.withOpacity(0.7),
//             ],
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Play/Pause button
//             if (isBuffering)
//               const CircularProgressIndicator(color: Colors.white)
//             else
//               GestureDetector(
//                 onTap: _togglePlayPause,
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: const BoxDecoration(
//                     color: Colors.black54,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: Colors.white,
//                     size: 48,
//                   ),
//                 ),
//               ),
//
//             const Spacer(),
//
//             // Progress bar and time
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   SliderTheme(
//                     data: SliderTheme.of(context).copyWith(
//                       activeTrackColor: Colors.white,
//                       inactiveTrackColor: Colors.white30,
//                       thumbColor: Colors.white,
//                       overlayColor: Colors.white.withOpacity(0.2),
//                       thumbShape: const RoundSliderThumbShape(
//                         enabledThumbRadius: 6,
//                       ),
//                       trackHeight: 2,
//                     ),
//                     child: Slider(
//                       value: duration.inMilliseconds > 0
//                           ? position.inMilliseconds / duration.inMilliseconds
//                           : 0.0,
//                       onChanged: (value) {
//                         final newPosition = Duration(
//                           milliseconds:
//                               (value * duration.inMilliseconds).round(),
//                         );
//                         _seekTo(newPosition);
//                       },
//                     ),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         _formatDuration(position),
//                         style:
//                             const TextStyle(color: Colors.white, fontSize: 12),
//                       ),
//                       Text(
//                         _formatDuration(duration),
//                         style:
//                             const TextStyle(color: Colors.white, fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _downloadDocument() async {
//     try {
//       final uri = Uri.parse(widget.message.message);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Cannot open document'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error downloading document: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to download document'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }
