package com.axolotlsoftware.sonofy

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import android.util.Log
import java.io.IOException

class NativeMediaService : Service(), MediaPlayer.OnPreparedListener, MediaPlayer.OnCompletionListener, MediaPlayer.OnErrorListener, AudioManager.OnAudioFocusChangeListener {
    companion object {
        private const val TAG = "NativeMediaService"
        private const val NOTIFICATION_ID = 1
        private const val CHANNEL_ID = "sonofy_media_channel"
        private const val CHANNEL_NAME = "Sonofy Media"
        
        private var instance: NativeMediaService? = null
        
        fun getInstance(): NativeMediaService? = instance
    }

    private val binder = MediaServiceBinder()
    private var mediaPlayer: MediaPlayer? = null
    private var mediaSession: MediaSessionCompat? = null
    private var notificationManager: NotificationManager? = null
    private var audioManager: AudioManager? = null
    private var headsetReceiver: BroadcastReceiver? = null
    
    // Current track info
    private var currentTitle = "Unknown Track"
    private var currentArtist = "Unknown Artist"
    private var currentArtwork: Bitmap? = null
    private var isPlaying = false
    
    // Callbacks to Flutter
    private var onPlayCallback: (() -> Unit)? = null
    private var onPauseCallback: (() -> Unit)? = null
    private var onNextCallback: (() -> Unit)? = null
    private var onPreviousCallback: (() -> Unit)? = null
    private var onStopCallback: (() -> Unit)? = null

    inner class MediaServiceBinder : Binder() {
        fun getService(): NativeMediaService = this@NativeMediaService
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        Log.d(TAG, "NativeMediaService created")
        
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        createNotificationChannel()
        initializeMediaSession()
        setupHeadsetReceiver()
    }

    override fun onBind(intent: Intent): IBinder = binder

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "NativeMediaService onStartCommand")
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        unregisterHeadsetReceiver()
        abandonAudioFocus()
        releaseMediaPlayer()
        releaseMediaSession()
        Log.d(TAG, "NativeMediaService destroyed")
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Music playback controls"
                setShowBadge(false)
            }
            
            notificationManager?.createNotificationChannel(channel)
        }
    }

    private fun initializeMediaSession() {
        mediaSession = MediaSessionCompat(this, TAG).apply {
            setFlags(
                MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS or 
                MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS
            )
            
            setCallback(object : MediaSessionCompat.Callback() {
                override fun onPlay() {
                    Log.d(TAG, "MediaSession onPlay")
                    resumePlayback()
                    onPlayCallback?.invoke()
                }

                override fun onPause() {
                    Log.d(TAG, "MediaSession onPause")
                    pausePlayback()
                    onPauseCallback?.invoke()
                }

                override fun onSkipToNext() {
                    Log.d(TAG, "MediaSession onNext")
                    onNextCallback?.invoke()
                }

                override fun onSkipToPrevious() {
                    Log.d(TAG, "MediaSession onPrevious")
                    onPreviousCallback?.invoke()
                }

                override fun onStop() {
                    Log.d(TAG, "MediaSession onStop")
                    stopPlayback()
                    onStopCallback?.invoke()
                }

                override fun onSeekTo(pos: Long) {
                    Log.d(TAG, "MediaSession onSeekTo: $pos")
                    mediaPlayer?.seekTo(pos.toInt())
                }
            })
            
            isActive = true
        }
    }

    // Public API methods
    fun playTrack(filePath: String): Boolean {
        try {
            Log.d(TAG, "Playing track: $filePath")
            
            // Solicitar foco de audio antes de reproducir
            if (!requestAudioFocus()) {
                Log.w(TAG, "Failed to gain audio focus, but continuing anyway")
            }
            
            releaseMediaPlayer()
            
            mediaPlayer = MediaPlayer().apply {
                setDataSource(filePath)
                setOnPreparedListener(this@NativeMediaService)
                setOnCompletionListener(this@NativeMediaService)
                setOnErrorListener(this@NativeMediaService)
                prepareAsync()
            }
            
            return true
        } catch (e: IOException) {
            Log.e(TAG, "Error preparing media player", e)
            abandonAudioFocus()
            return false
        }
    }

    fun pausePlayback(): Boolean {
        return try {
            mediaPlayer?.pause()
            isPlaying = false
            updatePlaybackState()
            updateNotification()
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error pausing playback", e)
            false
        }
    }

    fun resumePlayback(): Boolean {
        return try {
            mediaPlayer?.start()
            isPlaying = true
            updatePlaybackState()
            updateNotification()
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error resuming playback", e)
            false
        }
    }

    fun stopPlayback(): Boolean {
        return try {
            mediaPlayer?.stop()
            isPlaying = false
            updatePlaybackState()
            stopForeground(true)
            abandonAudioFocus()
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping playback", e)
            false
        }
    }

    fun seekTo(position: Int): Boolean {
        return try {
            mediaPlayer?.seekTo(position)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error seeking", e)
            false
        }
    }

    fun getCurrentPosition(): Int {
        return mediaPlayer?.currentPosition ?: 0
    }

    fun getDuration(): Int {
        return mediaPlayer?.duration ?: 0
    }

    fun isPlaying(): Boolean {
        return mediaPlayer?.isPlaying ?: false
    }

    fun setPlaybackSpeed(speed: Float): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val params = mediaPlayer?.playbackParams
                if (params != null) {
                    params.speed = speed
                    mediaPlayer?.playbackParams = params
                    true
                } else false
            } else false
        } catch (e: Exception) {
            Log.e(TAG, "Error setting playback speed", e)
            false
        }
    }

    fun updateMetadata(title: String, artist: String, artwork: ByteArray?) {
        currentTitle = title
        currentArtist = artist
        
        currentArtwork = artwork?.let { 
            try {
                BitmapFactory.decodeByteArray(it, 0, it.size)
            } catch (e: Exception) {
                Log.e(TAG, "Error decoding artwork", e)
                null
            }
        }
        
        updateMediaSessionMetadata()
        updateNotification()
    }

    fun setCallbacks(
        onPlay: (() -> Unit)?,
        onPause: (() -> Unit)?,
        onNext: (() -> Unit)?,
        onPrevious: (() -> Unit)?,
        onStop: (() -> Unit)?
    ) {
        onPlayCallback = onPlay
        onPauseCallback = onPause
        onNextCallback = onNext
        onPreviousCallback = onPrevious
        onStopCallback = onStop
    }

    // MediaPlayer callbacks
    override fun onPrepared(mp: MediaPlayer) {
        Log.d(TAG, "MediaPlayer prepared")
        mp.start()
        isPlaying = true
        updatePlaybackState()
        updateNotification()
    }

    override fun onCompletion(mp: MediaPlayer) {
        Log.d(TAG, "MediaPlayer completed")
        isPlaying = false
        onNextCallback?.invoke()
    }

    override fun onError(mp: MediaPlayer?, what: Int, extra: Int): Boolean {
        Log.e(TAG, "MediaPlayer error: what=$what, extra=$extra")
        isPlaying = false
        updatePlaybackState()
        return true
    }

    private fun updateMediaSessionMetadata() {
        val metadataBuilder = MediaMetadataCompat.Builder()
            .putString(MediaMetadataCompat.METADATA_KEY_TITLE, currentTitle)
            .putString(MediaMetadataCompat.METADATA_KEY_ARTIST, currentArtist)
            .putLong(MediaMetadataCompat.METADATA_KEY_DURATION, getDuration().toLong())

        currentArtwork?.let { 
            metadataBuilder.putBitmap(MediaMetadataCompat.METADATA_KEY_ALBUM_ART, it)
        }

        mediaSession?.setMetadata(metadataBuilder.build())
    }

    private fun updatePlaybackState() {
        val state = if (isPlaying) PlaybackStateCompat.STATE_PLAYING else PlaybackStateCompat.STATE_PAUSED
        
        val playbackState = PlaybackStateCompat.Builder()
            .setActions(
                PlaybackStateCompat.ACTION_PLAY or
                PlaybackStateCompat.ACTION_PAUSE or
                PlaybackStateCompat.ACTION_SKIP_TO_NEXT or
                PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS or
                PlaybackStateCompat.ACTION_STOP or
                PlaybackStateCompat.ACTION_SEEK_TO
            )
            .setState(state, getCurrentPosition().toLong(), 1.0f)
            .build()

        mediaSession?.setPlaybackState(playbackState)
    }

    private fun updateNotification() {
        val mediaStyle = androidx.media.app.NotificationCompat.MediaStyle()
            .setMediaSession(mediaSession?.sessionToken)

        val notification = androidx.core.app.NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(currentTitle)
            .setContentText(currentArtist)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setStyle(mediaStyle)
            .setVisibility(androidx.core.app.NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(isPlaying)
            .apply {
                currentArtwork?.let { setLargeIcon(it) }
            }
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }

    private fun releaseMediaPlayer() {
        mediaPlayer?.release()
        mediaPlayer = null
    }

    private fun setupHeadsetReceiver() {
        headsetReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    AudioManager.ACTION_AUDIO_BECOMING_NOISY -> {
                        // Se desconectaron los auriculares
                        Log.d(TAG, "Headphones disconnected, pausing playback")
                        if (isPlaying()) {
                            pausePlayback()
                            onPauseCallback?.invoke()
                        }
                    }
                    Intent.ACTION_HEADSET_PLUG -> {
                        // Información adicional sobre la conexión/desconexión de auriculares
                        val state = intent.getIntExtra("state", -1)
                        when (state) {
                            0 -> {
                                // Auriculares desconectados
                                Log.d(TAG, "Headset unplugged, pausing playback")
                                if (isPlaying()) {
                                    pausePlayback()
                                    onPauseCallback?.invoke()
                                }
                            }
                            1 -> {
                                // Auriculares conectados
                                Log.d(TAG, "Headset plugged in")
                                // No reanudar automáticamente, el usuario debe hacerlo manualmente
                            }
                        }
                    }
                }
            }
        }
        
        val intentFilter = IntentFilter().apply {
            addAction(AudioManager.ACTION_AUDIO_BECOMING_NOISY)
            addAction(Intent.ACTION_HEADSET_PLUG)
        }
        
        try {
            registerReceiver(headsetReceiver, intentFilter)
            Log.d(TAG, "Headset receiver registered successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register headset receiver", e)
        }
    }
    
    private fun unregisterHeadsetReceiver() {
        headsetReceiver?.let { 
            try {
                unregisterReceiver(it)
                Log.d(TAG, "Headset receiver unregistered successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to unregister headset receiver", e)
            }
        }
        headsetReceiver = null
    }

    // AudioManager.OnAudioFocusChangeListener
    override fun onAudioFocusChange(focusChange: Int) {
        when (focusChange) {
            AudioManager.AUDIOFOCUS_LOSS -> {
                // Pérdida permanente del foco de audio (otra app reproductor música)
                Log.d(TAG, "Audio focus lost permanently, stopping playback")
                if (isPlaying()) {
                    pausePlayback()
                    onPauseCallback?.invoke()
                }
                abandonAudioFocus()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                // Pérdida temporal del foco (notificación, llamada)
                Log.d(TAG, "Audio focus lost temporarily, pausing playback")
                if (isPlaying()) {
                    pausePlayback()
                    onPauseCallback?.invoke()
                }
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                // Pérdida temporal pero podemos seguir reproduciendo a bajo volumen
                Log.d(TAG, "Audio focus lost temporarily, ducking volume")
                mediaPlayer?.setVolume(0.3f, 0.3f)
            }
            AudioManager.AUDIOFOCUS_GAIN -> {
                // Recuperamos el foco de audio
                Log.d(TAG, "Audio focus gained")
                mediaPlayer?.setVolume(1.0f, 1.0f)
                // No reanudar automáticamente - el usuario debe hacerlo
            }
        }
    }

    private fun requestAudioFocus(): Boolean {
        val result = audioManager?.requestAudioFocus(
            this,
            AudioManager.STREAM_MUSIC,
            AudioManager.AUDIOFOCUS_GAIN
        ) ?: AudioManager.AUDIOFOCUS_REQUEST_FAILED
        
        return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    }

    private fun abandonAudioFocus() {
        audioManager?.abandonAudioFocus(this)
    }

    private fun releaseMediaSession() {
        mediaSession?.release()
        mediaSession = null
    }
}