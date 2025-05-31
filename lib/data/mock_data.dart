import '../models/conversation.dart';
import '../models/message.dart';

final List<Conversation> mockConversations = [
  Conversation(
    id: '1',
    contactName: 'Hajar Daoudi',
    lastMessage: 'Hey, how are you?',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    unreadCount: 2,
  ),
  Conversation(
    id: '2',
    contactName: 'Ayman Maamouri',
    lastMessage: 'See you tomorrow!',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    unreadCount: 0,
  ),
  Conversation(
    id: '3',
    contactName: 'Mehdi Daoudi',
    lastMessage: 'The meeting is at 2 PM',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    unreadCount: 1,
  ),
];

final Map<String, List<Message>> mockMessages = {
  '1': [
    Message(
      id: '1',
      conversationId: '1',
      content: 'Hey, how are you?',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    Message(
      id: '2',
      conversationId: '1',
      content: 'I\'m good, thanks! How about you?',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
  ],
  '2': [
    Message(
      id: '3',
      conversationId: '2',
      content: 'Are we still meeting tomorrow?',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Message(
      id: '4',
      conversationId: '2',
      content: 'Yes, see you tomorrow!',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ],
  '3': [
    Message(
      id: '5',
      conversationId: '3',
      content: 'Don\'t forget about the meeting',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Message(
      id: '6',
      conversationId: '3',
      content: 'The meeting is at 2 PM',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ],
};
