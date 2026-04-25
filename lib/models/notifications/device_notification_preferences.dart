class DeviceNotificationPreferences {
  final bool foregroundAlertsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showPreview;

  const DeviceNotificationPreferences({
    this.foregroundAlertsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showPreview = true,
  });

  DeviceNotificationPreferences copyWith({
    bool? foregroundAlertsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showPreview,
  }) {
    return DeviceNotificationPreferences(
      foregroundAlertsEnabled:
          foregroundAlertsEnabled ?? this.foregroundAlertsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showPreview: showPreview ?? this.showPreview,
    );
  }
}
