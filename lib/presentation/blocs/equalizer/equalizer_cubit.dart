import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/enums/equalizer_preset.dart';
import 'package:sonofy/data/models/equalizer_model.dart';
import 'package:sonofy/domain/usecases/get_equalizer_settings_usecase.dart';
import 'package:sonofy/domain/usecases/update_equalizer_usecase.dart';
import 'package:sonofy/presentation/blocs/equalizer/equalizer_state.dart';

class EqualizerCubit extends Cubit<EqualizerState> {
  final GetEqualizerSettingsUseCase _getEqualizerSettingsUseCase;
  final UpdateEqualizerUseCase _updateEqualizerUseCase;
  
  // Callback para sincronizar con el reproductor
  Function(bool enabled, List<double> bands, double preamp)? _onEqualizerChanged;

  EqualizerCubit({
    required GetEqualizerSettingsUseCase getEqualizerSettingsUseCase,
    required UpdateEqualizerUseCase updateEqualizerUseCase,
  })  : _getEqualizerSettingsUseCase = getEqualizerSettingsUseCase,
        _updateEqualizerUseCase = updateEqualizerUseCase,
        super(const EqualizerState());

  void setPlayerSync(Function(bool enabled, List<double> bands, double preamp) callback) {
    _onEqualizerChanged = callback;
  }

  Future<void> loadEqualizerSettings() async {
    try {
      emit(state.copyWith(isLoading: true));
      final equalizer = await _getEqualizerSettingsUseCase.call();
      emit(state.copyWith(
        equalizer: equalizer,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'player.equalizer.error_loading',
      ));
    }
  }

  Future<void> setEqualizerEnabled(bool enabled) async {
    try {
      await _updateEqualizerUseCase.setEnabled(enabled);
      final updatedEqualizer = state.equalizer.copyWith(isEnabled: enabled);
      emit(state.copyWith(equalizer: updatedEqualizer));
      
      _onEqualizerChanged?.call(
        updatedEqualizer.isEnabled,
        updatedEqualizer.currentValues,
        updatedEqualizer.preamp,
      );
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'player.equalizer.error_toggle',
      ));
    }
  }

  Future<void> setPreset(EqualizerPreset preset) async {
    try {
      await _updateEqualizerUseCase.setPreset(preset);
      final updatedEqualizer = state.equalizer.copyWith(currentPreset: preset);
      emit(state.copyWith(equalizer: updatedEqualizer));
      
      if (updatedEqualizer.isEnabled) {
        _onEqualizerChanged?.call(
          updatedEqualizer.isEnabled,
          updatedEqualizer.currentValues,
          updatedEqualizer.preamp,
        );
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'player.equalizer.error_preset',
      ));
    }
  }

  Future<void> updateBandValue(int bandIndex, double value) async {
    if (bandIndex < 0 || bandIndex >= 10) return;

    try {
      final newValues = List<double>.from(state.equalizer.customValues);
      newValues[bandIndex] = value;

      await _updateEqualizerUseCase.updateCustomValues(newValues);
      final updatedEqualizer = state.equalizer.copyWith(
        customValues: newValues,
        currentPreset: EqualizerPreset.custom,
      );
      emit(state.copyWith(equalizer: updatedEqualizer));
      
      if (updatedEqualizer.isEnabled) {
        _onEqualizerChanged?.call(
          updatedEqualizer.isEnabled,
          updatedEqualizer.currentValues,
          updatedEqualizer.preamp,
        );
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'player.equalizer.error_band',
      ));
    }
  }

  Future<void> updateAllBands(List<double> values) async {
    if (values.length != 10) return;

    try {
      await _updateEqualizerUseCase.updateCustomValues(values);
      final updatedEqualizer = state.equalizer.copyWith(
        customValues: values,
        currentPreset: EqualizerPreset.custom,
      );
      emit(state.copyWith(equalizer: updatedEqualizer));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'player.equalizer.error_band',
      ));
    }
  }

  Future<void> setPreamp(double preamp) async {
    try {
      await _updateEqualizerUseCase.setPreamp(preamp);
      final updatedEqualizer = state.equalizer.copyWith(preamp: preamp);
      emit(state.copyWith(equalizer: updatedEqualizer));
      
      if (updatedEqualizer.isEnabled) {
        _onEqualizerChanged?.call(
          updatedEqualizer.isEnabled,
          updatedEqualizer.currentValues,
          updatedEqualizer.preamp,
        );
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'player.equalizer.error_preamp',
      ));
    }
  }

  Future<void> resetToDefault() async {
    try {
      await _updateEqualizerUseCase.resetToDefault();
      const defaultEqualizer = EqualizerModel();
      emit(state.copyWith(equalizer: defaultEqualizer));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'player.equalizer.error_reset',
      ));
    }
  }

  void clearError() {
    emit(state.copyWith());
  }
}