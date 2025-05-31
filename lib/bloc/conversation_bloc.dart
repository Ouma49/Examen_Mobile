import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../data/mock_data.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final _uuid = const Uuid();

  ConversationBloc() : super(ConversationInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<CreateConversation>(_onCreateConversation);
    on<SearchConversations>(_onSearchConversations);
    on<DeleteConversation>(_onDeleteConversation);
  }

  void _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) {
    emit(ConversationLoading());
    try {
      emit(
        ConversationLoaded(
          conversations: mockConversations,
          messages: mockMessages,
        ),
      );
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void _onSendMessage(SendMessage event, Emitter<ConversationState> emit) {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;
      final newMessage = Message(
        id: _uuid.v4(),
        conversationId: event.conversationId,
        content: event.content,
        isMe: true,
        timestamp: DateTime.now(),
      );

      final updatedMessages = Map<String, List<Message>>.from(
        currentState.messages,
      );
      updatedMessages[event.conversationId] = [
        ...(updatedMessages[event.conversationId] ?? []),
        newMessage,
      ];

      final updatedConversations =
          currentState.conversations.map((conversation) {
        if (conversation.id == event.conversationId) {
          return conversation.copyWith(
            lastMessage: event.content,
            timestamp: DateTime.now(),
          );
        }
        return conversation;
      }).toList();

      emit(
        currentState.copyWith(
          conversations: updatedConversations,
          messages: updatedMessages,
        ),
      );
    }
  }

  void _onReceiveMessage(
    ReceiveMessage event,
    Emitter<ConversationState> emit,
  ) {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;
      final updatedMessages = Map<String, List<Message>>.from(
        currentState.messages,
      );
      updatedMessages[event.message.conversationId] = [
        ...(updatedMessages[event.message.conversationId] ?? []),
        event.message,
      ];

      final updatedConversations =
          currentState.conversations.map((conversation) {
        if (conversation.id == event.message.conversationId) {
          return conversation.copyWith(
            lastMessage: event.message.content,
            timestamp: DateTime.now(),
            unreadCount: conversation.unreadCount + 1,
          );
        }
        return conversation;
      }).toList();

      emit(
        currentState.copyWith(
          conversations: updatedConversations,
          messages: updatedMessages,
        ),
      );
    }
  }

  void _onCreateConversation(
    CreateConversation event,
    Emitter<ConversationState> emit,
  ) {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;
      final conversationId = _uuid.v4();

      final newConversation = Conversation(
        id: conversationId,
        contactName: event.contactName,
        lastMessage: event.initialMessage,
        timestamp: DateTime.now(),
        unreadCount: 0,
      );

      final newMessage = Message(
        id: _uuid.v4(),
        conversationId: conversationId,
        content: event.initialMessage,
        isMe: true,
        timestamp: DateTime.now(),
      );

      final updatedMessages =
          Map<String, List<Message>>.from(currentState.messages);
      updatedMessages[conversationId] = [newMessage];

      emit(
        currentState.copyWith(
          conversations: [...currentState.conversations, newConversation],
          messages: updatedMessages,
        ),
      );

      // Simulate receiving a response after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        final responseMessage = Message(
          id: _uuid.v4(),
          conversationId: conversationId,
          content: "Thanks for your message! I'll get back to you soon.",
          isMe: false,
          timestamp: DateTime.now(),
        );
        add(ReceiveMessage(responseMessage));
      });
    }
  }

  void _onSearchConversations(
    SearchConversations event,
    Emitter<ConversationState> emit,
  ) {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;
      if (event.query.isEmpty) {
        emit(currentState.copyWith(
          conversations: mockConversations,
        ));
        return;
      }

      final filteredConversations = currentState.conversations
          .where((conversation) =>
              conversation.contactName
                  .toLowerCase()
                  .contains(event.query.toLowerCase()) ||
              conversation.lastMessage
                  .toLowerCase()
                  .contains(event.query.toLowerCase()))
          .toList();

      emit(currentState.copyWith(
        conversations: filteredConversations,
      ));
    }
  }

  void _onDeleteConversation(
    DeleteConversation event,
    Emitter<ConversationState> emit,
  ) {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;
      final updatedConversations = currentState.conversations
          .where((conversation) => conversation.id != event.conversationId)
          .toList();

      final updatedMessages =
          Map<String, List<Message>>.from(currentState.messages);
      updatedMessages.remove(event.conversationId);

      emit(
        currentState.copyWith(
          conversations: updatedConversations,
          messages: updatedMessages,
        ),
      );
    }
  }
}
