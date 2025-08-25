import Flutter
import UIKit
import MediaPlayer
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var musicPlayer: MPMusicPlayerController?
  private var audioEngine: AVAudioEngine?
  private var equalizerNode: AVAudioUnitEQ?
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
      case "getPlaybackSpeed":
        self?.getPlaybackSpeed(result: result)
      case "setEqualizerBand":
        self?.setEqualizerBand(call: call, result: result)
      case "setEqualizerEnabled":
        self?.setEqualizerEnabled(call: call, result: result)
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
  
  private func getPlaybackSpeed(result: @escaping FlutterResult) {
    guard let player = musicPlayer else {
      logToFlutter("❌ No music player available for speed check")
      result(1.0)
      return
    }
    
    let currentSpeed = Double(player.currentPlaybackRate)
    logToFlutter("📊 Current playback speed: \(currentSpeed)x")
    result(currentSpeed)
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
}
