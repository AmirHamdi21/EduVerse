# Quickstart: Phase 1 Core Chat Infrastructure

To initialize the new core chat services in the Flutter app:

1. **Install Dependencies**
   Update `pubspec.yaml` to include `socket_io_client: ^3.0.2` and run `flutter pub get`.

2. **Initialize Services**
   During your app bootstrap (or inside main dependency injection), initialize `ChatSocketService`:

   ```dart
   final String myJwtToken = await tokenStorage.getToken();
   
   final chatSocketService = ChatSocketService();
   chatSocketService.connect(myJwtToken);
   ```

3. **REST Service usage example**:

   ```dart
   final chatService = ChatService(dio);
   final searchResults = await chatService.searchUsers('John');
   ```
