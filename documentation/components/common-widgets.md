# Widgets Comunes

## 📖 Visión General

Los widgets comunes de Sonofy son componentes reutilizables que proporcionan consistencia visual y funcional a través de toda la aplicación. Están diseñados siguiendo principios de Material Design y las convenciones del sistema de temas de la aplicación.

## 🎛️ Botones

### PrimaryButton

#### Propósito
Botón principal de la aplicación para acciones importantes y llamadas a la acción.

#### Ubicación
`lib/presentation/widgets/common/primary_button.dart`

#### Características
- **Diseño consistente**: Sigue el tema de la aplicación
- **Estados visuales**: Normal, pressed, disabled
- **Iconos opcionales**: Soporte para iconos junto al texto
- **Adaptativo**: Se adapta al color primario configurado

#### Implementación
```dart
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.padding,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 24, 
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? _buildLoadingContent()
            : _buildNormalContent(),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildNormalContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    return Text(text);
  }
}
```

#### Uso
```dart
// Botón básico
PrimaryButton(
  text: 'Reproducir Todo',
  onPressed: () => _playAllSongs(),
)

// Botón con icono
PrimaryButton(
  text: 'Agregar a Playlist',
  icon: Icons.add,
  onPressed: () => _addToPlaylist(),
)

// Botón en estado de carga
PrimaryButton(
  text: 'Guardando...',
  isLoading: true,
  onPressed: null,
)
```

### SecondaryButton

#### Propósito
Botón secundario para acciones menos prominentes o alternativas.

#### Ubicación
`lib/presentation/widgets/common/secundary_button.dart`

#### Características
- **Estilo outline**: Borde con fondo transparente
- **Menor prominencia**: Para acciones secundarias
- **Consistencia temática**: Usa colores del tema actual

#### Implementación
```dart
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.padding,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 24, 
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(text),
                ],
              )
            : Text(text),
      ),
    );
  }
}
```

## 📝 Campos de Texto

### CustomTextField

#### Propósito
Campo de texto personalizado que sigue el diseño de la aplicación para formularios y entrada de datos.

#### Ubicación
`lib/presentation/widgets/common/custom_text_field.dart`

#### Características
- **Diseño consistente**: Estilo unificado en toda la app
- **Validación integrada**: Soporte para validadores
- **Estados visuales**: Normal, focus, error
- **Iconos y prefijos**: Soporte para iconos y texto adicional

#### Implementación
```dart
class CustomTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.controller,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      validator: widget.validator,
      onChanged: widget.onChanged,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon != null 
            ? Icon(widget.prefixIcon) 
            : null,
        suffixIcon: widget.suffixIcon,
        border: _buildBorder(context, false),
        enabledBorder: _buildBorder(context, false),
        focusedBorder: _buildBorder(context, true),
        errorBorder: _buildErrorBorder(context),
        focusedErrorBorder: _buildErrorBorder(context),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: 12,
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder(BuildContext context, bool focused) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: focused 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
        width: focused ? 2 : 1,
      ),
    );
  }

  OutlineInputBorder _buildErrorBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 2,
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }
}
```

#### Uso
```dart
// Campo básico
CustomTextField(
  labelText: 'Nombre de Playlist',
  hintText: 'Mi playlist favorita',
  controller: _playlistNameController,
)

// Campo con validación
CustomTextField(
  labelText: 'Nombre de Usuario',
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'Este campo es requerido';
    }
    return null;
  },
)

// Campo de búsqueda
CustomTextField(
  hintText: 'Buscar canciones...',
  prefixIcon: Icons.search,
  onChanged: (value) => _performSearch(value),
)
```

## 📑 Tarjetas y Secciones

### SectionCard

#### Propósito
Contenedor para agrupar elementos relacionados en las pantallas de configuración.

#### Ubicación
`lib/presentation/widgets/common/section_card.dart`

#### Características
- **Agrupación visual**: Organiza elementos relacionados
- **Título e icono**: Identificación clara de la sección
- **Lista de children**: Contenido flexible
- **Diseño consistente**: Elevación y bordes redondeados

#### Implementación
```dart
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
```

### SectionItem

#### Propósito
Elemento individual dentro de una SectionCard para configuraciones o navegación.

#### Ubicación
`lib/presentation/widgets/common/section_item.dart`

#### Características
- **Layout consistente**: Título, subtítulo opcional, trailing widget
- **Interacción**: Tap handlers para navegación
- **Estados visuales**: Hover y pressed states
- **Flexibilidad**: Trailing personalizable

#### Implementación
```dart
class SectionItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  final bool enabled;

  const SectionItem({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.leadingIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: 20,
                color: enabled 
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).disabledColor,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: enabled 
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### Uso
```dart
// Item básico con navegación
SectionItem(
  title: 'Modo de tema',
  subtitle: 'Sistema',
  onTap: () => _showThemeSelector(),
)

// Item con trailing personalizado
SectionItem(
  title: 'Notificaciones',
  trailing: Switch(
    value: _notificationsEnabled,
    onChanged: (value) => _toggleNotifications(value),
  ),
)

// Item con icono
SectionItem(
  title: 'Acerca de',
  leadingIcon: Icons.info_outline,
  onTap: () => _showAbout(),
)
```

## 🎨 Sistema de Iconos

### FontAwesome Integration

#### Ubicación
`lib/presentation/widgets/common/font_awesome/`

#### Estructura
```
font_awesome/
├── font_awesome_flutter.dart    # Export principal
├── name_icon_mapping.dart       # Mapeo de nombres
└── src/
    ├── fa_icon.dart            # Widget de icono
    └── icon_data.dart          # Datos de iconos
```

#### FontAwesome Widget
```dart
class FontAwesome {
  // Iconos sólidos
  static const IconData solidHeart = IconData(0xf004, fontFamily: 'FontAwesomeSolid');
  static const IconData solidPlay = IconData(0xf04b, fontFamily: 'FontAwesomeSolid');
  static const IconData solidPause = IconData(0xf04c, fontFamily: 'FontAwesomeSolid');
  
  // Iconos light
  static const IconData lightHeart = IconData(0xf004, fontFamily: 'FontAwesomeLight');
  static const IconData lightMagnifyingGlass = IconData(0xf002, fontFamily: 'FontAwesomeLight');
  static const IconData lightGear = IconData(0xf013, fontFamily: 'FontAwesomeLight');
  
  // Iconos regular
  static const IconData regularHeart = IconData(0xf004, fontFamily: 'FontAwesomeRegular');
}
```

#### Uso
```dart
// Icono básico
Icon(FontAwesome.lightMagnifyingGlass)

// Icono con tamaño personalizado
Icon(
  FontAwesome.solidHeart,
  size: 24,
  color: Colors.red,
)

// En botones
IconButton(
  icon: Icon(FontAwesome.lightGear),
  onPressed: () => _openSettings(),
)
```

## 🎯 Helpers y Utilidades

### Validadores

#### Ubicación
`lib/core/utils/validators.dart`

#### Funciones Disponibles
```dart
class Validators {
  /// Valida que el campo no esté vacío
  static String? required(String? value, [String? message]) {
    if (value?.trim().isEmpty ?? true) {
      return message ?? 'Este campo es requerido';
    }
    return null;
  }

  /// Valida formato de email
  static String? email(String? value) {
    if (value?.isEmpty ?? true) return null;
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value!)) {
      return 'Formato de email inválido';
    }
    return null;
  }

  /// Valida longitud mínima
  static String? minLength(String? value, int minLength) {
    if (value?.isEmpty ?? true) return null;
    
    if (value!.length < minLength) {
      return 'Debe tener al menos $minLength caracteres';
    }
    return null;
  }

  /// Combina múltiples validadores
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
```

#### Uso
```dart
// Validador simple
CustomTextField(
  labelText: 'Nombre',
  validator: Validators.required,
)

// Validadores combinados
CustomTextField(
  labelText: 'Email',
  validator: Validators.combine([
    Validators.required,
    Validators.email,
  ]),
)

// Validador personalizado
CustomTextField(
  labelText: 'Contraseña',
  validator: (value) => Validators.minLength(value, 6),
)
```

### Toast Notifications

#### Ubicación
`lib/core/utils/toast.dart`

#### Implementación
```dart
class Toast {
  static void show(
    BuildContext context, 
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIconForType(type),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: _getColorForType(type, context),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static IconData _getIconForType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  static Color _getColorForType(ToastType type, BuildContext context) {
    switch (type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Theme.of(context).colorScheme.error;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

enum ToastType { success, error, warning, info }
```

#### Uso
```dart
// Toast básico
Toast.show(context, 'Configuración guardada');

// Toast con tipo específico
Toast.show(
  context, 
  'Error al cargar canciones', 
  type: ToastType.error,
);

// Toast con duración personalizada
Toast.show(
  context, 
  'Procesando...', 
  type: ToastType.info,
  duration: const Duration(seconds: 5),
);
```

## 📐 Responsive Design

### ResponsiveExtensions

#### Ubicación
`lib/core/extensions/responsive_extensions.dart`

#### Implementación
```dart
extension ResponsiveExtensions on BuildContext {
  /// Ancho de la pantalla
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Alto de la pantalla
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Verifica si es un dispositivo móvil
  bool get isMobile => screenWidth < 600;
  
  /// Verifica si es una tablet
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  
  /// Verifica si es desktop
  bool get isDesktop => screenWidth >= 1200;
  
  /// Padding horizontal responsivo
  double get horizontalPadding {
    if (isMobile) return 16.0;
    if (isTablet) return 24.0;
    return 32.0;
  }
  
  /// Número de columnas para grids
  int get gridColumns {
    if (isMobile) return 2;
    if (isTablet) return 3;
    return 4;
  }
}
```

#### Uso
```dart
// Layout responsivo
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: context.horizontalPadding,
    ),
    child: context.isMobile 
        ? _buildMobileLayout()
        : _buildTabletLayout(),
  );
}

// Grid responsivo
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: context.gridColumns,
  ),
  itemBuilder: (context, index) => ItemWidget(),
)
```

## 🔮 Widgets Futuros

### Componentes Planificados
- **SearchBar**: Barra de búsqueda con sugerencias
- **PlaylistCard**: Tarjeta para playlists personalizadas
- **VolumeSlider**: Control de volumen deslizable
- **EqualizerWidget**: Ecualizador visual
- **ArtworkPlaceholder**: Placeholder animado para carátulas
- **LoadingButton**: Botón con estados de carga avanzados

### Mejoras de Accesibilidad
- **HighContrastButton**: Botón para modo alto contraste
- **VoiceOverSupport**: Soporte mejorado para lectores de pantalla
- **LargeTextSupport**: Soporte para texto extra grande
- **KeyboardNavigation**: Navegación completa por teclado

Los widgets comunes proporcionan una base sólida y consistente para toda la interfaz de Sonofy, facilitando el desarrollo y mantenimiento mientras aseguran una experiencia de usuario uniforme.