import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rwd/components/common_parent_container.dart';
import 'package:rwd/constants/api_constants.dart';
import 'package:rwd/utils/common_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/api_model/chat/chat_model.dart';
import '../../../api/api_service/chat/chat_history_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/color.dart';
import 'message.dart';

class ChatListController {
  void Function()? _refreshCallback;

  void _setRefreshCallback(void Function() callback) {
    _refreshCallback = callback;
  }

  void refresh() {
    _refreshCallback?.call();
  }
}

class ChatListScreen extends StatefulWidget {
  final ChatListController? controller;

  const ChatListScreen({super.key, this.controller});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  List<ChatItem> chatListDisplay = [];
  List<ChatItem> chatList = [];
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _deletingChatId;
  bool _isDisposed = false;
  bool _hasLoadedOnce = false;
  TextEditingController searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  bool _selectionMode = false;
  Set<String> _selectedChatIds = {};
  Set<String> _pinnedChatIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPinnedChats();
    widget.controller?._setRefreshCallback(() {
      if (mounted && !_isDisposed) {
        _loadChatList();
      }
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _loadChatList();
      }
    });
  }

  Future<void> _loadPinnedChats() async {
    final prefs = await SharedPreferences.getInstance();
    _pinnedChatIds = prefs.getStringList('pinned_chats')?.toSet() ?? {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedOnce && !_isDisposed) {
      _loadChatList();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && !_isDisposed) {
      _loadChatList();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchDebounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadChatList() async {
    if (_isDisposed) {
      return;
    }

    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final response = await ChatApiService.getChatList();

      if (_isDisposed || !mounted) {
        return;
      }

      if (response.status) {
        for (int i = 0; i < response.data.length; i++) {
          final chat = response.data[i];
          developer.log('Chat $i: $chat', name: 'ChatListScreen');
        }

        if (mounted) {
          setState(() {
            chatListDisplay = List<ChatItem>.from(response.data);
            chatList = List<ChatItem>.from(response.data);
            _sortChatList();
            isLoading = false;
            _hasLoadedOnce = true;
          });
          _animationController.forward();
        }
      } else {
        final error = response.message.isNotEmpty
            ? response.message
            : 'Failed to load chat list';

        if (mounted) {
          setState(() {
            errorMessage = error;
            isLoading = false;
            _hasLoadedOnce = true;
          });
        }
      }
    } catch (e) {
      if (_isDisposed || !mounted) {
        return;
      }

      final error = e.toString().replaceAll('Exception: ', '');

      if (mounted) {
        setState(() {
          errorMessage = error;
          isLoading = false;
          _hasLoadedOnce = true;
        });
      }
    }
  }

  Future<void> _deleteChat(ChatItem chat) async {
    if (_isDisposed || !mounted) return;
    setState(() {
      _deletingChatId = chat.chatId;
    });

    try {
      final response = await ChatApiService.deleteChat(chat.chatId);

      if (_isDisposed || !mounted) {
        return;
      }

      if (response.status) {
        // Remove the chat from the list
        if (mounted) {
          setState(() {
            chatListDisplay.removeWhere((item) => item.chatId == chat.chatId);
            _deletingChatId = null;
          });
        }

        // Show success message
        _showSnackBar(
          message: response.message.isNotEmpty
              ? response.message
              : 'Chat deleted successfully',
          isSuccess: true,
        );
      } else {
        if (mounted) {
          setState(() {
            _deletingChatId = null;
          });
        }

        _showSnackBar(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to delete chat',
          isSuccess: false,
        );
      }
    } catch (e) {
      if (_isDisposed || !mounted) return;

      if (mounted) {
        setState(() {
          _deletingChatId = null;
        });
      }

      final errorMessage = e.toString().replaceAll('Exception: ', '');

      _showSnackBar(
        message: 'Failed to delete chat: $errorMessage',
        isSuccess: false,
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    final localizations = AppLocalizations.of(context)!;

    if (!mounted) return;

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
              Text(
                localizations.delete_chat,
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
                'Are you sure you want to delete the selected chats?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.action_cannot_be_undone,
                // 'This action cannot be undone.',
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
                localizations.cancel,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSelectedChats();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                localizations.delete,
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
    if (!mounted) return;

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

  String _formatTimestamp(DateTime? timestamp) {
    // Return a default message if timestamp is null
    if (timestamp == null) {
      return '';
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonParentContainer(
        showLargeGradient: false,
        child: Column(
          children: [
            SafeArea(
              child: Container(
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (_selectionMode)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectionMode = false;
                            _selectedChatIds.clear();
                          });
                        },
                      )
                    else
                      Text(
                        "Chat History",
                        style:
                            CommonUtils.commonTitleStyle(color: Colors.white),
                      ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      chatListDisplay.length.toString(),
                      style: CommonUtils.commonTitleStyle(
                          color: Colors.white, fontSize: 12),
                    ),
                    Spacer(),
                    if (_selectionMode) ...[
                      IconButton(
                        icon: const Icon(Icons.push_pin),
                        onPressed: _pinSelectedChats,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog();
                        },
                      ),
                    ]
                    /* Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 24,
                      ),*/
                  ],
                ),
              ),
            ),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: Colors.white,
                  height: 1,
                )),
            const SizedBox(
              height: 10,
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
              ),
              child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    _searchDebounceTimer?.cancel();
                    _searchDebounceTimer = Timer(
                      const Duration(milliseconds: 500),
                      () => _filterList(value),
                    );
                  },
                  style: TextStyle(
                      fontFamily: AppConstants.ptSansFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                      hint: Text("Search",
                          style: TextStyle(
                            fontFamily: AppConstants.ptSansFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          )),
                      hintStyle: TextStyle(
                          fontFamily: AppConstants.ptSansFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      border: InputBorder.none)),
            ),
            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  developer.log('Manual refresh triggered',
                      name: 'ChatListScreen');
                  await _loadChatList();
                },
                color: Colors.white,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSelectedChats() async {
    for (final chatId in _selectedChatIds) {
      await ChatApiService.deleteChat(chatId);
    }

    setState(() {
      chatListDisplay.removeWhere((e) => _selectedChatIds.contains(e.chatId));
      _selectedChatIds.clear();
      _selectionMode = false;
    });
  }

  Future<void> _pinSelectedChats() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      for (final id in _selectedChatIds) {
        if (_pinnedChatIds.contains(id)) {
          _pinnedChatIds.remove(id);
        } else {
          _pinnedChatIds.add(id);
        }
      }
      _selectionMode = false;
      _selectedChatIds.clear();
    });

    await prefs.setStringList(
      'pinned_chats',
      _pinnedChatIds.toList(),
    );

    _loadChatList();
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingWidget();
    } else if (errorMessage != null) {
      return _buildErrorWidget();
    } else if (chatListDisplay.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildChatList();
    }
  }

  Widget _buildLoadingWidget() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 16),
          Text(
            localizations.loading_chats,
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
    final localizations = AppLocalizations.of(context)!;

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
              localizations.something_went_wrong,
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
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _loadChatList();
              },
              icon: const Icon(Icons.refresh),
              label: Text(localizations.retry),
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
    final localizations = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
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
                localizations.no_chats_yet,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.start_conversation_message,
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chatListDisplay.length,
        itemBuilder: (context, index) {
          final chat = chatListDisplay[index];
          developer.log('Building chat item $index: ${chat.name}',
              name: 'ChatListScreen');
          return _buildChatItem(chat, index);
        },
      ),
    );
  }

  Widget _buildChatItem(ChatItem chat, int index) {
    final isDeleting = _deletingChatId == chat.chatId;
    final localizations = AppLocalizations.of(context)!;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_selectionMode) {
                      _toggleSelection(chat.chatId);
                    } else {
                      _onChatTap(chat);
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      _selectionMode = true;
                      _selectedChatIds.add(chat.chatId);
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  /*   onTap: isDeleting ? null : () => _onChatTap(chat),
                  onLongPress: isDeleting
                      ? null
                      : () => _showDeleteConfirmationDialog(chat),*/
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _selectedChatIds.contains(chat.chatId)
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_selectionMode)
                          Checkbox(
                            value: _selectedChatIds.contains(chat.chatId),
                            onChanged: (_) => _toggleSelection(chat.chatId),
                          ),
                        _buildAvatar(chat, isDeleting),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 14,
                              ),
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
                                        fontFamily: AppConstants.ptSansFont,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDeleting
                                            ? Colors.grey[400]
                                            : Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                (chat.image ?? "").isNotEmpty
                                    ? "Image"
                                    : chat.lastMessage,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: AppConstants.ptSansFont,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isDeleting)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    localizations.deleting,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red[400],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              if (isDeleting)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.red),
                                  ),
                                )
                              else
                                Text(
                                  _formatTimestamp(chat.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          formatChatTime(chat.lastMessageDateTime ?? ""),
                          style: CommonUtils.commonTitleStyle(
                              fontSize: 12,
                              weight: FontWeight.w400,
                              color: Color(0x66000000)),
                        ),
                        if (_pinnedChatIds.contains(chat.chatId))
                          const Icon(Icons.push_pin, size: 16),
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

  void _toggleSelection(String chatId) {
    setState(() {
      if (_selectedChatIds.contains(chatId)) {
        _selectedChatIds.remove(chatId);
        if (_selectedChatIds.isEmpty) {
          _selectionMode = false;
        }
      } else {
        _selectedChatIds.add(chatId);
      }
    });
  }

  Widget _buildAvatar(ChatItem chat, bool isDeleting) {
    developer.log('Building avatar for ${chat.name} with image: ${chat.image}',
        name: 'ChatListScreen');

    return Container(
      width: 48,
      height: 48,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10))),
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
                    developer.log('Image loaded successfully for ${chat.name}',
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                },
              )
            : _buildDefaultAvatar(chat.name),
      ),
    );
  }

  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Widget _buildDefaultAvatar(String name) {
    final displayChar = name
        .split(" ")
        .map(
          (e) => e.split('')[0],
        )
        .join('');
    developer.log('Building default avatar with character: $displayChar',
        name: 'ChatListScreen');

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        gradient: LinearGradient(
          colors: [gradientFirst, gradientSecond],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          displayChar,
          style: TextStyle(
            fontFamily: AppConstants.ptSansFont,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _onChatTap(ChatItem chat) {
    if (!mounted) return;

    // // TODO: Navigate to chat detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagingScreen(
          name: chat.name,
          image: chat.image,
          conversationId: chat.chatId,
          otherPersonUserId: chat.chatId,
          chatId: chat.chatId,
          otherPersonId: "",
          // recipientId: chat.userId,
        ),
      ),
    );
  }

  void _filterList(String value) {
    if (value.isEmpty) {
      chatListDisplay.clear();
      chatListDisplay.addAll(chatList);
      updateState();
      return;
    }
    chatListDisplay.clear();
    for (var element in chatList) {
      if (element.name.toLowerCase().contains(value.toLowerCase())) {
        chatListDisplay.add(element);
      }
    }
    updateState();
  }

  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _sortChatList() {
    chatListDisplay.sort((a, b) {
      final aPinned = _pinnedChatIds.contains(a.chatId);
      final bPinned = _pinnedChatIds.contains(b.chatId);

      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return 0;
    });
  }
}

String formatChatTime(String isoTime) {
  final DateTime msgTime = DateTime.parse(isoTime);
  final formattedDateTimeChat =
      DateFormat("dd-MM-yyyy HH:mm:ss").format(msgTime);
  final formattedDateTimeNow =
      DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now());
  final format = DateFormat('dd-MM-yyyy HH:mm:ss');

  DateTime start = format.parse(formattedDateTimeChat);
  DateTime end = format.parse(formattedDateTimeNow);

  Duration difference = end.difference(start);
  if (difference.inMinutes <= 0) {
    return 'Just Now';
  }
  // Minutes ago
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }

  // Hours ago
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }

  // Days ago (up to 5 days)
  if (difference.inDays <= 5) {
    return difference.inDays == 1
        ? '1 day ago'
        : '${difference.inDays} days ago';
  }

  // Older than 5 days → formatted date
  return DateFormat('dd MMM yyyy').format(msgTime);
}
