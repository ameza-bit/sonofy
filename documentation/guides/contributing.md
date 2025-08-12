# Guía de Contribución

## 🤝 Bienvenido a Sonofy

Gracias por tu interés en contribuir a Sonofy. Esta guía te ayudará a entender cómo participar en el desarrollo del proyecto de manera efectiva y colaborativa.

## 📋 Tabla de Contenidos

- [Código de Conducta](#-código-de-conducta)
- [Cómo Contribuir](#-cómo-contribuir)
- [Configuración del Entorno](#-configuración-del-entorno)
- [Flujo de Trabajo](#-flujo-de-trabajo)
- [Estándares de Código](#-estándares-de-código)
- [Proceso de Review](#-proceso-de-review)
- [Tipos de Contribuciones](#-tipos-de-contribuciones)

## 🤝 Código de Conducta

### Nuestros Valores
- **Respeto**: Trata a todos los colaboradores con respeto y cortesía
- **Inclusión**: Damos la bienvenida a personas de todos los trasfondos
- **Colaboración**: Trabajamos juntos hacia objetivos comunes
- **Aprendizaje**: Fomentamos el crecimiento y aprendizaje mutuo

### Comportamiento Esperado
- Usar lenguaje inclusivo y profesional
- Respetar diferentes puntos de vista y experiencias
- Aceptar críticas constructivas de manera positiva
- Mostrar empatía hacia otros miembros de la comunidad

### Comportamiento Inaceptable
- Lenguaje o imágenes sexualizadas
- Trolling, insultos o comentarios despectivos
- Acoso público o privado
- Publicar información privada de otros sin permiso

## 🚀 Cómo Contribuir

### 1. Reportar Bugs
Antes de reportar un bug:
- Verifica que no esté ya reportado en los issues
- Reproduce el problema en la última versión
- Prepara información detallada

#### Template para Bug Reports
```markdown
**Descripción del Bug**
Descripción clara y concisa del problema.

**Pasos para Reproducir**
1. Ir a '...'
2. Hacer clic en '...'
3. Desplazarse hasta '...'
4. Ver error

**Comportamiento Esperado**
Qué esperabas que pasara.

**Comportamiento Actual**
Qué está pasando en realidad.

**Screenshots**
Si aplica, agregar screenshots.

**Información del Entorno:**
 - OS: [e.g. iOS 16, Android 13]
 - Dispositivo: [e.g. iPhone 14, Samsung Galaxy S22]
 - Versión de Flutter: [e.g. 3.8.1]
 - Versión de la App: [e.g. 0.1.0]

**Información Adicional**
Cualquier otro contexto sobre el problema.
```

### 2. Solicitar Features
#### Template para Feature Requests
```markdown
**¿Tu feature request está relacionado con un problema?**
Descripción clara del problema. Ej: "Me frustra que..."

**Describe la solución que te gustaría**
Descripción clara y concisa de lo que quieres que pase.

**Describe alternativas que has considerado**
Descripción de soluciones o features alternativas.

**Información Adicional**
Cualquier otro contexto o screenshots sobre el feature request.
```

### 3. Contribuir con Código
1. Fork el repositorio
2. Crear branch para tu feature
3. Hacer cambios siguiendo estándares
4. Escribir tests apropiados
5. Enviar Pull Request

## ⚙️ Configuración del Entorno

### Requisitos Previos
- Flutter SDK 3.8.1+
- Dart SDK (incluido con Flutter)
- Git
- IDE preferido (VS Code, Android Studio)

### Configuración Inicial
```bash
# 1. Fork y clonar el repositorio
git clone https://github.com/tu-usuario/sonofy.git
cd sonofy

# 2. Configurar upstream
git remote add upstream https://github.com/original-repo/sonofy.git

# 3. Instalar dependencias
flutter pub get

# 4. Verificar configuración
flutter doctor

# 5. Ejecutar tests
flutter test

# 6. Ejecutar la app
flutter run
```

## 🔄 Flujo de Trabajo

### Branch Strategy
```
main
├── develop
├── feature/nueva-funcionalidad
├── bugfix/corregir-problema
├── hotfix/arreglo-urgente
└── release/v0.2.0
```

### Nomenclatura de Branches
- `feature/descripcion-breve` - Nuevas funcionalidades
- `bugfix/descripcion-del-bug` - Corrección de bugs
- `hotfix/arreglo-critico` - Arreglos urgentes
- `refactor/area-refactorizada` - Refactoring
- `docs/documentacion-actualizada` - Documentación

### Flujo de Trabajo Típico
```bash
# 1. Actualizar develop
git checkout develop
git pull upstream develop

# 2. Crear branch para feature
git checkout -b feature/nueva-funcionalidad

# 3. Hacer cambios
# ... desarrollar ...

# 4. Commit frecuentes
git add .
git commit -m "feat: agregar funcionalidad X"

# 5. Push a tu fork
git push origin feature/nueva-funcionalidad

# 6. Crear Pull Request en GitHub
```

## 📝 Estándares de Código

### Estilo de Código
```dart
// ✅ Correcto
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text('Player')),
          body: PlayerContent(song: state.currentSong),
        );
      },
    );
  }
}

// ❌ Incorrecto
class playerscreen extends StatelessWidget{
  @override
  Widget build(context){
    return Container();
  }
}
```

### Convenciones de Nomenclatura
- **Clases**: PascalCase (`PlayerScreen`, `SongCard`)
- **Archivos**: snake_case (`player_screen.dart`)
- **Variables**: camelCase (`currentSong`, `isPlaying`)
- **Constantes**: UPPER_SNAKE_CASE (`MAX_VOLUME`)
- **Privadas**: prefijo `_` (`_playerRepository`)

### Estructura de Archivos
```dart
// Orden de imports
import 'dart:...';          // SDK de Dart
import 'package:flutter/...'; // Flutter framework
import 'package:other/...';   // Packages externos
import 'package:sonofy/...';  // Imports internos

// Orden de elementos en clase
class ExampleWidget extends StatelessWidget {
  // 1. Propiedades estáticas
  static const String routeName = 'example';
  
  // 2. Propiedades de instancia
  final String title;
  final VoidCallback? onPressed;
  
  // 3. Constructor
  const ExampleWidget({
    super.key,
    required this.title,
    this.onPressed,
  });
  
  // 4. Métodos override
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // 5. Métodos privados
  void _handlePress() {
    // ...
  }
}
```

### Documentación de Código
```dart
/// Widget que muestra información de una canción.
///
/// Incluye título, artista, duración y carátula del álbum.
/// Permite reproducir la canción al hacer tap.
class SongCard extends StatelessWidget {
  /// La canción a mostrar
  final SongModel song;
  
  /// Callback ejecutado al seleccionar la canción
  final ValueChanged<SongModel>? onTap;
  
  /// Crea un [SongCard] con la [song] especificada.
  const SongCard({
    super.key,
    required this.song,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    // Implementación...
  }
}
```

### Testing
```dart
// Estructura de tests
group('PlayerCubit Tests', () {
  late MockPlayerRepository mockPlayerRepository;
  late PlayerCubit playerCubit;

  setUp(() {
    mockPlayerRepository = MockPlayerRepository();
    playerCubit = PlayerCubit(mockPlayerRepository);
  });

  tearDown(() {
    playerCubit.close();
  });

  group('setPlayingSong', () {
    test('should emit playing state when song is set', () async {
      // Arrange
      when(() => mockPlayerRepository.play(any()))
          .thenAnswer((_) async => true);

      // Act
      await playerCubit.setPlayingSong([mockSong], mockSong);

      // Assert
      expect(playerCubit.state.isPlaying, true);
      expect(playerCubit.state.currentSong, mockSong);
    });
  });
});
```

## 📏 Convenciones de Commits

### Formato de Commits
Usamos [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>[ámbito opcional]: <descripción>

[cuerpo opcional]

[pie opcional]
```

### Tipos de Commits
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Cambios de formato (sin afectar lógica)
- `refactor`: Refactoring de código
- `test`: Agregar o modificar tests
- `chore`: Mantenimiento (deps, build, etc.)

### Ejemplos
```bash
# Feature nueva
git commit -m "feat(player): agregar control de volumen"

# Bug fix
git commit -m "fix(library): corregir carga de canciones en Android"

# Documentación
git commit -m "docs: actualizar guía de contribución"

# Refactoring
git commit -m "refactor(core): extraer utilidades de tema a archivos separados"

# Test
git commit -m "test(player): agregar tests para PlayerCubit"
```

## 🔍 Proceso de Review

### Checklist para Pull Requests
- [ ] El código sigue las convenciones del proyecto
- [ ] Los tests pasan (`flutter test`)
- [ ] El análisis estático pasa (`flutter analyze`)
- [ ] La documentación está actualizada
- [ ] Los cambios están probados en dispositivo/emulador
- [ ] El PR tiene descripción clara
- [ ] Se agregaron tests para nueva funcionalidad

### Template de Pull Request
```markdown
## Descripción
Breve descripción de los cambios realizados.

## Tipo de Cambio
- [ ] Bug fix (cambio que corrige un problema)
- [ ] Nueva feature (cambio que agrega funcionalidad)
- [ ] Breaking change (arreglo o feature que causaría que funcionalidad existente no funcione como esperado)
- [ ] Cambio de documentación

## ¿Cómo se ha probado?
Describe las pruebas que ejecutaste para verificar tus cambios.

## Checklist:
- [ ] Mi código sigue las convenciones del proyecto
- [ ] He realizado una auto-review de mi código
- [ ] He comentado mi código, particularmente en áreas difíciles de entender
- [ ] He realizado cambios correspondientes a la documentación
- [ ] Mis cambios no generan nuevas advertencias
- [ ] He agregado tests que prueban que mi fix es efectivo o que mi feature funciona
- [ ] Tests unitarios nuevos y existentes pasan localmente

## Screenshots (si aplica)
Agregar screenshots para mostrar los cambios visuales.
```

### Proceso de Review
1. **Automated Checks**: CI/CD ejecuta tests y análisis
2. **Code Review**: Al menos un reviewer aprueba
3. **Testing**: Verificar en diferentes dispositivos
4. **Merge**: Squash merge a develop/main

## 🎯 Tipos de Contribuciones

### 🐛 Bug Fixes
- Corregir funcionalidad existente
- Mejorar estabilidad
- Optimizar rendimiento

### ✨ Nuevas Features
- Funcionalidades de reproductor
- Mejoras de UI/UX
- Nuevas pantallas o workflows

### 📚 Documentación
- Actualizar README
- Documentar APIs
- Guías de usuario
- Comentarios en código

### 🧪 Testing
- Tests unitarios
- Tests de integración
- Tests de UI
- Mejora de coverage

### 🎨 Diseño y UI
- Mejoras visuales
- Accesibilidad
- Responsive design
- Nuevos componentes

### 🔧 DevOps y Tooling
- Configuración de CI/CD
- Scripts de build
- Herramientas de desarrollo
- Automatización

## 📊 Guidelines para Diferentes Áreas

### Frontend/UI
- Seguir Material Design guidelines
- Implementar diseño responsivo
- Considerar accesibilidad
- Optimizar para diferentes tamaños de pantalla

### Estado y Lógica de Negocio
- Usar BLoC pattern consistentemente
- Mantener estados inmutables
- Implementar manejo de errores
- Agregar logging apropiado

### API y Datos
- Implementar Repository pattern
- Manejar errores de red gracefully
- Implementar caching cuando sea apropiado
- Validar datos de entrada

### Performance
- Minimizar rebuilds innecesarios
- Optimizar lists largas
- Lazy loading cuando sea apropiado
- Profiling regular

## 🎉 Reconocimiento

### Contributors
Mantenemos una lista de contribuidores en el README principal.

### First-time Contributors
¡Damos la bienvenida especial a nuevos contribuidores! Busca issues etiquetados con `good first issue`.

### Tipos de Reconocimiento
- Mención en release notes
- Añadir a contributors list
- Shout-out en redes sociales (si aplica)

## 📞 Obtener Ayuda

### Canales de Comunicación
- **GitHub Issues**: Para bugs y feature requests
- **GitHub Discussions**: Para preguntas generales
- **Code Reviews**: Para feedback específico de código

### Contacto
- Crear issue en GitHub para preguntas técnicas
- Revisar documentación existente primero
- Ser específico y proporcionar contexto

## 🔄 Versionado

Seguimos [Semantic Versioning](https://semver.org/):
- `MAJOR`: Cambios incompatibles de API
- `MINOR`: Funcionalidad nueva compatible hacia atrás
- `PATCH`: Bug fixes compatibles hacia atrás

## 📅 Release Cycle

- **Develop**: Desarrollo continuo
- **Release Candidates**: Testing antes de release
- **Stable Releases**: Cada 2-4 semanas
- **Hotfixes**: Según necesidad

¡Gracias por contribuir a Sonofy! Tu participación hace que el proyecto sea mejor para todos. 🎵