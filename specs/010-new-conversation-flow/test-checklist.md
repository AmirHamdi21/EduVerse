# New Conversation Flow - Manual Test Checklist

This checklist covers all manual tests for Phases 3, 4, and 5 of the New Conversation Flow feature.

**Prerequisites:**
- App is running on device/emulator
- User is logged in
- Navigate to Chat screen (accessible via bottom navigation)

---

## Phase 3: User Story 1 - Direct Conversations (T048-T055)

### T048: Search by Email
- [ ] Open new conversation dialog (tap FAB +)
- [ ] Type a valid email address in search field
- [ ] **Expected:** Matching user appears in results within 2 seconds
- [ ] **Pass/Fail:** Pass

### T049: Search by Name  
- [ ] Type partial name (e.g., "John")
- [ ] **Expected:** Users with matching names appear, ordered by relevance
- [ ] **Pass/Fail:** Pass

### T050: Selecting User
- [ ] Tap on a search result
- [ ] **Expected:** 
  - Chip with user name appears above search field
  - Search field clears automatically
- [ ] **Pass/Fail:** Fail

### T051: Removing Participant
- [ ] Tap X on the user chip
- [ ] **Expected:** Chip disappears, participant removed from selection
- [ ] **Pass/Fail:** Pass

### T052: Creating Direct Conversation (WITHOUT message)
- [ ] Select 1 user (chip appears)
- [ ] Leave message field empty
- [ ] Click "Start Conversation"
- [ ] **Expected:**
  - Dialog closes
  - New conversation appears in list with user's name (NOT "Conversation {id}")
  - Shows "No messages yet" (this is expected since no message was sent)
- [ ] **Pass/Fail:** Fail (it shows text must be string and dont close the dialog and didnt create the chat group)

### T052b: Creating Direct Conversation (WITH message)
- [ ] Open dialog, select 1 user
- [ ] Enter message: "Hello!"
- [ ] Click "Start Conversation"
- [ ] **Expected:**
  - Dialog closes
  - New conversation appears with user's name
  - Conversation shows the sent message
- [ ] **Pass/Fail:** Pass (but the message appear when making manual refresh)

### T053: Network Error Handling
- [ ] Disable network/put device in airplane mode
- [ ] Try to search for users
- [ ] **Expected:** Error message appears with "Retry" button
- [ ] Re-enable network and click Retry
- [ ] **Expected:** Search proceeds normally
- [ ] **Pass/Fail:** Pass (it makes search in the offline and doesnt show the retry button i think because the backend is running locally / for the creating new chat the retry button appear)

### T054: Existing Conversation Routing
- [ ] Note a user you already have a direct conversation with
- [ ] Open new conversation dialog
- [ ] Select that same user
- [ ] Click "Start Conversation"
- [ ] **Expected:** Navigates to the existing conversation (doesn't create duplicate)
- [ ] **Pass/Fail:** Pass

### T055: Self-Messaging
- [ ] Search for your own email
- [ ] Select yourself
- [ ] Click "Start Conversation"
- [ ] **Expected:** Conversation with yourself appears in list
- [ ] **Pass/Fail:** Fail (doesnt appear)

---

## Phase 4: User Story 2 - Group Conversations (T066-T072)

### T066: Mode Toggle
- [ ] Open new conversation dialog
- [ ] Click "Group" button in toggle
- [ ] **Expected:** 
  - Group name field appears
  - Mode switches to group
- [ ] **Pass/Fail:** Pass

### T067: Multi-Select in Group Mode
- [ ] Switch to Group mode
- [ ] Search and select 2+ users
- [ ] **Expected:** 
  - All selected users appear as chips
  - Can continue adding more users
- [ ] **Pass/Fail:** Pass

### T068: Group Name Validation
- [ ] Select 2+ users in Group mode
- [ ] Leave group name empty
- [ ] Click "Start Conversation"
- [ ] **Expected:** Error message "Group name is required"
- [ ] **Pass/Fail:** Pass

### T069: Minimum Participants Validation
- [ ] Switch to Group mode
- [ ] Select only 1 user
- [ ] Enter a group name
- [ ] Click "Start Conversation"
- [ ] **Expected:** Error message "Groups require at least 3 participants (including you)"
- [ ] **Pass/Fail:** Pass

### T070: Creating Group Conversation
- [ ] Select 2+ users
- [ ] Enter group name: "Test Group"
- [ ] Optionally enter message
- [ ] Click "Start Conversation"
- [ ] **Expected:**
  - Dialog closes
  - New group appears in list with the name "Test Group"
- [ ] **Pass/Fail:** Fail (it shows text must be string and dont close the dialog and didnt create the chat group)

### T071: Group in Conversation List
- [ ] View the created group in conversation list
- [ ] **Expected:**
  - Displays with group name (not participant names)
  - Shows participant count or avatars
- [ ] **Pass/Fail:** Pass

### T072: Switching Modes
- [ ] Select a user in Direct mode
- [ ] Switch to Group mode
- [ ] **Expected:** Selection is preserved
- [ ] Switch back to Direct mode
- [ ] **Expected:** Selection is still there
- [ ] **Pass/Fail:** Pass

---

## Phase 5: User Story 3 - Enhanced Search (T077-T084)

### T077: Search Debouncing
- [ ] Type rapidly in search field (e.g., "j", "jo", "joh", "john")
- [ ] **Expected:** Only one API call happens ~400ms after you stop typing
- [ ] **Pass/Fail:** Pass

### T078: Relevance Ordering
- [ ] Search for a term that matches multiple users differently
- [ ] **Expected:** Exact email matches first, then partial matches, then name matches
- [ ] **Pass/Fail:** Pass

### T079: Partial Email Search
- [ ] Search "@example.com" or similar domain
- [ ] **Expected:** All users with that domain appear
- [ ] **Pass/Fail:** Pass (but it also should the groups that has participant with the same @example.com searched)

### T080: Partial Name Search
- [ ] Search for a last name like "doe" or "smith"
- [ ] **Expected:** Users with that name in first OR last name appear
- [ ] **Pass/Fail:** Pass

### T081: Empty State
- [ ] Search "xyznonexistent12345"
- [ ] **Expected:** "No users found" message with icon displays
- [ ] **Pass/Fail:** Pass

### T082: Result Display
- [ ] View search results
- [ ] **Expected:** Each shows:
  - Full name prominently
  - Email below in lighter/smaller text
  - Avatar with initials
- [ ] **Pass/Fail:** Fail (i didint found a search result)

### T083: Search Field Clearing
- [ ] Select a user from results
- [ ] **Expected:** Search field clears
- [ ] Search for another user
- [ ] **Expected:** Can add another participant
- [ ] **Pass/Fail:** Fail (i didint found a search result)

### T084: Special Characters
- [ ] Search for email with dots: "john.doe@example.com"
- [ ] Search with hyphen: "mary-jane"
- [ ] **Expected:** Search works correctly, results appear
- [ ] **Pass/Fail:** Pass

---

## Additional Issue Tests

### A1: Direct Chat After Group Creation
- [ ] Create a group with participants A and B
- [ ] Open new conversation dialog
- [ ] Select participant A only (direct mode)
- [ ] Click "Start Conversation"
- [ ] **Expected:** Direct conversation with A appears in list (separate from group)
- [ ] **Pass/Fail:** Pass

---

## Summary

| Phase | Total Tests | Passed | Failed | Notes |
|-------|-------------|--------|--------|-------|
| Phase 3 (T048-T055) | 9 | | | |
| Phase 4 (T066-T072) | 7 | | | |
| Phase 5 (T077-T084) | 8 | | | |
| Additional | 1 | | | |
| **TOTAL** | **25** | | | |

**Tester:** ________________
**Date:** ________________
**App Version:** ________________
**Device/Emulator:** ________________
