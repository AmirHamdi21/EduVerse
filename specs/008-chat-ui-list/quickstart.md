# Quickstart: Unified Chat UI — Conversation List

To integrate the new single Conversation List across role screens:

1. Delete existing widget imports from the screen (e.g., student chat widgets).
2. Ensure the parent `Scaffold` or nested navigation provides access to the global `ChatBloc` (provided at `MaterialApp` level).
3. Insert the single `SharedConversationList` widget as the main body.
4. Pass the appropriate `accentColor` and `isDark` values (retrieved from `Theme.of(context)`).

Example implementation in a screen:

```dart
class AdminMessagesScreen extends StatelessWidget {
  const AdminMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SharedConversationList(
        accentColor: theme.colorScheme.primary,
        isDark: theme.brightness == Brightness.dark,
        onSearchQuery: (query) => context.read<ChatBloc>().add(SearchConversations(query)),
        onFilterSelected: (filter) => context.read<ChatBloc>().add(FilterConversations(filter)),
      ),
    );
  }
}
```