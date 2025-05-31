import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String contactName;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.contactName,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [id, contactName, lastMessage, timestamp, unreadCount];

  Conversation copyWith({
    String? id,
    String? contactName,
    String? lastMessage,
    DateTime? timestamp,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
} 