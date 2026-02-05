import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_models.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final profile = _generateSampleProfile();
      final settings = const AppSettings();
      final devices = _generateSampleDevices();

      emit(ProfileLoaded(
        profile: profile,
        settings: settings,
        connectedDevices: devices,
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
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

  Future<void> updateProfile(UserProfile updatedProfile) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(isSaving: true));
    HapticFeedback.mediumImpact();

    try {
      await Future.delayed(const Duration(seconds: 1));

      emit(currentState.copyWith(
        profile: updatedProfile.copyWith(updatedAt: DateTime.now()),
        isEditing: false,
        isSaving: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSaving: false,
        error: 'Failed to update profile: ${e.toString()}',
      ));
    }
  }

  void updateSettings(AppSettings newSettings) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    HapticFeedback.selectionClick();
    emit(currentState.copyWith(settings: newSettings));
  }

  void togglePushNotifications(bool value) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(
      settings: currentState.settings.copyWith(pushNotifications: value),
    ));
  }

  void toggleEmailAlerts(bool value) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(
      settings: currentState.settings.copyWith(emailAlerts: value),
    ));
  }

  void toggleAiSuggestions(bool value) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(
      settings: currentState.settings.copyWith(aiSuggestions: value),
    ));
  }

  void toggleAutoDarkMode(bool value) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(
      settings: currentState.settings.copyWith(autoDarkMode: value),
    ));
  }

  void toggleWeeklyPerformanceSummary(bool value) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(
      settings: currentState.settings.copyWith(weeklyPerformanceSummary: value),
    ));
  }

  void setThemeMode(ThemeMode mode) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(
      settings: currentState.settings.copyWith(themeMode: mode),
    ));
  }

  void setAccentColor(AccentColor color) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    HapticFeedback.selectionClick();
    emit(currentState.copyWith(
      settings: currentState.settings.copyWith(accentColor: color),
    ));
  }

  void toggleTwoFactorAuth(bool value) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(
      settings: currentState.settings.copyWith(twoFactorAuth: value),
    ));
  }

  void setLanguage(String languageCode) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(
      settings: currentState.settings.copyWith(languageCode: languageCode),
    ));
  }

  Future<void> removeDevice(String deviceId) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    HapticFeedback.mediumImpact();

    final updatedDevices = currentState.connectedDevices
        .where((d) => d.id != deviceId)
        .toList();

    emit(currentState.copyWith(connectedDevices: updatedDevices));
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(isSaving: true));

    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(currentState.copyWith(isSaving: false));
    } catch (e) {
      emit(currentState.copyWith(
        isSaving: false,
        error: 'Failed to change password: ${e.toString()}',
      ));
    }
  }

  Future<void> exportData() async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(isSaving: true));

    try {
      await Future.delayed(const Duration(seconds: 2));
      emit(currentState.copyWith(isSaving: false));
    } catch (e) {
      emit(currentState.copyWith(
        isSaving: false,
        error: 'Failed to export data: ${e.toString()}',
      ));
    }
  }

  void clearError() {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(clearError: true));
  }

  UserProfile _generateSampleProfile() {
    return UserProfile(
      id: 'user_001',
      firstName: 'Alex',
      lastName: 'Doe',
      email: 'alex.doe@university.edu',
      phoneNumber: '+1 234 567 890',
      avatarUrl: null,
      coverUrl: null,
      role: 'Undergraduate - Computer Engineering',
      studentId: 'ID: 12345678',
      university: 'MIT',
      major: 'Computer Engineering',
      minor: 'Mathematics',
      level: 'Undergraduate',
      year: '3rd Year',
      expectedGraduation: '2026',
      dateOfBirth: DateTime(2002, 5, 15),
      location: 'New York, USA',
      bio: 'Passionate about AI and machine learning. Love building innovative solutions.',
      gpa: 3.8,
      rank: 125,
      coursesEnrolled: 12,
      assignmentsCompleted: 48,
      socialLinks: const SocialLinks(
        personalWebsite: 'https://alexdoe.dev',
        github: 'github.com/alexdoe',
        linkedin: 'linkedin.com/in/alex-doe',
        twitter: '@alexdoe',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );
  }

  List<ConnectedDevice> _generateSampleDevices() {
    return [
      ConnectedDevice(
        id: 'device_1',
        name: 'MacBook Pro - Current',
        type: 'Laptop',
        location: 'New York, USA',
        lastActive: DateTime.now(),
        isCurrentDevice: true,
      ),
      ConnectedDevice(
        id: 'device_2',
        name: 'iPhone 12',
        type: 'iPhone',
        location: 'New York, USA',
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ConnectedDevice(
        id: 'device_3',
        name: 'iPad Air',
        type: 'iPad',
        location: 'New York, USA',
        lastActive: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
