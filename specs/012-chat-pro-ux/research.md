
# Phase 0: Research & Architecture Decisions

All initial unknowns have been resolved via the `/speckit.clarify` phase. 

## Decisions

1. **Initial Contacts List**
   - **Decision**: Hide "All Contacts" initially. Show only "Frequently Contacted" until the user searches.
   - **Rationale**: The backend `/api/messages/users/search` endpoint is paginated (`limit=20`). Fetching all users globally is unscalable. 

2. **Common Groups**
   - **Decision**: Client-side filtering of already loaded conversations.
   - **Rationale**: Avoids creating new backend REST endpoints and ensures data is fully synchronized with the user`'`s live BLoC state.

3. **Offline User Initialization**
   - **Decision**: Fallback to displaying "Offline" without a timestamp.
   - **Rationale**: The WebSocket `online_users_list` only returns currently online users. Last-seen timestamps are accumulated live via `user_status` events or fetched later.

4. **Reply To Identity Recovery**
   - **Decision**: Fallback to "Unknown User".
   - **Rationale**: If the local `ParticipantCache` fails to hydrate the ID, doing a synchronous network request per reply snippet is too expensive and complex. An explicit "Unknown User" fallback is safe.

5. **Reply Deep-Linking**
   - **Decision**: Scroll to Original Message.
   - **Rationale**: Matches WhatsApp/Telegram standard behavior where tapping a replied snippet scrolls the viewport to the target message.
