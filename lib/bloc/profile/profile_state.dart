import 'profile_models.dart';

/// Base state for Profile
abstract class ProfileState {
  const ProfileState();
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Loaded state with data
class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final AppSettings settings;
  final List<ConnectedDevice> connectedDevices;
  final bool isEditing;
  final bool isSaving;
  final String? error;

  const ProfileLoaded({
    required this.profile,
    required this.settings,
    this.connectedDevices = const [],
    this.isEditing = false,
    this.isSaving = false,
    this.error,
  });

  ProfileLoaded copyWith({
    UserProfile? profile,
    AppSettings? settings,
    List<ConnectedDevice>? connectedDevices,
    bool? isEditing,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
      connectedDevices: connectedDevices ?? this.connectedDevices,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Error state
class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});
}
