# Quickstart: Instructor Courses Integration

Follow these steps to generate models and test the new integration:

1. **Generate Freezed Models**: Ensure robust JSON parsing and generation.
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
2. **Run the Application**:
   ```bash
   flutter run
   ```
3. **Verify Locally**:
   - Log in with Instructor credentials.
   - Observe the loading state and verify real-time data population in the Top Stats Board.
   - Disable networking on the device/emulator to test the fallback to the cached offline models driven by `HydratedBloc`.
