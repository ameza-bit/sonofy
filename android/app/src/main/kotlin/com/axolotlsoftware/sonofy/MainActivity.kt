package com.axolotlsoftware.sonofy

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "native_audio_player"
    private var mediaService: NativeMediaService? = null
    private var serviceBound = false
    
    companion object {
        private var instance: MainActivity? = null
        private var methodChannel: MethodChannel? = null
        
        fun sendMediaCommand(command: String, value: Long = 0) {
            Log.d("MainActivity", "Sending media command: $command")
            instance?.runOnUiThread {
                when (command) {
                    "play" -> methodChannel?.invokeMethod("onMediaButtonPlay", null)
                    "pause" -> methodChannel?.invokeMethod("onMediaButtonPause", null)
                    "next" -> methodChannel?.invokeMethod("onMediaButtonNext", null)
                    "previous" -> methodChannel?.invokeMethod("onMediaButtonPrevious", null)
                    "stop" -> methodChannel?.invokeMethod("onMediaButtonStop", null)
                    "seek" -> methodChannel?.invokeMethod("onMediaButtonSeek", value)
                }
            }
        }
    }
    
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as NativeMediaService.MediaServiceBinder
            mediaService = binder.getService()
            serviceBound = true
            Log.d("MainActivity", "MediaService connected")
            
            // Set up callbacks to Flutter
            mediaService?.setCallbacks(
                onPlay = { methodChannel?.invokeMethod("onMediaButtonPlay", null) },
                onPause = { methodChannel?.invokeMethod("onMediaButtonPause", null) },
                onNext = { methodChannel?.invokeMethod("onMediaButtonNext", null) },
                onPrevious = { methodChannel?.invokeMethod("onMediaButtonPrevious", null) },
                onStop = { methodChannel?.invokeMethod("onMediaButtonStop", null) }
            )
        }
        
        override fun onServiceDisconnected(name: ComponentName?) {
            mediaService = null
            serviceBound = false
            Log.d("MainActivity", "MediaService disconnected")
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        instance = this
        
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel = channel
        
        channel.setMethodCallHandler { call, result ->
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
                "updateNotification" -> updateNotification(call, result)
                "hideNotification" -> hideNotification(result)
                "setupMediaButtonHandlers" -> setupMediaButtonHandlers(result)
                "bindMediaService" -> bindMediaService(result)
                else -> result.notImplemented()
            }
        }
        
        // Bind to media service
        bindToMediaService()
    }
    
    private fun bindToMediaService() {
        val intent = Intent(this, NativeMediaService::class.java)
        bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
    }
    
    private fun bindMediaService(result: MethodChannel.Result) {
        if (!serviceBound) {
            bindToMediaService()
        }
        result.success(true)
    }
    
    private fun playTrack(url: String, result: MethodChannel.Result) {
        try {
            Log.d("NativeAudioPlayer", "Playing track: $url")
            
            if (serviceBound && mediaService != null) {
                val success = mediaService!!.playTrack(url)
                result.success(success)
            } else {
                Log.e("NativeAudioPlayer", "MediaService not bound")
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error playing track", e)
            result.success(false)
        }
    }
    
    private fun pauseTrack(result: MethodChannel.Result) {
        try {
            if (serviceBound && mediaService != null) {
                val success = mediaService!!.pausePlayback()
                result.success(success)
            } else {
                Log.e("NativeAudioPlayer", "MediaService not bound")
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error pausing track", e)
            result.success(false)
        }
    }
    
    private fun resumeTrack(result: MethodChannel.Result) {
        try {
            if (serviceBound && mediaService != null) {
                val success = mediaService!!.resumePlayback()
                result.success(success)
            } else {
                Log.e("NativeAudioPlayer", "MediaService not bound")
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error resuming track", e)
            result.success(false)
        }
    }
    
    private fun stopTrack(result: MethodChannel.Result) {
        try {
            if (serviceBound && mediaService != null) {
                val success = mediaService!!.stopPlayback()
                result.success(success)
            } else {
                Log.e("NativeAudioPlayer", "MediaService not bound")
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error stopping track", e)
            result.success(false)
        }
    }
    
    private fun seekToPosition(positionSeconds: Double, result: MethodChannel.Result) {
        try {
            val positionMs = (positionSeconds * 1000).toInt()
            if (serviceBound && mediaService != null) {
                val success = mediaService!!.seekTo(positionMs)
                result.success(success)
            } else {
                Log.e("NativeAudioPlayer", "MediaService not bound")
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error seeking to position", e)
            result.success(false)
        }
    }
    
    private fun getCurrentPosition(result: MethodChannel.Result) {
        try {
            if (serviceBound && mediaService != null) {
                val currentMs = mediaService!!.getCurrentPosition()
                val currentSeconds = currentMs.toDouble() / 1000.0
                result.success(currentSeconds)
            } else {
                Log.e("NativeAudioPlayer", "MediaService not bound")
                result.success(0.0)
            }
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error getting current position", e)
            result.success(0.0)
        }
    }
    
    private fun getDuration(result: MethodChannel.Result) {
        try {
            if (serviceBound && mediaService != null) {
                val durationMs = mediaService!!.getDuration()
                val durationSeconds = durationMs.toDouble() / 1000.0
                result.success(durationSeconds)
            } else {
                Log.e("NativeAudioPlayer", "MediaService not bound")
                result.success(0.0)
            }
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error getting duration", e)
            result.success(0.0)
        }
    }
    
    private fun isPlaying(result: MethodChannel.Result) {
        try {
            if (serviceBound && mediaService != null) {
                val playing = mediaService!!.isPlaying()
                result.success(playing)
            } else {
                Log.e("NativeAudioPlayer", "MediaService not bound")
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error checking if playing", e)
            result.success(false)
        }
    }
    
    private fun setPlaybackSpeed(speed: Double, result: MethodChannel.Result) {
        try {
            if (serviceBound && mediaService != null) {
                val success = mediaService!!.setPlaybackSpeed(speed.toFloat())
                result.success(success)
            } else {
                Log.e("NativeAudioPlayer", "MediaService not bound")
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error setting playback speed", e)
            result.success(false)
        }
    }
    
    private fun setVolume(volume: Double, result: MethodChannel.Result) {
        try {
            // El volumen se maneja a nivel del sistema, no del MediaPlayer específico
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
    
    
    private fun updateNotification(call: MethodCall, result: MethodChannel.Result) {
        try {
            val title = call.argument<String>("title") ?: "Unknown Track"
            val artist = call.argument<String>("artist") ?: "Unknown Artist"
            val artwork = call.argument<ByteArray>("artwork")
            
            Log.d("NativeAudioPlayer", "Updating notification: $title by $artist")
            
            if (serviceBound && mediaService != null) {
                mediaService!!.updateMetadata(title, artist, artwork)
                result.success(true)
            } else {
                Log.e("NativeAudioPlayer", "MediaService not bound")
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error updating notification", e)
            result.success(false)
        }
    }
    
    private fun hideNotification(result: MethodChannel.Result) {
        try {
            if (serviceBound && mediaService != null) {
                mediaService!!.stopPlayback()
                result.success(true)
            } else {
                result.success(true)
            }
        } catch (e: Exception) {
            Log.e("NativeAudioPlayer", "Error hiding notification", e)
            result.success(false)
        }
    }
    
    private fun setupMediaButtonHandlers(result: MethodChannel.Result) {
        // Este método se llama desde Flutter para configurar los handlers
        result.success(true)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        instance = null
        methodChannel = null
        
        // Desconectar del servicio
        if (serviceBound) {
            unbindService(serviceConnection)
            serviceBound = false
        }
    }
}
