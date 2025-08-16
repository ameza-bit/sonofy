import Flutter
import UIKit
import MediaPlayer
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var musicPlayer: MPMusicPlayerController?
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
      case "exportAudio":
        self?.exportAudio(call: call, result: result)
      case "playDirectly":
        self?.playDirectly(call: call, result: result)
      case "playWithMusicPlayer":
        self?.playWithMusicPlayer(call: call, result: result)
      case "pauseMusicPlayer":
        self?.pauseMusicPlayer(result: result)
      case "stopMusicPlayer":
        self?.stopMusicPlayer(result: result)
      case "getMusicPlayerStatus":
        self?.getMusicPlayerStatus(result: result)
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
  
  private func exportAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
    logToFlutter("📦 Starting audio export")
    
    guard let args = call.arguments as? [String: Any],
          let songIdString = args["songId"] as? String,
          let outputPath = args["outputPath"] as? String,
          let songId = UInt64(songIdString) else {
      logToFlutter("❌ Invalid export arguments")
      result(false)
      return
    }
    
    logToFlutter("🔍 Searching for song ID: \(songId)")
    
    let query = MPMediaQuery.songs()
    let predicate = MPMediaPropertyPredicate(value: NSNumber(value: songId), forProperty: MPMediaItemPropertyPersistentID)
    query.addFilterPredicate(predicate)
    
    guard let mediaItems = query.items, let mediaItem = mediaItems.first else {
      logToFlutter("❌ No media item found for export")
      result(false)
      return
    }
    
    logToFlutter("✅ Found: \(mediaItem.title ?? "Unknown")")
    
    guard let assetURL = mediaItem.assetURL else {
      logToFlutter("❌ No asset URL available")
      result(false)
      return
    }
    
    logToFlutter("🔗 Asset URL: \(assetURL)")
    
    // Try direct file copy approach
    let outputURL = URL(fileURLWithPath: outputPath)
    
    // Create parent directory
    let parentDir = outputURL.deletingLastPathComponent()
    do {
      try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
      logToFlutter("📁 Created output directory")
    } catch {
      logToFlutter("❌ Failed to create directory: \(error.localizedDescription)")
    }
    
    // Remove existing file
    if FileManager.default.fileExists(atPath: outputPath) {
      try? FileManager.default.removeItem(atPath: outputPath)
      logToFlutter("🗑️ Removed existing file")
    }
    
    // First try: Direct file copy if possible
    do {
      let data = try Data(contentsOf: assetURL)
      try data.write(to: outputURL)
      logToFlutter("✅ Direct copy successful! Size: \(data.count) bytes")
      result(true)
      return
    } catch {
      logToFlutter("⚠️ Direct copy failed: \(error.localizedDescription)")
    }
    
    // Second try: Use AVAssetReader for more control
    logToFlutter("🔄 Trying AVAssetReader approach...")
    
    let asset = AVURLAsset(url: assetURL)
    
    // Check if asset is readable
    guard asset.isReadable else {
      logToFlutter("❌ Asset is not readable")
      result(false)
      return
    }
    
    logToFlutter("📖 Asset is readable, checking tracks...")
    
    let audioTracks = asset.tracks(withMediaType: .audio)
    guard !audioTracks.isEmpty else {
      logToFlutter("❌ No audio tracks found")
      result(false)
      return
    }
    
    logToFlutter("🎵 Found \(audioTracks.count) audio track(s)")
    
    // Try AVAssetExportSession with different settings
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
      logToFlutter("❌ Could not create export session")
      result(false)
      return
    }
    
    // Check supported file types
    let supportedTypes = exportSession.supportedFileTypes
    logToFlutter("📋 Supported types: \(supportedTypes)")
    
    exportSession.outputURL = outputURL
    
    // Try different file types
    if supportedTypes.contains(.m4a) {
      exportSession.outputFileType = .m4a
      logToFlutter("🎯 Using .m4a format")
    } else if supportedTypes.contains(.caf) {
      exportSession.outputFileType = .caf
      logToFlutter("🎯 Using .caf format")
    } else if supportedTypes.contains(.mov) {
      exportSession.outputFileType = .mov
      logToFlutter("🎯 Using .mov format")
    } else {
      logToFlutter("❌ No supported file types found")
      result(false)
      return
    }
    
    logToFlutter("📦 Starting export...")
    
    exportSession.exportAsynchronously {
      DispatchQueue.main.async {
        switch exportSession.status {
        case .completed:
          self.logToFlutter("✅ Export completed successfully!")
          result(true)
        case .failed:
          let error = exportSession.error?.localizedDescription ?? "Unknown error"
          self.logToFlutter("❌ Export failed: \(error)")
          // Try one more approach - create a symbolic link
          self.trySymbolicLink(from: assetURL, to: outputURL, result: result)
        case .cancelled:
          self.logToFlutter("❌ Export was cancelled")
          result(false)
        default:
          self.logToFlutter("❌ Export finished with status: \(exportSession.status.rawValue)")
          result(false)
        }
      }
    }
  }
  
  private func trySymbolicLink(from sourceURL: URL, to destinationURL: URL, result: @escaping FlutterResult) {
    logToFlutter("🔗 Trying symbolic link approach...")
    
    do {
      // Remove destination if exists
      if FileManager.default.fileExists(atPath: destinationURL.path) {
        try FileManager.default.removeItem(at: destinationURL)
      }
      
      // Create symbolic link
      try FileManager.default.createSymbolicLink(at: destinationURL, withDestinationURL: sourceURL)
      logToFlutter("✅ Symbolic link created successfully!")
      result(true)
    } catch {
      logToFlutter("❌ Symbolic link failed: \(error.localizedDescription)")
      result(false)
    }
  }
  
  private func playDirectly(call: FlutterMethodCall, result: @escaping FlutterResult) {
    logToFlutter("🎵 Starting direct playback")
    guard let args = call.arguments as? [String: Any],
          let songIdString = args["songId"] as? String,
          let songId = UInt64(songIdString) else {
      logToFlutter("❌ Invalid playback arguments")
      result(false)
      return
    }
    
    let query = MPMediaQuery.songs()
    let predicate = MPMediaPropertyPredicate(value: NSNumber(value: songId), forProperty: MPMediaItemPropertyPersistentID)
    query.addFilterPredicate(predicate)
    
    guard let mediaItems = query.items, let mediaItem = mediaItems.first else {
      logToFlutter("❌ No media item found for playback")
      result(false)
      return
    }
    
    if let assetURL = mediaItem.assetURL {
      logToFlutter("🎵 Asset URL available: \(assetURL)")
      // TODO: Implement AVPlayer playback
      result(true)
    } else {
      logToFlutter("❌ No asset URL for playback")
      result(false)
    }
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
}
