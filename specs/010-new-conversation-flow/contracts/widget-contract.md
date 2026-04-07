# Widget Contract: SharedNewChatDialog

**Feature**: Phase 5 - New Conversation Flow  
**Widget Path**: `lib/widgets/shared/chat/shared_new_chat_dialog.dart`  
**Type**: Stateless Widget (with BlocBuilder for reactive UI)

## Purpose

A reusable dialog widget that provides a complete UI for creating new direct or group conversations. The dialog handles user search, participant selection, mode toggling, and conversation creation with full error handling and retry capability.

---

## Public Interface

### Constructor

```dart
class SharedNewChatDialog extends StatelessWidget {
  const SharedNewChatDialog({
    super.key,
  });
}
```

**Notes**:
- No props required - all state managed through ChatBloc
- Dialog is shown via `showDialog()` standard Flutter API
- Automatically integrates with existing ChatBloc in context

---

## User Interactions

### 1. Search Users

**Trigger**: User types in search TextField  
**Action**: Dispatches `ChatSearchUsersRequested(query)` with 400ms debounce  
**Visual Feedback**:
- Loading spinner while `state.userSearchLoading == true`
- Results list appears below search field
- Empty state message if no results
- Error message with "Retry" button on failure

### 2. Select User (Direct Mode)

**Trigger**: User taps on search result  
**Action**: Dispatches `ChatParticipantAdded(user)`  
**Visual Effect**:
- Selected user shown as chip above search field
- Search results cleared
- Search field cleared

### 3. Select Multiple Users (Group Mode)

**Trigger**: User taps multiple search results  
**Action**: Dispatches `ChatParticipantAdded(user)` for each  
**Visual Effect**:
- Multiple chips displayed in Wrap widget
- Each chip has remove icon (X)
- Search field remains active for more selections

### 4. Remove Participant

**Trigger**: User taps X icon on participant chip  
**Action**: Dispatches `ChatParticipantRemoved(userId)`  
**Visual Effect**: Chip disappears from selection

### 5. Toggle Conversation Mode

**Trigger**: User taps "Direct" or "Group" toggle button  
**Action**: Dispatches `ChatConversationModeChanged(mode)`  
**Visual Effect**:
- Group name field appears/disappears
- Selection behavior changes (single vs. multiple)
- Validation rules change

### 6. Enter Group Name

**Trigger**: User types in group name TextField (Group mode only)  
**Action**: Local state, passed to event on submit  
**Validation**: Required for group mode

### 7. Enter Initial Message

**Trigger**: User types in message TextField  
**Action**: Local state, passed to event on submit  
**Validation**: Optional for all modes

### 8. Start Conversation

**Trigger**: User taps "Start Conversation" button  
**Action**: Dispatches `ChatStartConversationRequested` with validation  
**Visual Feedback**:
- Loading spinner on button
- Disabled state while `state.creatingConversation == true`
- Error message below button if creation fails
- Dialog closes on success (via BlocListener)

### 9. Cancel/Close

**Trigger**: User taps Cancel button or taps outside dialog  
**Action**: Dispatches `ChatNewConversationDialogReset()`, then Navigator.pop()  
**Effect**: All dialog state cleared, returns to chat list

---

## Testing Contract

### Widget Tests

```dart
testWidgets('shows search results when typing', (tester) async {
  // Arrange: Provide mock ChatBloc with search results
  // Act: Enter text in search field
  // Assert: Verify results list displays correctly
});

testWidgets('adds participant when result tapped', (tester) async {
  // Arrange: Mock search results
  // Act: Tap on a search result
  // Assert: Verify ChatParticipantAdded event dispatched
});

testWidgets('validates group requirements before creation', (tester) async {
  // Arrange: Group mode with <2 participants
  // Act: Tap Start Conversation
  // Assert: Error message shown, no event dispatched
});

testWidgets('preserves data on error', (tester) async {
  // Arrange: Error state with participants and message
  // Act: Verify all fields still contain data
  // Assert: Retry button visible
});
```

---

## Compliance with Constitution

✅ **BLoC State Management First**: All state in ChatBloc, no widget-level API calls  
✅ **Strict Data Layer Separation**: ChatService handles API, widget only dispatches events  
✅ **Type Safety**: All models strongly typed with validation  
✅ **Website Feature Parity**: UI matches website's MessagingChat new conversation modal  
✅ **Testable**: Widget easily testable with mock ChatBloc  
✅ **No Mock Data**: All data from real API calls via ChatService
