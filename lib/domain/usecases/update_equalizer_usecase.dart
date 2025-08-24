import 'package:sonofy/core/enums/equalizer_preset.dart';
import 'package:sonofy/domain/repositories/equalizer_repository.dart';

class UpdateEqualizerUseCase {
  final EqualizerRepository _repository;

  UpdateEqualizerUseCase(this._repository);

  Future<void> setEnabled(bool enabled) async {
    return _repository.setEqualizerEnabled(enabled);
  }

  Future<void> setPreset(EqualizerPreset preset) async {
    return _repository.setPreset(preset);
  }

  Future<void> updateCustomValues(List<double> values) async {
    return _repository.updateCustomValues(values);
  }

  Future<void> setPreamp(double preamp) async {
    return _repository.setPreamp(preamp);
  }

  Future<void> resetToDefault() async {
    return _repository.resetToDefault();
  }
}