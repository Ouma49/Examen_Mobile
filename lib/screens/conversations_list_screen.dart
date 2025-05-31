import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import '../models/conversation.dart';
import 'conversation_details_screen.dart';

class ConversationsListScreen extends StatelessWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          if (state is ConversationInitial) {
            context.read<ConversationBloc>().add(const LoadConversations());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConversationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConversationError) {
            return Center(child: Text(state.message));
          }

          if (state is ConversationLoaded) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchBar(
                    hintText: 'Search conversations...',
                    leading: const Icon(Icons.search),
                    onChanged: (value) {
                      context.read<ConversationBloc>().add(
                            SearchConversations(value),
                          );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = state.conversations[index];
                      return ConversationListTile(
                        conversation: conversation,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConversationDetailsScreen(
                                conversationId: conversation.id,
                                contactName: conversation.contactName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showNewConversationDialog(context);
        },
        icon: const Icon(Icons.edit),
        label: const Text('New Message'),
      ),
    );
  }

  void _showNewConversationDialog(BuildContext context) {
    final contactController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Conversation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: contactController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                hintText: 'Enter contact name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Enter your message',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (contactController.text.isNotEmpty &&
                  messageController.text.isNotEmpty) {
                context.read<ConversationBloc>().add(
                      CreateConversation(
                        contactName: contactController.text,
                        initialMessage: messageController.text,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class ConversationListTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationListTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = conversation.unreadCount > 0;

    return Dismissible(
      key: Key(conversation.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context.read<ConversationBloc>().add(
              DeleteConversation(conversation.id),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Conversation with ${conversation.contactName} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // TODO: Implement undo functionality if needed
              },
            ),
          ),
        );
      },
      child: Material(
        color: isUnread
            ? theme.colorScheme.surface
            : theme.colorScheme.surface.withOpacity(0.7),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                _buildAvatar(context),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            conversation.contactName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isUnread
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.8),
                            ),
                          ),
                          Text(
                            _formatTimestamp(conversation.timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isUnread
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                fontWeight: isUnread
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                conversation.unreadCount.toString(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          conversation.contactName[0].toUpperCase(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'Today at ${_formatTime(timestamp)}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      return _getWeekday(timestamp.weekday);
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }
}
