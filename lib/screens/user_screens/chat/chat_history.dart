import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:r_w_r/constants/color_constants.dart';

import '../../../api/api_model/chat/chat_model.dart';
import '../../../api/api_service/chat/chat_history_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin {
  List<ChatItem> chatList = [];
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Track which chat is being deleted to show loading state
  String? _deletingChatId;

  @override
  void initState() {
    super.initState();
    developer.log('ChatListScreen initialized', name: 'ChatListScreen');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadChatList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadChatList() async {
    developer.log('Loading chat list...', name: 'ChatListScreen');

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await ChatApiService.getChatList();
      developer.log(
          'Received response: status=${response.status}, message=${response.message}, data count=${response.data.length}',
          name: 'ChatListScreen');

      if (response.status) {
        developer.log(
            'Chat list loaded successfully with ${response.data.length} items',
            name: 'ChatListScreen');

        // Debug each chat item
        for (int i = 0; i < response.data.length; i++) {
          final chat = response.data[i];
          developer.log('Chat $i: $chat', name: 'ChatListScreen');
        }

        setState(() {
          chatList = response.data;
          isLoading = false;
        });
        _animationController.forward();
      } else {
        final error = response.message.isNotEmpty
            ? response.message
            : 'Failed to load chat list';
        developer.log('Chat list loading failed: $error',
            name: 'ChatListScreen');

        setState(() {
          errorMessage = error;
          isLoading = false;
        });
      }
    } catch (e) {
      final error = e.toString().replaceAll('Exception: ', '');
      developer.log('Exception occurred while loading chat list: $error',
          name: 'ChatListScreen');

      setState(() {
        errorMessage = error;
        isLoading = false;
      });
    }
  }

  Future<void> _deleteChat(ChatItem chat) async {
    developer.log('Starting chat deletion for: ${chat.chatId}',
        name: 'ChatListScreen');

    setState(() {
      _deletingChatId = chat.chatId;
    });

    try {
      final response = await ChatApiService.deleteChat(chat.chatId);
      developer.log(
          'Delete response: status=${response.status}, message=${response.message}',
          name: 'ChatListScreen');

      if (response.status) {
        // Remove the chat from the list
        setState(() {
          chatList.removeWhere((item) => item.chatId == chat.chatId);
          _deletingChatId = null;
        });

        // Show success message
        _showSnackBar(
          message: response.message.isNotEmpty
              ? response.message
              : 'Chat deleted successfully',
          isSuccess: true,
        );

        developer.log('Chat deleted successfully: ${chat.chatId}',
            name: 'ChatListScreen');
      } else {
        setState(() {
          _deletingChatId = null;
        });

        _showSnackBar(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to delete chat',
          isSuccess: false,
        );

        developer.log('Chat deletion failed: ${response.message}',
            name: 'ChatListScreen');
      }
    } catch (e) {
      setState(() {
        _deletingChatId = null;
      });

      final errorMessage = e.toString().replaceAll('Exception: ', '');
      developer.log('Exception during chat deletion: $errorMessage',
          name: 'ChatListScreen');

      _showSnackBar(
        message: 'Failed to delete chat: $errorMessage',
        isSuccess: false,
      );
    }
  }

  void _showDeleteConfirmationDialog(ChatItem chat) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete Chat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this chat with ${chat.name.isNotEmpty ? chat.name : 'Unknown User'}?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                developer.log('Delete dialog cancelled',
                    name: 'ChatListScreen');
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteChat(chat);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar({required String message, required bool isSuccess}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green[600] : Colors.red[600],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getCauseColor(String cause) {
    final normalizedCause = cause.toUpperCase();
    developer.log('Getting color for cause: $normalizedCause',
        name: 'ChatListScreen');

    switch (normalizedCause) {
      case 'DRIVER':
        return Colors.blue;
      case 'PASSENGER':
        return Colors.green;
      case 'ADMIN':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        leading: Icon(
          Icons.circle_rounded,
          color: ColorConstants.primaryColor,
        ),
        backgroundColor: ColorConstants.primaryColor,
        centerTitle: true,
        title: const Text(
          'Message',
          style: TextStyle(
            color: ColorConstants.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadChatList,
        color: Colors.blue,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    developer.log(
        'Building body - isLoading: $isLoading, errorMessage: $errorMessage, chatList length: ${chatList.length}',
        name: 'ChatListScreen');

    if (isLoading) {
      return _buildLoadingWidget();
    } else if (errorMessage != null) {
      return _buildErrorWidget();
    } else if (chatList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildChatList();
    }
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 16),
          Text(
            'Loading chats...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadChatList,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No chats yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start a conversation to see it here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    developer.log('Building chat list with ${chatList.length} items',
        name: 'ChatListScreen');

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final chat = chatList[index];
          developer.log('Building chat item $index: ${chat.name}',
              name: 'ChatListScreen');
          return _buildChatItem(chat, index);
        },
      ),
    );
  }

  Widget _buildChatItem(ChatItem chat, int index) {
    developer.log(
        'Building chat item: name=${chat.name}, image=${chat.image}',
        name: 'ChatListScreen');

    final isDeleting = _deletingChatId == chat.chatId;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isDeleting ? null : () => _onChatTap(chat),
                  onLongPress: isDeleting
                      ? null
                      : () => _showDeleteConfirmationDialog(chat),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildAvatar(chat, isDeleting),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      chat.name.isNotEmpty
                                          ? chat.name
                                          : 'Unknown User',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDeleting
                                            ? Colors.grey[400]
                                            : Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isDeleting)
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.red),
                                      ),
                                    )
                                  else
                                    Text(
                                      _formatTimestamp(
                                          chat.timestamp ?? DateTime.now()),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // if (chat.cause.isNotEmpty)
                              //   Container(
                              //     padding: const EdgeInsets.symmetric(
                              //       horizontal: 8,
                              //       vertical: 4,
                              //     ),
                              //     decoration: BoxDecoration(
                              //       color: _getCauseColor(chat.cause)
                              //           .withOpacity(isDeleting ? 0.05 : 0.1),
                              //       borderRadius: BorderRadius.circular(12),
                              //     ),
                              //     child: Text(
                              //       chat.cause.toUpperCase(),
                              //       style: TextStyle(
                              //         fontSize: 12,
                              //         color: isDeleting
                              //             ? Colors.grey[400]
                              //             : _getCauseColor(chat.cause),
                              //         fontWeight: FontWeight.w500,
                              //       ),
                              //     ),
                              //   ),
                              if (isDeleting)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Deleting...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red[400],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isDeleting)
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(ChatItem chat, bool isDeleting) {
    developer.log('Building avatar for ${chat.name} with image: ${chat.image}',
        name: 'ChatListScreen');

    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Opacity(
          opacity: isDeleting ? 0.5 : 1.0,
          child: chat.image.isNotEmpty && _isValidImageUrl(chat.image)
              ? Image.network(
                  chat.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    developer.log('Image load error for ${chat.image}: $error',
                        name: 'ChatListScreen');
                    return _buildDefaultAvatar(chat.name);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      developer.log(
                          'Image loaded successfully for ${chat.name}',
                          name: 'ChatListScreen');
                      return child;
                    }
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.blue[300]!, Colors.blue[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    );
                  },
                )
              : _buildDefaultAvatar(chat.name),
        ),
      ),
    );
  }

  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      developer.log('Invalid image URL: $url', name: 'ChatListScreen');
      return false;
    }
  }

  Widget _buildDefaultAvatar(String name) {
    final displayChar = name.isNotEmpty ? name[0].toUpperCase() : '?';
    developer.log('Building default avatar with character: $displayChar',
        name: 'ChatListScreen');

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue[300]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          displayChar,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _onChatTap(ChatItem chat) {
    developer.log('Chat tapped: ${chat.name} (${chat.chatId})',
        name: 'ChatListScreen');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${chat.name}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // // TODO: Navigate to chat detail screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => MessagingScreen(
    //         userId: driver.userId, cause: "DRIVER"
    //
    //     ),
    //   ),
    // );
  }
}
