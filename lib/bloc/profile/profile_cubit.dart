import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/api/user_profile_service.dart';
import 'profile_models.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserProfileService _userProfileService;

  ProfileCubit({required UserProfileService userProfileService})
    : _userProfileService = userProfileService,
      super(const ProfileInitial());

  Future<void> loadProfile({bool force = false}) async {
    if (!force && state is ProfileLoading) {
      return;
    }

    final previousState = state;
    if (previousState is! ProfileLoaded) {
      emit(const ProfileLoading());
    } else {
      emit(previousState.copyWith(isSaving: true, clearError: true));
    }

    try {
      final profile = await _userProfileService.getProfile();
      final preferences = await _userProfileService.getPreferences();
      final settings = _mergePreferencesIntoSettings(
        previousState is ProfileLoaded
            ? previousState.settings
            : const AppSettings(),
        preferences,
      );
      final devices = previousState is ProfileLoaded
          ? previousState.connectedDevices
          : _generateSampleDevices();

      emit(
        ProfileLoaded(
          profile: profile,
          settings: settings,
          connectedDevices: devices,
        ),
      );
    } catch (e) {
      if (previousState is ProfileLoaded) {
        emit(
          previousState.copyWith(
            isSaving: false,
            error: 'Failed to load profile: ${_formatError(e)}',
          ),
        );
      } else {
        emit(ProfileError(message: _formatError(e)));
      }
    }
  }

  void startEditing() {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(isEditing: true));
  }

  void cancelEditing() {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(isEditing: false));
  }

  Future<bool> updateProfile(UpdateUserProfileRequest request) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return false;

    emit(currentState.copyWith(isSaving: true, clearError: true));
    HapticFeedback.mediumImpact();

    try {
      final updatedProfile = await _userProfileService.updateProfile(request);
      emit(
        currentState.copyWith(
          profile: updatedProfile,
          isEditing: false,
          isSaving: false,
          clearError: true,
        ),
      );
      return true;
    } catch (e) {
      emit(
        currentState.copyWith(
          isSaving: false,
          error: 'Failed to update profile: ${_formatError(e)}',
        ),
      );
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return false;

    emit(currentState.copyWith(isSaving: true, clearError: true));

    try {
      await _userProfileService.changePassword(
        ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );
      emit(currentState.copyWith(isSaving: false, clearError: true));
      return true;
    } catch (e) {
      emit(
        currentState.copyWith(
          isSaving: false,
          error: 'Failed to change password: ${_formatError(e)}',
        ),
      );
      return false;
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    HapticFeedback.selectionClick();
    await _persistPreferences(currentState, newSettings);
  }

  Future<void> togglePushNotifications(bool value) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    await _persistPreferences(
      currentState,
      currentState.settings.copyWith(pushNotifications: value),
    );
  }

  Future<void> toggleEmailAlerts(bool value) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    await _persistPreferences(
      currentState,
      currentState.settings.copyWith(emailAlerts: value),
    );
  }

  void toggleAiSuggestions(bool value) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(
      currentState.copyWith(
        settings: currentState.settings.copyWith(aiSuggestions: value),
      ),
    );
  }

  void toggleAutoDarkMode(bool value) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(
      currentState.copyWith(
        settings: currentState.settings.copyWith(autoDarkMode: value),
      ),
    );
  }

  void toggleWeeklyPerformanceSummary(bool value) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(
      currentState.copyWith(
        settings: currentState.settings.copyWith(
          weeklyPerformanceSummary: value,
        ),
      ),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    await _persistPreferences(
      currentState,
      currentState.settings.copyWith(themeMode: mode),
    );
  }

  void setAccentColor(AccentColor color) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    HapticFeedback.selectionClick();
    emit(
      currentState.copyWith(
        settings: currentState.settings.copyWith(accentColor: color),
      ),
    );
  }

  void toggleTwoFactorAuth(bool value) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(
      currentState.copyWith(
        settings: currentState.settings.copyWith(twoFactorAuth: value),
      ),
    );
  }

  Future<void> setLanguage(String languageCode) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    await _persistPreferences(
      currentState,
      currentState.settings.copyWith(languageCode: languageCode),
    );
  }

  Future<void> removeDevice(String deviceId) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    HapticFeedback.mediumImpact();

    final updatedDevices = currentState.connectedDevices
        .where((device) => device.id != deviceId)
        .toList();

    emit(currentState.copyWith(connectedDevices: updatedDevices));
  }

  Future<void> exportData() async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(isSaving: true, clearError: true));

    await Future<void>.delayed(const Duration(milliseconds: 600));

    emit(currentState.copyWith(isSaving: false, clearError: true));
  }

  void clearError() {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(clearError: true));
  }

  String _formatError(Object error) {
    final raw = error.toString().replaceAll('Exception: ', '').trim();
    return raw.isEmpty ? 'Unknown error' : raw;
  }

  Future<void> _persistPreferences(
    ProfileLoaded currentState,
    AppSettings nextSettings,
  ) async {
    emit(
      currentState.copyWith(
        settings: nextSettings,
        isSaving: true,
        clearError: true,
      ),
    );

    try {
      final savedPreferences = await _userProfileService.updatePreferences(
        _preferencesFromSettings(nextSettings),
      );

      emit(
        currentState.copyWith(
          settings: _mergePreferencesIntoSettings(
            nextSettings,
            savedPreferences,
          ),
          isSaving: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isSaving: false,
          error: 'Failed to update preferences: ${_formatError(e)}',
        ),
      );
    }
  }

  AppSettings _mergePreferencesIntoSettings(
    AppSettings baseSettings,
    UserPreferences preferences,
  ) {
    return baseSettings.copyWith(
      pushNotifications: preferences.pushNotifications,
      emailAlerts: preferences.emailNotifications,
      themeMode: preferences.theme.toLowerCase() == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light,
      languageCode: preferences.language,
    );
  }

  UpdateUserPreferencesRequest _preferencesFromSettings(AppSettings settings) {
    return UpdateUserPreferencesRequest(
      language: settings.languageCode,
      theme: settings.themeMode == ThemeMode.dark ? 'dark' : 'light',
      emailNotifications: settings.emailAlerts,
      pushNotifications: settings.pushNotifications,
    );
  }

  List<ConnectedDevice> _generateSampleDevices() {
    return <ConnectedDevice>[
      ConnectedDevice(
        id: 'device_1',
        name: 'Current Device',
        type: 'Laptop',
        location: 'Current Session',
        lastActive: DateTime.now(),
        isCurrentDevice: true,
      ),
      ConnectedDevice(
        id: 'device_2',
        name: 'Mobile App',
        type: 'Phone',
        location: 'Recent Session',
        lastActive: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }
}
