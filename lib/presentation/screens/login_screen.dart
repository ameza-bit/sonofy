import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/themes/gradient_helpers.dart';
import 'package:sonofy/core/themes/music_theme.dart';
import 'package:sonofy/presentation/screens/settings_screen.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = 'login';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final authTheme = MusicTheme.authTheme(primaryColor);
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.musicBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Sonofy',
            style: TextStyle(
              color: context.musicDarkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.lightGear,
                color: context.musicMediumGrey,
              ),
              onPressed: () {
                context.pushNamed(SettingsScreen.routeName);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header con gradiente
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: context.musicGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.solidMusic,
                      size: 48,
                      color: context.musicTextOnGradient,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to ${context.tr("app.title")}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: context.musicTextOnGradient,
                      ),
                    ),
                    Text(
                      'Find Music & Enjoy',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.musicTextOnGradient.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Formulario de login
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.musicSurface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: context.musicCardShadow,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.musicDarkGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Campo de email
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            AuthThemeData.authIcons['email'],
                            color: context.musicMediumGrey,
                          ),
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: context.musicLightGrey),
                          filled: true,
                          fillColor: context.musicBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(authTheme.inputBorderRadius),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(authTheme.inputBorderRadius),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: TextStyle(color: context.musicDarkGrey),
                      ),

                      const SizedBox(height: 16),

                      // Campo de password
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            AuthThemeData.authIcons['password'],
                            color: context.musicMediumGrey,
                          ),
                          suffixIcon: Icon(
                            AuthThemeData.authIcons['hidePassword'],
                            color: context.musicMediumGrey,
                          ),
                          hintText: 'Create your password',
                          hintStyle: TextStyle(color: context.musicLightGrey),
                          filled: true,
                          fillColor: context.musicBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(authTheme.inputBorderRadius),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(authTheme.inputBorderRadius),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: TextStyle(color: context.musicDarkGrey),
                      ),

                      const SizedBox(height: 24),

                      // Botón Sign In con gradiente
                      GradientButton(
                        primaryColor: primaryColor,
                        borderRadius: authTheme.buttonBorderRadius,
                        padding: EdgeInsets.symmetric(
                          vertical: authTheme.buttonHeight / 3.5,
                        ),
                        onPressed: () {
                          // TODO(developer): Implementar login
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login functionality coming soon!'),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AuthThemeData.authIcons['success'],
                              color: context.musicTextOnGradient,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Forgot password
                      TextButton(
                        onPressed: () {
                          // TODO(developer): Implementar forgot password
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(color: context.musicSubtleBorder),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(
                          color: context.musicMediumGrey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: context.musicSubtleBorder),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Social buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Google
                    _buildSocialButton(
                      context,
                      AuthThemeData.authIcons['google']!,
                      'Google',
                      () {},
                    ),
                    // Facebook
                    _buildSocialButton(
                      context,
                      AuthThemeData.authIcons['facebook']!,
                      'Facebook',
                      () {},
                    ),
                    // Apple
                    _buildSocialButton(
                      context,
                      AuthThemeData.authIcons['apple']!,
                      'Apple',
                      () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Sign Up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: context.musicMediumGrey),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO(developer): Navegar a Sign Up
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 80,
      height: 56,
      decoration: BoxDecoration(
        color: context.musicSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.musicSubtleBorder),
        boxShadow: [
          BoxShadow(
            color: context.musicCardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: context.musicDarkGrey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: context.musicMediumGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
