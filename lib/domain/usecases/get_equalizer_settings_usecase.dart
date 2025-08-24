import 'package:sonofy/data/models/equalizer_model.dart';
import 'package:sonofy/domain/repositories/equalizer_repository.dart';

class GetEqualizerSettingsUseCase {
  final EqualizerRepository _repository;

  GetEqualizerSettingsUseCase(this._repository);

  Future<EqualizerModel> call() async {
    return _repository.getEqualizerSettings();
  }
}