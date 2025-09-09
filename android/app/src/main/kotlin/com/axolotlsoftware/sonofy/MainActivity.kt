package com.axolotlsoftware.sonofy

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.MediaPlayer
import android.media.MediaMetadataRetriever
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val CHANNEL = "native_audio_player"
    private var mediaPlayer: MediaPlayer? = null
    private var handler: Handler? = null
    private var positionRunnable: Runnable? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playTrack" -> playTrack(call.argument<String>("url")!!, result)
                "pauseTrack" -> pauseTrack(result)
                "resumeTrack" -> resumeTrack(result)
                "stopTrack" -> stopTrack(result)
                "seekToPosition" -> seekToPosition(call.argument<Double>("position")!!, result)
                "getCurrentPosition" -> getCurrentPosition(result)
                "getDuration" -> getDuration(result)
                "isPlaying" -> isPlaying(result)
                "setPlaybackSpeed" -> setPlaybackSpeed(call.argument<Double>("speed")!!, result)
                "setVolume" -> setVolume(call.argument<Double>("volume")!!, result)
                "getVolume" -> getVolume(result)
                else -> result.notImplemented()
            }
        }
    }
    
    private fun playTrack(url: String, result: MethodChannel.Result) {
        try {
            Log.d("NativeAudioPlayer", "Playing track: $url")
            
            // Stop any existing playback
            mediaPlayer?.release()
            mediaPlayer = MediaPlayer().apply {
                setDataSource(url)
                prepareAsync()
                setOnPreparedListener { player ->
                    player.start()
                    startPositionUpdates()
                    Log.d("NativeAudioPlayer", "Track started playing")
                    result.success(true)
                }
                setOnErrorListener { _, what, extra ->
                    Log.e("NativeAudioPlayer", "MediaPlayer error: $what, $extra")
                    result.success(false)
                    false
                }
                setOnCompletionListener {
                    Log.d("NativeAudioPlayer", "Track completed")
                    stopPositionUpdates()
                }
            }
        } catch (e: IOException) {
            Log.e("NativeAudioPlayer", "Error playing track", e)
            result.success(false)
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Unexpected error playing track", e)
            result.success(false)
        }
    }
    
    private fun pauseTrack(result: MethodChannel.Result) {
        try {
            mediaPlayer?.pause()
            stopPositionUpdates()
            result.success(true)
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error pausing track", e)
            result.success(false)
        }
    }
    
    private fun resumeTrack(result: MethodChannel.Result) {
        try {
            mediaPlayer?.start()
            startPositionUpdates()
            result.success(true)
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error resuming track", e)
            result.success(false)
        }
    }
    
    private fun stopTrack(result: MethodChannel.Result) {
        try {
            mediaPlayer?.stop()
            stopPositionUpdates()
            result.success(true)
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error stopping track", e)
            result.success(false)
        }
    }
    
    private fun seekToPosition(positionSeconds: Double, result: MethodChannel.Result) {
        try {
            val positionMs = (positionSeconds * 1000).toInt()
            mediaPlayer?.seekTo(positionMs)
            result.success(true)
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error seeking to position", e)
            result.success(false)
        }
    }
    
    private fun getCurrentPosition(result: MethodChannel.Result) {
        try {
            val currentMs = mediaPlayer?.currentPosition ?: 0
            val currentSeconds = currentMs.toDouble() / 1000.0
            result.success(currentSeconds)
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error getting current position", e)
            result.success(0.0)
        }
    }
    
    private fun getDuration(result: MethodChannel.Result) {
        try {
            val durationMs = mediaPlayer?.duration ?: 0
            val durationSeconds = durationMs.toDouble() / 1000.0
            result.success(durationSeconds)
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error getting duration", e)
            result.success(0.0)
        }
    }
    
    private fun isPlaying(result: MethodChannel.Result) {
        try {
            val playing = mediaPlayer?.isPlaying ?: false
            result.success(playing)
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error checking if playing", e)
            result.success(false)
        }
    }
    
    private fun setPlaybackSpeed(speed: Double, result: MethodChannel.Result) {
        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                val params = mediaPlayer?.playbackParams
                if (params != null) {
                    params.speed = speed.toFloat()
                    mediaPlayer?.playbackParams = params
                    result.success(true)
                } else {
                    result.success(false)
                }
            } else {
                // Speed control not available on older versions
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error setting playback speed", e)
            result.success(false)
        }
    }
    
    private fun setVolume(volume: Double, result: MethodChannel.Result) {
        try {
            val vol = volume.toFloat()
            mediaPlayer?.setVolume(vol, vol)
            result.success(true)
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error setting volume", e)
            result.success(false)
        }
    }
    
    private fun getVolume(result: MethodChannel.Result) {
        // MediaPlayer doesn't provide direct volume getter
        // Return a default value or maintain volume state
        result.success(1.0)
    }
    
    private fun startPositionUpdates() {
        if (handler == null) {
            handler = Handler(Looper.getMainLooper())
        }
        
        positionRunnable = object : Runnable {
            override fun run() {
                // Position updates will be handled by Flutter's timer
                // This is just for maintaining the MediaPlayer state
                handler?.postDelayed(this, 500)
            }
        }
        
        positionRunnable?.let { handler?.post(it) }
    }
    
    private fun stopPositionUpdates() {
        positionRunnable?.let { handler?.removeCallbacks(it) }
        positionRunnable = null
    }
    
    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.release()
        mediaPlayer = null
        stopPositionUpdates()
        handler = null
    }
}
