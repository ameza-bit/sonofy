import 'dart:ui';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samva/core/enums/language.dart';
import 'package:samva/data/models/setting.dart';
import 'package:samva/domain/repositories/settings_repository.dart';
import 'package:samva/presentation/blocs/settings/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsCubit(this._settingsRepository) : super(SettingsState.initial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    emit(state.copyWith(isLoading: true));
    try {
      final settings = _settingsRepository.getSettings();
      emit(state.copyWith(settings: settings, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void updateIsDarkMode(ThemeMode isDarkMode) {
    _updateSetting(state.settings.copyWith(themeMode: isDarkMode));
  }

  void updatePrimaryColor(Color primaryColor) {
    _updateSetting(state.settings.copyWith(primaryColor: primaryColor));
  }

  void updateFontSize(double fontSize) {
    _updateSetting(state.settings.copyWith(fontSize: fontSize));
  }

  void updateLanguage(Language language) {
    _updateSetting(state.settings.copyWith(language: language));
  }

  void updateBiometricEnabled(bool biometricEnabled) {
    _updateSetting(state.settings.copyWith(biometricEnabled: biometricEnabled));
  }

  void updateSettings(Settings settings) {
    _updateSetting(settings);
  }

  void _updateSetting(Settings newSetting) {
    try {
      _settingsRepository.saveSettings(newSetting);
      emit(state.copyWith(settings: newSetting));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
