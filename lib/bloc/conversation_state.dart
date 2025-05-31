import 'package:equatable/equatable.dart';
import '../models/conversation.dart';
import '../models/message.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<Conversation> conversations;
  final Map<String, List<Message>> messages;

  const ConversationLoaded({
    required this.conversations,
    required this.messages,
  });

  @override
  List<Object?> get props => [conversations, messages];

  ConversationLoaded copyWith({
    List<Conversation>? conversations,
    Map<String, List<Message>>? messages,
  }) {
    return ConversationLoaded(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
    );
  }
}

class ConversationError extends ConversationState {
  final String message;

  const ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}
