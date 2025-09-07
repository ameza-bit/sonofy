import 'package:flutter_test/flutter_test.dart';
import 'package:sonofy/core/utils/audio_player_converter.dart';

void main() {
  group('AudioPlayerConverter Tests', () {
    
    test('debería detectar URLs de iPod Library correctamente', () {
      const ipodUrl = 'ipod-library://item/item.m4a?id=123456789';
      const regularUrl = '/storage/emulated/0/Music/song.mp3';
      
      expect(AudioPlayerConverter.isIpodLibraryUrl(ipodUrl), true);
      expect(AudioPlayerConverter.isIpodLibraryUrl(regularUrl), false);
    });

    test('debería detectar archivos de audio locales correctamente', () {
      const mp3File = '/storage/emulated/0/Music/song.mp3';
      const m4aFile = '/Users/user/Music/song.m4a';
      const wavFile = '/path/to/audio.wav';
      const flacFile = '/music/track.flac';
      const oggFile = '/audio/file.ogg';
      const aacFile = '/sounds/audio.aac';
      const textFile = '/documents/file.txt';
      const ipodUrl = 'ipod-library://item/item.m4a?id=123456789';
      
      // Archivos de audio locales válidos
      expect(AudioPlayerConverter.isLocalAudioFile(mp3File), true);
      expect(AudioPlayerConverter.isLocalAudioFile(m4aFile), true);
      expect(AudioPlayerConverter.isLocalAudioFile(wavFile), true);
      expect(AudioPlayerConverter.isLocalAudioFile(flacFile), true);
      expect(AudioPlayerConverter.isLocalAudioFile(oggFile), true);
      expect(AudioPlayerConverter.isLocalAudioFile(aacFile), true);
      
      // Archivos no válidos
      expect(AudioPlayerConverter.isLocalAudioFile(textFile), false);
      expect(AudioPlayerConverter.isLocalAudioFile(ipodUrl), false);
    });

    test('debería manejar extensiones en mayúsculas y minúsculas', () {
      const mp3Upper = '/path/SONG.MP3';
      const m4aLower = '/path/song.m4a';
      const mixedCase = '/path/Track.FlAc';
      
      expect(AudioPlayerConverter.isLocalAudioFile(mp3Upper), true);
      expect(AudioPlayerConverter.isLocalAudioFile(m4aLower), true);
      expect(AudioPlayerConverter.isLocalAudioFile(mixedCase), true);
    });

    test('no debería detectar URLs de iPod Library como archivos locales', () {
      const ipodUrl = 'ipod-library://item/item.m4a?id=123456789';
      
      expect(AudioPlayerConverter.isLocalAudioFile(ipodUrl), false);
    });

    test('debería manejar rutas vacías o inválidas', () {
      const empty = '';
      const noExtension = '/path/file';
      const onlyDot = '/path/file.';
      
      expect(AudioPlayerConverter.isLocalAudioFile(empty), false);
      expect(AudioPlayerConverter.isLocalAudioFile(noExtension), false);
      expect(AudioPlayerConverter.isLocalAudioFile(onlyDot), false);
    });
  });
}