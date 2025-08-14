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
                          const Divider(),
                          Row(
                            spacing: 16,
                            children: [
                              Expanded(
                                child: Text(
                                  context.tr('player.sleep.wait_description'),
                                  style: TextStyle(
                                    fontSize: context.scaleText(16),
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              Checkbox(
                                value: playerState.waitForSongToFinish,
                                onChanged: (value) => context
                                    .read<PlayerCubit>()
                                    .toggleWaitForSongToFinish(),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.bottomSheetHeight),
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
      return _buildTimerOptions(context, primaryColor);
    }
  }

  Widget _buildActiveTimer(
    BuildContext context,
    PlayerState playerState,
    Color primaryColor,
  ) {
    final remaining = playerState.sleepTimerRemaining;
    if (remaining == null) return const SizedBox();

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
      ],
    );
  }

  Widget _buildTimerOptions(BuildContext context, Color primaryColor) {
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
    int selectedMinutes = 60;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.tr('player.sleep.custom_duration')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.tr('player.sleep.select_minutes')),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: selectedMinutes > 1
                        ? () => setState(() => selectedMinutes--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$selectedMinutes ${context.tr('player.sleep.minutes')}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: selectedMinutes < 180
                        ? () => setState(() => selectedMinutes++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
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
                  Duration(minutes: selectedMinutes),
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
