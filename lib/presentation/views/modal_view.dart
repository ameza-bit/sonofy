import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/bottom_player.dart';

void modalView(
  BuildContext context, {
  required String title,
  required List<Widget> children,
  double? maxHeight = 0.65,
  bool showPlayer = false,
  bool isScrollable = false,
}) => showModalBottomSheet(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (_) => BlocBuilder<SettingsCubit, SettingsState>(
    builder: (context, state) {
      final primaryColor = state.settings.primaryColor;
      final screenHeight = MediaQuery.of(context).size.height;
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        constraints: BoxConstraints(
          maxHeight: screenHeight * maxHeight!,
          maxWidth: MediaQuery.of(context).size.width,
          minHeight: screenHeight * 0.25,
          minWidth: MediaQuery.of(context).size.width,
        ),
        margin: EdgeInsets.only(bottom: keyboardHeight),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Hero(
              tag: 'modal_container',
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
                      const SizedBox(height: 24),
                      Expanded(
                        child: isScrollable
                            ? SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: children,
                                ),
                              )
                            : Column(children: children),
                      ),
                      if (showPlayer) const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomSheet: showPlayer
              ? BottomPlayer(onTap: () => context.pop())
              : null,
        ),
      );
    },
  ),
);
