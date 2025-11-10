import 'package:flutter/material.dart';
import 'package:r_w_r/constants/color_constants.dart';

import '../user_screens/chat/message.dart';

class ChatHistoryPage extends StatelessWidget {
  final List<ChatItem> chatHistory = [
    ChatItem(
      name: 'Alice Johnson',
      lastMessageTime: '10:30 AM',
    ),
    ChatItem(
      name: 'Bob Smith',
      lastMessageTime: 'Yesterday',
    ),
    ChatItem(
      name: 'Charlie Brown',
      lastMessageTime: '2:15 PM',
    ),
    ChatItem(
      name: 'Diana Prince',
      lastMessageTime: 'Monday',
    ),
    ChatItem(
      name: 'Edward Elric',
      lastMessageTime: '9:00 AM',
    ),
    ChatItem(
      name: 'Fiona Gallagher',
      lastMessageTime: '12:45 PM',
    ),
    ChatItem(
      name: 'George Michael',
      lastMessageTime: 'Tuesday',
    ),
    ChatItem(
      name: 'Hannah Montana',
      lastMessageTime: '3:00 PM',
    ),
    ChatItem(
      name: 'Ivy League',
      lastMessageTime: '10:45 AM',
    ),
    ChatItem(
      name: 'Jack Sparrow',
      lastMessageTime: 'Yesterday',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat History',
          style: TextStyle(
            color: ColorConstants.white,
          ),
        ),
        backgroundColor: ColorConstants.primaryColor,
      ),
      body: ListView.builder(
        itemCount: chatHistory.length,
        itemBuilder: (context, index) {
          final chat = chatHistory[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.grey,
                ),
                title: Text(chat.name),
                subtitle: Text('Last message at ${chat.lastMessageTime}'),
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => MessagingScreen()));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatItem {
  final String name;
  final String lastMessageTime;

  ChatItem({
    required this.name,
    required this.lastMessageTime,
  });
}
