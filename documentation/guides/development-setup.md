# Guía de Configuración de Desarrollo

## 🚀 Requisitos Previos

### Software Requerido

#### Flutter SDK
- **Versión**: 3.8.1 o superior
- **Canal**: Stable recomendado
- **Instalación**: [Guía oficial de Flutter](https://docs.flutter.dev/get-started/install)

#### Dart SDK
- **Versión**: Incluido con Flutter SDK
- **Verificación**: `dart --version`

#### IDE Recomendados
- **VS Code** con extensiones de Flutter/Dart
- **Android Studio** con plugins de Flutter
- **IntelliJ IDEA** con plugins de Flutter

### Herramientas de Desarrollo

#### Git
```bash
# Verificar instalación
git --version

# Configuración inicial (si es primera vez)
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

#### Dependencias del Sistema

**macOS**:
```bash
# Xcode Command Line Tools
xcode-select --install

# CocoaPods
sudo gem install cocoapods
```

**Windows**:
- Visual Studio 2019/2022 con C++ tools
- Git for Windows

**Linux**:
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install curl git unzip xz-utils zip libglu1-mesa

# Fedora/RHEL
sudo dnf install curl git unzip xz zip
```

## 📱 Configuración de Plataformas

### Android

#### Android Studio
1. **Instalación**: Descargar desde [developer.android.com](https://developer.android.com/studio)
2. **SDK Configuration**:
   - API Level 21 (Android 5.0) mínimo
   - API Level 34 (Android 14) recomendado
   - Android SDK Build-Tools
   - Android SDK Platform-Tools

#### Variables de Entorno
```bash
# Agregar a ~/.bashrc, ~/.zshrc, o equivalente
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

#### Dispositivo/Emulador
```bash
# Listar dispositivos conectados
adb devices

# Crear emulador (opcional)
flutter emulators --create --name pixel_6
```

### iOS (Solo macOS)

#### Xcode
1. **Instalación**: Desde Mac App Store
2. **Versión**: 14.0 o superior
3. **Configuración**:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

#### CocoaPods
```bash
# Verificar instalación
pod --version

# Actualizar si es necesario
sudo gem install cocoapods
```

#### Simulador iOS
```bash
# Listar simuladores disponibles
xcrun simctl list devices

# Abrir simulador
open -a Simulator
```

### Desktop (Opcional)

#### Windows
- Visual Studio 2022 con C++ CMake tools

#### macOS
- Xcode ya configurado

#### Linux
```bash
# Dependencias adicionales para Linux desktop
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

## 🔧 Configuración del Proyecto

### 1. Clonar el Repositorio
```bash
git clone <repository-url>
cd sonofy
```

### 2. Verificar Configuración de Flutter
```bash
# Verificar instalación y configuración
flutter doctor

# Resultado esperado: ✓ en todas las plataformas que planeas usar
```

### 3. Obtener Dependencias
```bash
# Instalar dependencias de Flutter
flutter pub get

# Para iOS (solo macOS)
cd ios && pod install && cd ..
```

### 4. Configurar Archivos de Entorno

#### Android Signing (Opcional para desarrollo)
```bash
# Crear keystore para debugging (opcional)
keytool -genkey -v -keystore debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000
```

#### iOS Team ID (Para dispositivos físicos)
```bash
# En ios/Runner.xcodeproj, configurar:
# - Development Team
# - Bundle Identifier único
```

## 🏃‍♂️ Ejecutar la Aplicación

### Comandos Básicos
```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <device-id>

# Ejecutar en modo debug (por defecto)
flutter run

# Ejecutar en modo profile (para análisis de rendimiento)
flutter run --profile

# Ejecutar en modo release
flutter run --release
```

### Atajos Durante Desarrollo
- `r` - Hot reload
- `R` - Hot restart
- `p` - Toggle widget inspector
- `q` - Quit

### Ejecutar en Plataformas Específicas
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Chrome (web)
flutter run -d chrome

# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

## 🧪 Testing y Calidad de Código

### Ejecutar Tests
```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/

# Tests con coverage
flutter test --coverage

# Ver reporte de coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Análisis de Código
```bash
# Análisis estático
flutter analyze

# Formatear código
flutter format .

# Verificar formato
flutter format --set-exit-if-changed .
```

### Linting
```bash
# El proyecto usa flutter_lints
# Configuración en analysis_options.yaml

# Verificar reglas de lint
flutter analyze --no-fatal-infos
```

## 🔍 Debugging

### Debug en IDE

#### VS Code
1. Instalar extensión Flutter
2. Usar `F5` o "Run > Start Debugging"
3. Configurar breakpoints con `F9`

#### Android Studio
1. Usar botón "Debug" 
2. Configurar breakpoints haciendo clic en margen izquierdo
3. Inspector de widgets disponible

### Flutter Inspector
```bash
# Abrir inspector web
flutter run --web-renderer html

# En navegador, abrir:
# http://localhost:port/?dart_devtools=true
```

### Logging
```dart
// En el código, usar:
import 'dart:developer' as developer;

developer.log('Mensaje de debug', name: 'sonofy.player');
debugPrint('Mensaje de desarrollo');
```

### Performance Profiling
```bash
# Ejecutar con profiling
flutter run --profile

# Abrir DevTools
dart devtools
```

## 📦 Build y Deployment

### Android APK
```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build app bundle (recomendado para Play Store)
flutter build appbundle --release
```

### iOS IPA
```bash
# Build para simulador
flutter build ios --simulator

# Build para dispositivo
flutter build ios --release

# Crear archivo IPA
flutter build ipa
```

### Web
```bash
# Build para web
flutter build web

# Con renderer específico
flutter build web --web-renderer canvaskit
flutter build web --web-renderer html
```

### Desktop
```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## 🛠️ Herramientas de Desarrollo Adicionales

### Extensiones de VS Code Recomendadas
```json
{
  "recommendations": [
    "Dart-Code.flutter",
    "Dart-Code.dart-code",
    "ms-vscode.vscode-json",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-typescript-next"
  ]
}
```

### Configuración de VS Code
```json
// .vscode/settings.json
{
  "dart.debugExternalPackageLibraries": true,
  "dart.debugSdkLibraries": false,
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "editor.rulers": [80],
  "editor.tabSize": 2,
  "files.associations": {
    "*.dart": "dart"
  }
}
```

### Git Hooks (Opcional)
```bash
# Instalar pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
flutter analyze
flutter test
EOF

chmod +x .git/hooks/pre-commit
```

## 🔧 Solución de Problemas Comunes

### Flutter Doctor Issues

#### Android License Issues
```bash
flutter doctor --android-licenses
# Aceptar todas las licencias
```

#### iOS Development Issues
```bash
# Reinstalar herramientas de Xcode
sudo xcode-select --install

# Limpiar caché de CocoaPods
cd ios
rm -rf Pods Podfile.lock
pod install
```

### Problemas de Dependencias
```bash
# Limpiar y reinstalar dependencias
flutter clean
flutter pub get

# Para iOS
cd ios && pod deintegrate && pod install
```

### Problemas de Performance
```bash
# Limpiar build cache
flutter clean

# Rebuild completo
flutter pub get
flutter run
```

### Problemas con Hot Reload
```bash
# Hot restart en lugar de hot reload
# Presionar 'R' en terminal o usar comando
flutter run --hot
```

## 📝 Configuración del Entorno de Desarrollo

### Variables de Entorno
```bash
# .env file (si se usa)
FLUTTER_ENV=development
DEBUG_MODE=true
LOG_LEVEL=debug
```

### Configuración de IDE
```yaml
# .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Sonofy Debug",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--flavor",
        "development"
      ]
    }
  ]
}
```

## 🎯 Próximos Pasos

1. **Familiarizarse con el código**: Revisar `lib/main.dart` y estructura de carpetas
2. **Revisar documentación**: Leer `/documentation/` para entender arquitectura
3. **Configurar herramientas**: Instalar extensiones recomendadas
4. **Hacer primer cambio**: Pequeña modificación para verificar workflow
5. **Ejecutar tests**: Asegurar que todo funciona correctamente

## 🆘 Soporte

### Recursos Oficiales
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Codelabs](https://docs.flutter.dev/codelabs)

### Documentación del Proyecto
- [Arquitectura](../architecture/)
- [API Documentation](../api/)
- [Componentes](../components/)

### Obtener Ayuda
1. Revisar esta documentación
2. Consultar issues conocidos en el repositorio
3. Crear issue para problemas nuevos
4. Consultar con el equipo de desarrollo

¡Feliz coding! 🎉