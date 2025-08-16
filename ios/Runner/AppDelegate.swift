import Flutter
import UIKit
import MediaPlayer
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "ipod_library_converter", binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "exportAudio" {
        self?.exportAudio(call: call, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func exportAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let songIdString = args["songId"] as? String,
          let outputPath = args["outputPath"] as? String,
          let songId = UInt64(songIdString) else {
      result(false)
      return
    }
    
    let query = MPMediaQuery.songs()
    let predicate = MPMediaPropertyPredicate(value: NSNumber(value: songId), forProperty: MPMediaItemPropertyPersistentID)
    query.addFilterPredicate(predicate)
    
    guard let mediaItems = query.items,
          let mediaItem = mediaItems.first,
          let assetURL = mediaItem.assetURL else {
      result(false)
      return
    }
    
    let asset = AVURLAsset(url: assetURL)
    let outputURL = URL(fileURLWithPath: outputPath)
    
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
      result(false)
      return
    }
    
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: outputPath) {
      try? fileManager.removeItem(atPath: outputPath)
    }
    
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .m4a
    
    exportSession.exportAsynchronously {
      DispatchQueue.main.async {
        switch exportSession.status {
        case .completed:
          result(true)
        case .failed, .cancelled:
          result(false)
        default:
          result(false)
        }
      }
    }
  }
}
