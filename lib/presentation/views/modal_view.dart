import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

void modalView(
  BuildContext context, {
  required String title,
  required List<Widget> children,
  double? maxHeight = 0.65,
}) => showModalBottomSheet(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  backgroundColor: context.musicBackground,
  constraints: BoxConstraints(
    maxHeight: MediaQuery.of(context).size.height * maxHeight!,
    maxWidth: MediaQuery.of(context).size.width,
    minHeight: MediaQuery.of(context).size.height * 0.25,
    minWidth: MediaQuery.of(context).size.width,
  ),
  builder: (_) => BlocBuilder<SettingsCubit, SettingsState>(
    builder: (context, state) {
      final primaryColor = state.settings.primaryColor;

      return Scaffold(
        backgroundColor: context.musicBackground,
        body: SafeArea(
          child: Hero(
            tag: 'delete_playlist_container',
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 24,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: context.scaleText(12)),
                          ),
                          Icon(
                            FontAwesomeIcons.lightChevronDown,
                            color: primaryColor,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  ),
);
