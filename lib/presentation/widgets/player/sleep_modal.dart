import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/constants/app_constants.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/bottom_player.dart';

class SleepModal extends StatelessWidget {
  const SleepModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: context.musicBackground,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height * 0.25,
        minWidth: MediaQuery.of(context).size.width,
      ),
      builder: (context) => const SleepModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final primaryColor = settingsState.settings.primaryColor;

        return BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, playerState) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Hero(
                  tag: 'sleep_container',
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.tr('player.sleep.title'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: context.scaleText(12),
                                  ),
                                ),
                                Icon(
                                  FontAwesomeIcons.lightChevronDown,
                                  color: primaryColor,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _buildSleepContent(
                              context,
                              playerState,
                              primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              resizeToAvoidBottomInset: false,
              bottomSheet: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      color: Theme.of(context).cardColor,
                    ),
                  ),
                  BottomPlayer(onTap: () => context.pop()),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSleepContent(
    BuildContext context,
    PlayerState playerState,
    Color primaryColor,
  ) {
    if (playerState.isSleepTimerActive) {
      return _buildActiveTimer(context, playerState, primaryColor);
    } else {
      return _buildTimerOptions(context, playerState, primaryColor);
    }
  }

  Widget _buildActiveTimer(
    BuildContext context,
    PlayerState playerState,
    Color primaryColor,
  ) {
    final remaining = playerState.sleepTimerRemaining;
    if (remaining == null) return const SizedBox();

    final isWaitingForSongEnd =
        remaining == Duration.zero && playerState.waitForSongToFinish;

    if (isWaitingForSongEnd) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.lightHourglass, size: 64, color: primaryColor),
          const SizedBox(height: 24),
          Text(
            context.tr('player.sleep.waiting_for_song_end'),
            style: TextStyle(
              fontSize: context.scaleText(18),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('player.sleep.will_pause_after_song'),
            style: TextStyle(
              fontSize: context.scaleText(14),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.read<PlayerCubit>().stopSleepTimer(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(context.tr('player.sleep.cancel_timer')),
          ),
          const SizedBox(height: 32),
        ],
      );
    }

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(FontAwesomeIcons.lightClock, size: 64, color: primaryColor),
        const SizedBox(height: 24),
        Text(
          context.tr('player.sleep.timer_active'),
          style: TextStyle(
            fontSize: context.scaleText(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: context.scaleText(48),
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => context.read<PlayerCubit>().stopSleepTimer(),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text(context.tr('player.sleep.cancel_timer')),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildWaitForSongTile(
    BuildContext context,
    PlayerState playerState,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(FontAwesomeIcons.lightMusic, color: primaryColor),
        title: Text(
          context.tr('player.sleep.wait_description'),
          style: TextStyle(fontSize: context.scaleText(16)),
        ),
        trailing: Checkbox(
          value: playerState.waitForSongToFinish,
          onChanged: (_) =>
              context.read<PlayerCubit>().toggleWaitForSongToFinish(),
        ),
        onTap: () => context.read<PlayerCubit>().toggleWaitForSongToFinish(),
        tileColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTimerOptions(
    BuildContext context,
    PlayerState playerState,
    Color primaryColor,
  ) {
    final durations = [
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(minutes: 45),
      const Duration(hours: 1),
    ];

    return ListView(
      children: [
        const SizedBox(height: 24),
        Text(
          context.tr('player.sleep.select_duration'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.scaleText(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        ...durations.map(
          (duration) => _buildDurationTile(
            context,
            duration,
            _formatDuration(context, duration),
            primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildCustomDurationTile(context, primaryColor),
        const SizedBox(height: 16),
        const Divider(),
        _buildWaitForSongTile(context, playerState, primaryColor),
        const SizedBox(height: AppSpacing.bottomSheetHeight),
      ],
    );
  }

  Widget _buildDurationTile(
    BuildContext context,
    Duration duration,
    String label,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(FontAwesomeIcons.lightClock, color: primaryColor),
        title: Text(label, style: TextStyle(fontSize: context.scaleText(16))),
        onTap: () {
          context.read<PlayerCubit>().startSleepTimer(
            duration,
            context.read<PlayerCubit>().state.waitForSongToFinish,
          );
        },
        tileColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCustomDurationTile(BuildContext context, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(FontAwesomeIcons.lightPenToSquare, color: primaryColor),
        title: Text(
          context.tr('player.sleep.custom_duration'),
          style: TextStyle(fontSize: context.scaleText(16)),
        ),
        onTap: () => _showCustomDurationDialog(context, primaryColor),
        tileColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showCustomDurationDialog(BuildContext context, Color primaryColor) {
    double selectedMinutes = 60.0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.tr('player.sleep.custom_duration')),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.tr('player.sleep.select_minutes')),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedMinutes.round()} ${context.tr('player.sleep.minutes')}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: primaryColor.withValues(alpha: 0.3),
                    thumbColor: primaryColor,
                    overlayColor: primaryColor.withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                    trackHeight: 4,
                    valueIndicatorColor: primaryColor,
                    valueIndicatorTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Slider(
                    value: selectedMinutes,
                    min: 1.0,
                    max: 180.0,
                    divisions: 179,
                    label: '${selectedMinutes.round()} min',
                    onChanged: (value) {
                      setState(() => selectedMinutes = value);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1 min',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '180 min',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickButton(
                      context,
                      setState,
                      15,
                      selectedMinutes,
                      primaryColor,
                      (value) => selectedMinutes = value,
                    ),
                    _buildQuickButton(
                      context,
                      setState,
                      30,
                      selectedMinutes,
                      primaryColor,
                      (value) => selectedMinutes = value,
                    ),
                    _buildQuickButton(
                      context,
                      setState,
                      60,
                      selectedMinutes,
                      primaryColor,
                      (value) => selectedMinutes = value,
                    ),
                    _buildQuickButton(
                      context,
                      setState,
                      90,
                      selectedMinutes,
                      primaryColor,
                      (value) => selectedMinutes = value,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.tr('common.cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<PlayerCubit>().startSleepTimer(
                  Duration(minutes: selectedMinutes.round()),
                  context.read<PlayerCubit>().state.waitForSongToFinish,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text(
                context.tr('player.sleep.start_timer'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context,
    StateSetter setState,
    int minutes,
    double currentValue,
    Color primaryColor,
    Function(double) onChanged,
  ) {
    final isSelected = currentValue.round() == minutes;
    return GestureDetector(
      onTap: () {
        setState(() => onChanged(minutes.toDouble()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor, width: isSelected ? 2 : 1),
        ),
        child: Text(
          '${minutes}m',
          style: TextStyle(
            color: isSelected ? Colors.white : primaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _formatDuration(BuildContext context, Duration duration) {
    if (duration.inHours > 0) {
      return context.tr(
        'player.sleep.duration_hours',
        args: [duration.inHours.toString()],
      );
    } else {
      return context.tr(
        'player.sleep.duration_minutes',
        args: [duration.inMinutes.toString()],
      );
    }
  }
}
