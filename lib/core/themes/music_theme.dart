import 'package:flutter/material.dart';
import 'package:sonofy/core/themes/music_colors.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

/// Temas especializados para componentes de música y reproductor.
/// Proporciona configuraciones específicas para elementos como controles
/// de reproducción, listas de canciones, y otros componentes musicales.
class MusicTheme {
  
  /// Configuración del tema para el reproductor principal
  static MusicPlayerThemeData musicPlayerTheme(Color primaryColor) {
    return MusicPlayerThemeData(
      primaryColor: primaryColor,
      gradientColor: MusicColors.generateGradientColor(primaryColor),
      backgroundColor: MusicColors.surface,
      controlButtonSize: 56.0,
      smallControlButtonSize: 40.0,
      progressBarHeight: 4.0,
      albumArtSize: 280.0,
      albumArtBorderRadius: 16.0,
    );
  }
  
  /// Configuración del tema para elementos de playlist
  static PlaylistThemeData playlistTheme(Color primaryColor) {
    return PlaylistThemeData(
      primaryColor: primaryColor,
      itemHeight: 72.0,
      itemBorderRadius: 12.0,
      selectedItemColor: MusicColors.generateLightVariant(primaryColor),
      playingItemColor: primaryColor,
      itemSpacing: 8.0,
    );
  }
  
  /// Configuración del tema para cards de onboarding
  static OnboardingThemeData onboardingTheme(Color primaryColor) {
    return OnboardingThemeData(
      primaryColor: primaryColor,
      gradientColor: MusicColors.generateGradientColor(primaryColor),
      cardBorderRadius: 20.0,
      buttonBorderRadius: 12.0,
      indicatorSize: 8.0,
      spacing: 24.0,
    );
  }
  
  /// Configuración del tema para formularios de autenticación
  static AuthThemeData authTheme(Color primaryColor) {
    return AuthThemeData(
      primaryColor: primaryColor,
      gradientColor: MusicColors.generateGradientColor(primaryColor),
      inputBorderRadius: 12.0,
      buttonBorderRadius: 12.0,
      inputHeight: 56.0,
      buttonHeight: 56.0,
      formSpacing: 16.0,
    );
  }
}

/// Datos del tema para el reproductor de música
class MusicPlayerThemeData {
  const MusicPlayerThemeData({
    required this.primaryColor,
    required this.gradientColor,
    required this.backgroundColor,
    required this.controlButtonSize,
    required this.smallControlButtonSize,
    required this.progressBarHeight,
    required this.albumArtSize,
    required this.albumArtBorderRadius,
  });

  final Color primaryColor;
  final Color gradientColor;
  final Color backgroundColor;
  final double controlButtonSize;
  final double smallControlButtonSize;
  final double progressBarHeight;
  final double albumArtSize;
  final double albumArtBorderRadius;
  
  /// Gradiente para botones de control
  LinearGradient get controlGradient {
    return LinearGradient(
      colors: [gradientColor, primaryColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  /// Lista de iconos para controles de reproducción con FontAwesome
  static const Map<String, IconData> controlIcons = {
    'play': FontAwesomeIcons.solidPlay,
    'pause': FontAwesomeIcons.solidPause,
    'next': FontAwesomeIcons.solidForward,
    'previous': FontAwesomeIcons.solidBackward,
    'shuffle': FontAwesomeIcons.solidShuffle,
    'repeat': FontAwesomeIcons.solidRepeat,
    'heart': FontAwesomeIcons.solidHeart,
    'heartEmpty': FontAwesomeIcons.heart,
    'share': FontAwesomeIcons.solidShare,
    'download': FontAwesomeIcons.solidDownload,
    'more': FontAwesomeIcons.solidEllipsisVertical,
  };
}

/// Datos del tema para elementos de playlist
class PlaylistThemeData {
  const PlaylistThemeData({
    required this.primaryColor,
    required this.itemHeight,
    required this.itemBorderRadius,
    required this.selectedItemColor,
    required this.playingItemColor,
    required this.itemSpacing,
  });

  final Color primaryColor;
  final double itemHeight;
  final double itemBorderRadius;
  final Color selectedItemColor;
  final Color playingItemColor;
  final double itemSpacing;
  
  /// Iconos para elementos de playlist
  static const Map<String, IconData> playlistIcons = {
    'music': FontAwesomeIcons.solidMusic,
    'playing': FontAwesomeIcons.solidVolumeHigh,
    'paused': FontAwesomeIcons.solidVolumeXmark,
    'download': FontAwesomeIcons.solidDownload,
    'downloaded': FontAwesomeIcons.solidCheck,
    'favorite': FontAwesomeIcons.solidHeart,
    'favoriteEmpty': FontAwesomeIcons.heart,
  };
}

/// Datos del tema para cards de onboarding
class OnboardingThemeData {
  const OnboardingThemeData({
    required this.primaryColor,
    required this.gradientColor,
    required this.cardBorderRadius,
    required this.buttonBorderRadius,
    required this.indicatorSize,
    required this.spacing,
  });

  final Color primaryColor;
  final Color gradientColor;
  final double cardBorderRadius;
  final double buttonBorderRadius;
  final double indicatorSize;
  final double spacing;
  
  /// Gradiente para cards y botones
  LinearGradient get gradient {
    return LinearGradient(
      colors: [gradientColor, primaryColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

/// Datos del tema para formularios de autenticación
class AuthThemeData {
  const AuthThemeData({
    required this.primaryColor,
    required this.gradientColor,
    required this.inputBorderRadius,
    required this.buttonBorderRadius,
    required this.inputHeight,
    required this.buttonHeight,
    required this.formSpacing,
  });

  final Color primaryColor;
  final Color gradientColor;
  final double inputBorderRadius;
  final double buttonBorderRadius;
  final double inputHeight;
  final double buttonHeight;
  final double formSpacing;
  
  /// Gradiente para botones de autenticación
  LinearGradient get buttonGradient {
    return LinearGradient(
      colors: [gradientColor, primaryColor],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
  
  /// Iconos para formularios de autenticación
  static const Map<String, IconData> authIcons = {
    'email': FontAwesomeIcons.envelope,
    'password': FontAwesomeIcons.solidLock,
    'showPassword': FontAwesomeIcons.eye,
    'hidePassword': FontAwesomeIcons.eyeSlash,
    'user': FontAwesomeIcons.user,
    'phone': FontAwesomeIcons.solidPhone,
    'google': FontAwesomeIcons.google,
    'facebook': FontAwesomeIcons.facebookF,
    'apple': FontAwesomeIcons.apple,
    'success': FontAwesomeIcons.solidCircleCheck,
    'error': FontAwesomeIcons.solidCircleXmark,
  };
}

/// Widget helper para crear controles de reproductor consistentes
class MusicControls extends StatelessWidget {
  const MusicControls({
    required this.theme,
    required this.isPlaying,
    required this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.onShuffle,
    this.onRepeat,
    this.isShuffling = false,
    this.isRepeating = false,
    super.key,
  });

  final MusicPlayerThemeData theme;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onShuffle;
  final VoidCallback? onRepeat;
  final bool isShuffling;
  final bool isRepeating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle button
        IconButton(
          onPressed: onShuffle,
          icon: Icon(
            MusicPlayerThemeData.controlIcons['shuffle'],
            color: isShuffling 
                ? theme.primaryColor 
                : MusicColors.iconInactive,
          ),
        ),
        
        // Previous button
        IconButton(
          onPressed: onPrevious,
          icon: Icon(
            MusicPlayerThemeData.controlIcons['previous'],
            size: theme.smallControlButtonSize * 0.6,
            color: theme.primaryColor,
          ),
        ),
        
        // Play/Pause button (main control)
        Container(
          width: theme.controlButtonSize,
          height: theme.controlButtonSize,
          decoration: BoxDecoration(
            gradient: theme.controlGradient,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPlayPause,
            icon: Icon(
              isPlaying 
                  ? MusicPlayerThemeData.controlIcons['pause']
                  : MusicPlayerThemeData.controlIcons['play'],
              color: MusicColors.textOnGradient,
              size: theme.controlButtonSize * 0.4,
            ),
          ),
        ),
        
        // Next button
        IconButton(
          onPressed: onNext,
          icon: Icon(
            MusicPlayerThemeData.controlIcons['next'],
            size: theme.smallControlButtonSize * 0.6,
            color: theme.primaryColor,
          ),
        ),
        
        // Repeat button
        IconButton(
          onPressed: onRepeat,
          icon: Icon(
            MusicPlayerThemeData.controlIcons['repeat'],
            color: isRepeating 
                ? theme.primaryColor 
                : MusicColors.iconInactive,
          ),
        ),
      ],
    );
  }
}

/// Widget helper para elementos de playlist consistentes
class PlaylistItem extends StatelessWidget {
  const PlaylistItem({
    required this.theme,
    required this.title,
    required this.artist,
    required this.onTap,
    this.isPlaying = false,
    this.isSelected = false,
    this.isFavorite = false,
    this.duration,
    this.albumArt,
    super.key,
  });

  final PlaylistThemeData theme;
  final String title;
  final String artist;
  final VoidCallback onTap;
  final bool isPlaying;
  final bool isSelected;
  final bool isFavorite;
  final String? duration;
  final Widget? albumArt;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected 
        ? theme.selectedItemColor 
        : isPlaying 
            ? theme.playingItemColor.withValues(alpha: 0.1)
            : Colors.transparent;
            
    final textColor = isPlaying ? theme.playingItemColor : MusicColors.darkGrey;

    return Container(
      height: theme.itemHeight,
      margin: EdgeInsets.only(bottom: theme.itemSpacing),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(theme.itemBorderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(theme.itemBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Album art or music icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: MusicColors.subtleBorder,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: albumArt ?? Icon(
                    FontAwesomeIcons.solidMusic,
                    color: MusicColors.iconInactive,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        artist,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Duration and favorite
                Row(
                  children: [
                    if (duration != null) ...[
                      Text(
                        duration!,
                        style: TextStyle(
                          color: MusicColors.lightGrey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    // Playing indicator or favorite icon
                    Icon(
                      isPlaying
                          ? PlaylistThemeData.playlistIcons['playing']
                          : isFavorite
                              ? PlaylistThemeData.playlistIcons['favorite']
                              : null,
                      size: 16,
                      color: isPlaying ? theme.playingItemColor : theme.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}