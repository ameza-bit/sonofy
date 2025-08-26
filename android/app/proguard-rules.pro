# Keep audio_service classes
-keep class com.ryanheise.audioservice.** { *; }

# Keep media session classes
-keep class androidx.media.** { *; }
-keep class android.support.v4.media.** { *; }

# Keep AudioService background execution
-keep class * extends com.ryanheise.audioservice.AudioServicePlugin$AudioServiceActivity