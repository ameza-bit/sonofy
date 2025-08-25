import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/enums/language.dart';
import 'package:sonofy/core/enums/order_by.dart';
import 'package:sonofy/data/models/equalizer_settings.dart';
import 'package:sonofy/data/models/setting.dart';
import 'package:sonofy/domain/repositories/settings_repository.dart';
import 'package:sonofy/domain/usecases/select_music_folder_usecase.dart';
import 'package:sonofy/domain/usecases/get_songs_from_folder_usecase.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  final SelectMusicFolderUseCase? _selectMusicFolderUseCase;
  final GetSongsFromFolderUseCase? _getSongsFromFolderUseCase;

  SettingsCubit(
    this._settingsRepository,
    this._selectMusicFolderUseCase,
    this._getSongsFromFolderUseCase,
  ) : super(SettingsState.initial()) {
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

  void updateOrderBy(OrderBy orderBy) {
    _updateSetting(state.settings.copyWith(orderBy: orderBy));
  }

  void updatePlaybackSpeed(double playbackSpeed) {
    _updateSetting(state.settings.copyWith(playbackSpeed: playbackSpeed));
  }

  void updateEqualizerSettings(EqualizerSettings equalizerSettings) {
    _updateSetting(state.settings.copyWith(equalizerSettings: equalizerSettings));
  }

  void updateSettings(Settings settings) {
    _updateSetting(settings);
  }

  Future<bool> selectAndSetMusicFolder() async {
    // Solo iOS soporta selección de carpetas
    if (_selectMusicFolderUseCase == null ||
        _getSongsFromFolderUseCase == null) {
      return false;
    }

    emit(state.copyWith(isLoading: true));
    try {
      final String? selectedPath = await _selectMusicFolderUseCase();
      if (selectedPath != null) {
        final List<File> mp3Files = await _getSongsFromFolderUseCase(
          selectedPath,
        );
        final newSettings = state.settings.copyWith(
          localMusicPath: selectedPath,
        );
        _updateSetting(newSettings);
        emit(state.copyWith(isLoading: false));
        return mp3Files.isNotEmpty;
      } else {
        emit(state.copyWith(isLoading: false));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
      return false;
    }
  }

  Future<List<File>> getMp3FilesFromCurrentFolder() async {
    // Solo iOS soporta obtención de archivos de carpetas
    if (_getSongsFromFolderUseCase == null) {
      return [];
    }

    final currentPath = state.settings.localMusicPath;
    if (currentPath == null || currentPath.isEmpty) {
      return [];
    }

    try {
      return await _getSongsFromFolderUseCase(currentPath);
    } catch (e) {
      return [];
    }
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
