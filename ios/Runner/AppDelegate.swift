import Flutter
import UIKit
import MediaPlayer
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var musicPlayer: MPMusicPlayerController?
  private var audioEngine: AVAudioEngine?
  private var equalizerNode: AVAudioUnitEQ?
  
  // AVAudioPlayer para reproducción nativa de archivos MP3 locales
  private var audioPlayer: AVAudioPlayer?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup method channel in a different way
    if let controller = window?.rootViewController as? FlutterViewController {
      setupMethodChannel(controller: controller)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private var logChannel: FlutterMethodChannel?
  
  private func setupMethodChannel(controller: FlutterViewController) {
    let channel = FlutterMethodChannel(name: "ipod_library_converter", binaryMessenger: controller.binaryMessenger)
    self.logChannel = channel
    
    self.logToFlutter("📱 Method channel setup complete")
    
    channel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      self?.logToFlutter("📱 Received call: \(call.method)")
      
      switch call.method {
      case "checkDrmProtection":
        self?.checkDrmProtection(call: call, result: result)
      case "playWithMusicPlayer":
        self?.playWithMusicPlayer(call: call, result: result)
      case "pauseMusicPlayer":
        self?.pauseMusicPlayer(result: result)
      case "stopMusicPlayer":
        self?.stopMusicPlayer(result: result)
      case "getMusicPlayerStatus":
        self?.getMusicPlayerStatus(result: result)
      case "resumeMusicPlayer":
        self?.resumeMusicPlayer(result: result)
      case "getCurrentPosition":
        self?.getCurrentPosition(result: result)
      case "getDuration":
        self?.getDuration(result: result)
      case "seekToPosition":
        self?.seekToPosition(call: call, result: result)
      case "setPlaybackSpeed":
        self?.setPlaybackSpeed(call: call, result: result)
      case "setEqualizerBand":
        self?.setEqualizerBand(call: call, result: result)
      case "setEqualizerEnabled":
        self?.setEqualizerEnabled(call: call, result: result)
      // Métodos para reproducción nativa de MP3
      case "playMP3WithNativePlayer":
        self?.playMP3WithNativePlayer(call: call, result: result)
      case "getMP3Duration":
        self?.getMP3Duration(call: call, result: result)
      case "pauseNativeMP3Player":
        self?.pauseNativeMP3Player(result: result)
      case "stopNativeMP3Player":
        self?.stopNativeMP3Player(result: result)
      case "resumeNativeMP3Player":
        self?.resumeNativeMP3Player(result: result)
      case "getNativeMP3PlayerStatus":
        self?.getNativeMP3PlayerStatus(result: result)
      case "getCurrentMP3Position":
        self?.getCurrentMP3Position(result: result)
      case "seekToMP3Position":
        self?.seekToMP3Position(call: call, result: result)
      case "setMP3PlaybackSpeed":
        self?.setMP3PlaybackSpeed(call: call, result: result)
      case "updateNowPlayingInfo":
        self?.updateNowPlayingInfoFromFlutter(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    })
  }
  
  private func logToFlutter(_ message: String) {
    DispatchQueue.main.async {
      self.logChannel?.invokeMethod("logFromIOS", arguments: message)
    }
  }
  
  private func checkDrmProtection(call: FlutterMethodCall, result: @escaping FlutterResult) {
    logToFlutter("🔒 Starting DRM check")
    guard let args = call.arguments as? [String: Any],
          let songIdString = args["songId"] as? String,
          let songId = UInt64(songIdString) else {
      logToFlutter("❌ Invalid DRM check arguments")
      result(true)
      return
    }
    
    logToFlutter("🔍 Searching for song ID: \(songId)")
    
    let query = MPMediaQuery.songs()
    let predicate = MPMediaPropertyPredicate(value: NSNumber(value: songId), forProperty: MPMediaItemPropertyPersistentID)
    query.addFilterPredicate(predicate)
    
    guard let mediaItems = query.items, let mediaItem = mediaItems.first else {
      logToFlutter("❌ No media item found for DRM check")
      result(true)
      return
    }
    
    let isProtected = mediaItem.value(forProperty: MPMediaItemPropertyHasProtectedAsset) as? Bool ?? false
    let hasAssetUrl = mediaItem.assetURL != nil
    
    logToFlutter("🔒 \(mediaItem.title ?? "Unknown") - Protected: \(isProtected), Has URL: \(hasAssetUrl)")
    result(isProtected || !hasAssetUrl)
  }
  
  private func playWithMusicPlayer(call: FlutterMethodCall, result: @escaping FlutterResult) {
    logToFlutter("🎵 Starting MPMusicPlayerController playback")
    
    guard let args = call.arguments as? [String: Any],
          let songIdString = args["songId"] as? String,
          let songId = UInt64(songIdString) else {
      logToFlutter("❌ Invalid arguments for music player")
      result(false)
      return
    }
    
    logToFlutter("🔍 Setting up music player for song ID: \(songId)")
    
    // Initialize music player if needed
    if musicPlayer == nil {
      musicPlayer = MPMusicPlayerController.applicationMusicPlayer
      logToFlutter("🎵 Created new MPMusicPlayerController")
    }
    
    guard let player = musicPlayer else {
      logToFlutter("❌ Failed to create music player")
      result(false)
      return
    }
    
    // Create query for the specific song
    let query = MPMediaQuery.songs()
    let predicate = MPMediaPropertyPredicate(value: NSNumber(value: songId), forProperty: MPMediaItemPropertyPersistentID)
    query.addFilterPredicate(predicate)
    
    guard let mediaItems = query.items, !mediaItems.isEmpty else {
      logToFlutter("❌ No media items found for music player")
      result(false)
      return
    }
    
    let collection = MPMediaItemCollection(items: mediaItems)
    logToFlutter("✅ Found \(mediaItems.count) item(s), setting queue...")
    
    // Set the queue and play
    player.setQueue(with: collection)
    player.play()
    
    // Configurar los controles del Command Center para MPMusicPlayerController
    setupMPMusicPlayerCommandCenter()
    
    logToFlutter("🎵 Music player started!")
    result(true)
  }
  
  private func pauseMusicPlayer(result: @escaping FlutterResult) {
    logToFlutter("⏸️ Pausing music player")
    guard let player = musicPlayer else {
      logToFlutter("❌ No music player available")
      result(false)
      return
    }
    
    player.pause()
    logToFlutter("✅ Music player paused")
    result(true)
  }
  
  private func stopMusicPlayer(result: @escaping FlutterResult) {
    logToFlutter("⏹️ Stopping music player")
    guard let player = musicPlayer else {
      logToFlutter("❌ No music player available")
      result(false)
      return
    }
    
    player.stop()
    logToFlutter("✅ Music player stopped")
    result(true)
  }
  
  private func getMusicPlayerStatus(result: @escaping FlutterResult) {
    guard let player = musicPlayer else {
      result("stopped")
      return
    }
    
    let status: String
    switch player.playbackState {
    case .playing:
      status = "playing"
    case .paused:
      status = "paused"
    case .stopped:
      status = "stopped"
    case .interrupted:
      status = "interrupted"
    case .seekingForward, .seekingBackward:
      status = "seeking"
    @unknown default:
      status = "unknown"
    }
    
    logToFlutter("📊 Music player status: \(status)")
    result(status)
  }
  
  private func resumeMusicPlayer(result: @escaping FlutterResult) {
    logToFlutter("▶️ Resuming music player")
    guard let player = musicPlayer else {
      logToFlutter("❌ No music player available")
      result(false)
      return
    }
    
    player.play()
    logToFlutter("✅ Music player resumed")
    result(true)
  }
  
  private func getCurrentPosition(result: @escaping FlutterResult) {
    guard let player = musicPlayer else {
      result(0.0)
      return
    }
    
    let currentTime = player.currentPlaybackTime
    logToFlutter("⏱️ Current position: \(currentTime) seconds")
    result(currentTime)
  }
  
  private func getDuration(result: @escaping FlutterResult) {
    guard let player = musicPlayer,
          let nowPlayingItem = player.nowPlayingItem else {
      result(0.0)
      return
    }
    
    let duration = nowPlayingItem.playbackDuration
    logToFlutter("⏱️ Duration: \(duration) seconds")
    result(duration)
  }
  
  private func seekToPosition(call: FlutterMethodCall, result: @escaping FlutterResult) {
    logToFlutter("⏩ Seeking to position")
    guard let player = musicPlayer else {
      logToFlutter("❌ No music player available for seek")
      result(false)
      return
    }
    
    guard let args = call.arguments as? [String: Any],
          let positionSeconds = args["position"] as? Double else {
      logToFlutter("❌ Invalid seek position arguments")
      result(false)
      return
    }
    
    logToFlutter("⏩ Seeking to: \(positionSeconds) seconds")
    player.currentPlaybackTime = positionSeconds
    logToFlutter("✅ Seek completed")
    result(true)
  }
  
  private func setPlaybackSpeed(call: FlutterMethodCall, result: @escaping FlutterResult) {
    logToFlutter("🚀 Setting playback speed")
    guard let player = musicPlayer else {
      logToFlutter("❌ No music player available for speed control")
      result(false)
      return
    }
    
    guard let args = call.arguments as? [String: Any],
          let speed = args["speed"] as? Double else {
      logToFlutter("❌ Invalid speed arguments")
      result(false)
      return
    }
    
    logToFlutter("🚀 Setting speed to: \(speed)x")
    player.currentPlaybackRate = Float(speed)
    logToFlutter("✅ Playback speed set to \(speed)x")
    result(true)
  }
  
  
  private func setEqualizerBand(call: FlutterMethodCall, result: @escaping FlutterResult) {
    logToFlutter("🎚️ Setting equalizer band")
    
    guard let args = call.arguments as? [String: Any],
          let bandIndex = args["bandIndex"] as? Int,
          let gain = args["gain"] as? Double else {
      logToFlutter("❌ Invalid equalizer band arguments")
      result(false)
      return
    }
    
    // TODO: Implementar ecualizador real con AVAudioEngine
    // Por ahora solo registramos la configuración
    logToFlutter("🎚️ Band \(bandIndex) set to \(gain)dB (simulated)")
    result(true)
  }
  
  private func setEqualizerEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
    logToFlutter("🎚️ Setting equalizer enabled status")
    
    guard let args = call.arguments as? [String: Any],
          let enabled = args["enabled"] as? Bool else {
      logToFlutter("❌ Invalid equalizer enabled arguments")
      result(false)
      return
    }
    
    // TODO: Implementar activación/desactivación real del ecualizador
    // Por ahora solo registramos el estado
    logToFlutter("🎚️ Equalizer \(enabled ? "enabled" : "disabled") (simulated)")
    result(true)
  }
  
  // ==========================================
  // MÉTODOS PARA REPRODUCCIÓN NATIVA DE MP3
  // ==========================================
  
  private func setupAudioSession() {
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.playback, mode: .default)
      try audioSession.setActive(true)
      logToFlutter("🔊 Audio session configured for playback")
    } catch {
      logToFlutter("❌ Failed to setup audio session: \(error)")
    }
  }
  
  private func updateNowPlayingInfoFromFlutter(call: FlutterMethodCall, result: @escaping FlutterResult) {
    logToFlutter("📱 Updating Now Playing info from Flutter")
    
    guard let args = call.arguments as? [String: Any] else {
      logToFlutter("❌ Invalid arguments for updateNowPlayingInfo")
      result(false)
      return
    }
    
    let title = args["title"] as? String ?? "Unknown Track"
    let artist = args["artist"] as? String ?? "Unknown Artist"
    let duration = args["duration"] as? Double ?? 0.0
    let currentTime = args["currentTime"] as? Double ?? 0.0
    let isPlaying = args["isPlaying"] as? Bool ?? false
    let artworkData = args["artwork"] as? FlutterStandardTypedData
    
    var nowPlayingInfo = [String: Any]()
    nowPlayingInfo[MPMediaItemPropertyTitle] = title
    nowPlayingInfo[MPMediaItemPropertyArtist] = artist
    nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
    nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
    
    // Convertir artwork de Uint8List a MPMediaItemArtwork
    if let artworkData = artworkData,
       let image = UIImage(data: artworkData.data) {
      let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
        return image
      }
      nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
    }
    
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    logToFlutter("✅ Updated Now Playing info: \(title) by \(artist) - \(currentTime)/\(duration)s")
    result(true)
  }
  
  private func setupRemoteCommandCenter() {
    let commandCenter = MPRemoteCommandCenter.shared()
    
    commandCenter.playCommand.addTarget { [weak self] _ in
      self?.resumeNativeMP3Player { _ in }
      return .success
    }
    
    commandCenter.pauseCommand.addTarget { [weak self] _ in
      self?.pauseNativeMP3Player { _ in }
      return .success
    }
    
    // Configurar botones de siguiente y anterior
    commandCenter.nextTrackCommand.addTarget { [weak self] _ in
      self?.logToFlutter("⏭️ Next track command from Control Center")
      self?.logChannel?.invokeMethod("onControlCenterNext", arguments: nil)
      return .success
    }
    
    commandCenter.previousTrackCommand.addTarget { [weak self] _ in
      self?.logToFlutter("⏮️ Previous track command from Control Center") 
      self?.logChannel?.invokeMethod("onControlCenterPrevious", arguments: nil)
      return .success
    }
    
    commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
      if let event = event as? MPChangePlaybackPositionCommandEvent {
        self?.audioPlayer?.currentTime = event.positionTime
        return .success
      }
      return .commandFailed
    }
    
    // Habilitar los comandos
    commandCenter.nextTrackCommand.isEnabled = true
    commandCenter.previousTrackCommand.isEnabled = true
    
    logToFlutter("🎛️ Remote command center configured with next/previous support")
  }
  
  private func setupMPMusicPlayerCommandCenter() {
    // Los targets ya están configurados en setupRemoteCommandCenter()
    // Solo necesitamos habilitar los comandos
    let commandCenter = MPRemoteCommandCenter.shared()
    commandCenter.nextTrackCommand.isEnabled = true
    commandCenter.previousTrackCommand.isEnabled = true
    
    logToFlutter("🎛️ MPMusicPlayer command center configured")
  }
  
  private func playMP3WithNativePlayer(call: FlutterMethodCall, result: @escaping FlutterResult) {
    logToFlutter("🎵 Starting native MP3 playback")
    
    guard let args = call.arguments as? [String: Any],
          let filePath = args["filePath"] as? String else {
      logToFlutter("❌ Invalid arguments for MP3 player")
      result(false)
      return
    }
    
    logToFlutter("🔍 Playing MP3 file: \(filePath)")
    
    // Setup audio session
    setupAudioSession()
    
    // Stop any existing playback
    audioPlayer?.stop()
    
    guard let url = URL(string: filePath) else {
      logToFlutter("❌ Invalid file path for MP3")
      result(false)
      return
    }
    
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer?.prepareToPlay()
      
      let success = audioPlayer?.play() ?? false
      
      if success {
        // Setup remote command center and now playing info
        setupRemoteCommandCenter()
    setupMPMusicPlayerCommandCenter()
        // No actualizar aquí - Flutter se encarga de la sincronización continua
        logToFlutter("✅ Native MP3 player started!")
      } else {
        logToFlutter("❌ Failed to start native MP3 player")
      }
      result(success)
    } catch {
      logToFlutter("❌ Error creating AVAudioPlayer: \(error)")
      result(false)
    }
  }
  
  private func getMP3Duration(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let filePath = args["filePath"] as? String,
          let url = URL(string: filePath) else {
      logToFlutter("❌ Invalid arguments for MP3 duration")
      result(0.0)
      return
    }
    
    do {
      let tempPlayer = try AVAudioPlayer(contentsOf: url)
      let duration = tempPlayer.duration
      logToFlutter("⏱️ MP3 Duration: \(duration) seconds")
      result(duration)
    } catch {
      logToFlutter("❌ Error getting MP3 duration: \(error)")
      result(0.0)
    }
  }
  
  private func pauseNativeMP3Player(result: @escaping FlutterResult) {
    logToFlutter("⏸️ Pausing native MP3 player")
    guard let player = audioPlayer else {
      logToFlutter("❌ No native MP3 player available")
      result(false)
      return
    }
    
    player.pause()
    logToFlutter("✅ Native MP3 player paused")
    result(true)
  }
  
  private func stopNativeMP3Player(result: @escaping FlutterResult) {
    logToFlutter("⏹️ Stopping native MP3 player")
    guard let player = audioPlayer else {
      logToFlutter("❌ No native MP3 player available")
      result(false)
      return
    }
    
    player.stop()
    audioPlayer = nil
    // Clear now playing info when stopped
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    logToFlutter("✅ Native MP3 player stopped")
    result(true)
  }
  
  private func resumeNativeMP3Player(result: @escaping FlutterResult) {
    logToFlutter("▶️ Resuming native MP3 player")
    guard let player = audioPlayer else {
      logToFlutter("❌ No native MP3 player available")
      result(false)
      return
    }
    
    let success = player.play()
    logToFlutter(success ? "✅ Native MP3 player resumed" : "❌ Failed to resume native MP3 player")
    result(success)
  }
  
  private func getNativeMP3PlayerStatus(result: @escaping FlutterResult) {
    guard let player = audioPlayer else {
      result("stopped")
      return
    }
    
    let status = player.isPlaying ? "playing" : "paused"
    logToFlutter("📊 Native MP3 player status: \(status)")
    result(status)
  }
  
  private func getCurrentMP3Position(result: @escaping FlutterResult) {
    guard let player = audioPlayer else {
      result(0.0)
      return
    }
    
    let currentTime = player.currentTime
    logToFlutter("⏱️ Current MP3 position: \(currentTime) seconds")
    result(currentTime)
  }
  
  private func seekToMP3Position(call: FlutterMethodCall, result: @escaping FlutterResult) {
    logToFlutter("⏩ Seeking MP3 to position")
    guard let player = audioPlayer else {
      logToFlutter("❌ No native MP3 player available for seek")
      result(false)
      return
    }
    
    guard let args = call.arguments as? [String: Any],
          let positionSeconds = args["position"] as? Double else {
      logToFlutter("❌ Invalid seek position arguments for MP3")
      result(false)
      return
    }
    
    logToFlutter("⏩ Seeking MP3 to: \(positionSeconds) seconds")
    player.currentTime = positionSeconds
    logToFlutter("✅ MP3 seek completed")
    result(true)
  }
  
  private func setMP3PlaybackSpeed(call: FlutterMethodCall, result: @escaping FlutterResult) {
    logToFlutter("🚀 Setting MP3 playback speed")
    guard let player = audioPlayer else {
      logToFlutter("❌ No native MP3 player available for speed control")
      result(false)
      return
    }
    
    guard let args = call.arguments as? [String: Any],
          let speed = args["speed"] as? Double else {
      logToFlutter("❌ Invalid speed arguments for MP3")
      result(false)
      return
    }
    
    logToFlutter("🚀 Setting MP3 speed to: \(speed)x")
    player.enableRate = true
    player.rate = Float(speed)
    logToFlutter("✅ MP3 playback speed set to \(speed)x")
    result(true)
  }
  
}
