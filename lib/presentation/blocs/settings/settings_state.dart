import 'package:samva/data/models/setting.dart';

class SettingsState {
  final Settings settings;
  final bool isLoading;
  final String? error;

  const SettingsState({
    required this.settings,
    this.isLoading = false,
    this.error,
  });

  factory SettingsState.initial() {
    return SettingsState(settings: Settings());
  }

  SettingsState copyWith({Settings? settings, bool? isLoading, String? error}) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
