import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/enums/equalizer_preset.dart';
import 'package:sonofy/domain/repositories/equalizer_repository.dart';
import 'package:sonofy/presentation/blocs/equalizer/equalizer_state.dart';

class EqualizerCubit extends Cubit<EqualizerState> {
  final EqualizerRepository _equalizerRepository;

  EqualizerCubit(this._equalizerRepository) : super(EqualizerState.initial()) {
    _loadSettings();
  }

  void _loadSettings() {
    try {
      emit(state.copyWith(isLoading: true));
      final settings = _equalizerRepository.getEqualizerSettings();
      emit(state.copyWith(settings: settings, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setBandGain(int bandIndex, double gain) async {
    try {
      emit(state.copyWith(isLoading: true));

      final success = await _equalizerRepository.setBand(bandIndex, gain);
      if (success) {
        final newSettings = state.settings.updateBand(bandIndex, gain);
        emit(state.copyWith(settings: newSettings, isLoading: false));
      } else {
        emit(
          state.copyWith(isLoading: false, error: 'Failed to update band gain'),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setPreset(EqualizerPreset preset) async {
    try {
      emit(state.copyWith(isLoading: true));

      final success = await _equalizerRepository.setPreset(preset);
      if (success) {
        final newSettings = state.settings.applyPreset(preset);
        emit(state.copyWith(settings: newSettings, isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to apply preset'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      emit(state.copyWith(isLoading: true));

      final success = await _equalizerRepository.setEnabled(enabled);
      if (success) {
        final newSettings = state.settings.copyWith(isEnabled: enabled);
        emit(state.copyWith(settings: newSettings, isLoading: false));
      } else {
        emit(
          state.copyWith(isLoading: false, error: 'Failed to toggle equalizer'),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> resetToFlat() async {
    await setPreset(EqualizerPreset.normal);
  }

  Future<void> refreshSettings() async {
    _loadSettings();
  }

  void clearError() {
    emit(state.copyWith());
  }
}
