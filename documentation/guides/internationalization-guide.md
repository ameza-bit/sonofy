# Guía de Internacionalización - Sistema de Traducciones

## 📋 Visión General

Sonofy utiliza un sistema de internacionalización robusto basado en `easy_localization` que permite soporte multiidioma completo. La aplicación actualmente soporta **Español** e **Inglés** con una arquitectura extensible para agregar más idiomas.

## 🌍 Idiomas Soportados

- **Español (es)** - Idioma principal
- **English (en)** - Idioma secundario

## 📁 Estructura de Archivos

```
assets/translations/
├── es.json     # Traducciones en español
└── en.json     # Traducciones en inglés
```

## 🆕 Nuevas Traducciones Agregadas

### Opciones de Modal Contextual

**Español (`es.json`)**
```json
{
  "options": {
    "play_song": "Reproducir",
    "play_next": "Reproducir a continuación", 
    "add_to_queue": "Agregar a la cola",
    "remove_from_queue": "Quitar de la cola",
    "song_info": "Información de la canción",
    "song_added_next": "Canción agregada para reproducir a continuación",
    "song_added_to_queue": "Canción agregada a la cola",
    "song_not_in_queue": "La canción no está en la cola actual",
    "song_removed_from_queue": "Canción eliminada de la cola"
  }
}
```

**Inglés (`en.json`)**
```json
{
  "options": {
    "play_song": "Play",
    "play_next": "Play next",
    "add_to_queue": "Add to queue", 
    "remove_from_queue": "Remove from queue",
    "song_info": "Song information",
    "song_added_next": "Song added to play next",
    "song_added_to_queue": "Song added to queue",
    "song_not_in_queue": "Song is not in the current queue",
    "song_removed_from_queue": "Song removed from queue"
  }
}
```

### Información de Canción

**Español (`es.json`)**
```json
{
  "song": {
    "details": "Detalles de la Canción",
    "title": "Título",
    "artist": "Artista", 
    "album": "Álbum",
    "duration": "Duración",
    "genre": "Género",
    "composer": "Compositor",
    "file_size": "Tamaño del Archivo"
  }
}
```

**Inglés (`en.json`)**
```json
{
  "song": {
    "details": "Song Details",
    "title": "Title",
    "artist": "Artist",
    "album": "Album", 
    "duration": "Duration",
    "genre": "Genre",
    "composer": "Composer",
    "file_size": "File Size"
  }
}
```

### Mensajes de Playlist

**Español (`es.json`)**
```json
{
  "playlist": {
    "song_added_generic": "Canción agregada a la lista de reproducción",
    "song_removed": "Canción eliminada de {playlist}",
    "remove_song_confirmation": "¿Estás seguro que quieres eliminar esta canción de '{playlist}'?"
  }
}
```

**Inglés (`en.json`)**
```json
{
  "playlist": {
    "song_added_generic": "Song added to playlist", 
    "song_removed": "Song removed from {playlist}",
    "remove_song_confirmation": "Are you sure you want to remove this song from '{playlist}'?"
  }
}
```

## 🔧 Uso de Traducciones

### Sintaxis Básica

```dart
// Traducción simple
Text(context.tr('options.play_song'))

// Traducción con parámetros nombrados
Text(
  context.tr('playlist.song_removed', namedArgs: {
    'playlist': playlistName,
  })
)

// Traducción con pluralización
Text(
  context.tr('playlist.songs_count', namedArgs: {
    'count': songCount.toString(),
  })
)
```

### Ejemplos en Widgets

```dart
// ✅ En opciones de modal
SectionItem(
  icon: FontAwesomeIcons.solidPlay,
  title: context.tr('options.play_song'),
  onTap: () => _playSong(),
)

// ✅ En confirmaciones
showDialog(
  builder: (context) => AlertDialog(
    content: Text(
      context.tr('playlist.remove_song_confirmation', namedArgs: {
        'playlist': playlist.title,
      }),
    ),
  ),
)

// ✅ En notificaciones
Toast.show(
  context.tr('options.song_added_next')
)
```

## 📝 Convenciones de Nomenclatura

### Estructura Jerárquica

Las traducciones siguen una estructura jerárquica clara:

```json
{
  "categoria": {
    "subcategoria": "valor",
    "accion_resultado": "Mensaje de resultado"
  }
}
```

### Categorías Principales

| Categoría | Propósito | Ejemplo |
|-----------|-----------|---------|
| `options` | Opciones de menús y modales | `options.play_song` |
| `song` | Información y metadatos | `song.artist` |
| `playlist` | Gestión de playlists | `playlist.song_added` |
| `player` | Reproductor de música | `player.no_song_selected` |
| `library` | Biblioteca musical | `library.empty` |
| `common` | Elementos comunes | `common.cancel` |

### Patrones de Naming

- **Acciones**: `verbo_objeto` → `play_song`, `add_to_queue`
- **Estados**: `sustantivo_estado` → `song_playing`, `playlist_empty`  
- **Resultados**: `objeto_resultado` → `song_added`, `playlist_created`
- **Confirmaciones**: `accion_confirmation` → `delete_confirmation`

## 🚀 Agregar Nuevas Traducciones

### Paso 1: Definir la Traducción

**es.json**
```json
{
  "nueva_categoria": {
    "nueva_opcion": "Texto en español"
  }
}
```

**en.json** 
```json
{
  "nueva_categoria": {
    "nueva_opcion": "Text in English"
  }
}
```

### Paso 2: Usar en el Código

```dart
Text(context.tr('nueva_categoria.nueva_opcion'))
```

### Paso 3: Testear Cambio de Idioma

```dart
// Cambiar idioma programáticamente
await context.setLocale(const Locale('en'));
```

## 🔄 Context-Aware Translations

Las nuevas traducciones soportan contextos específicos:

```dart
// Diferentes mensajes según contexto
if (context == ModalContext.playlistModal) {
  Toast.show(context.tr('options.song_removed_from_queue'));
} else if (context == ModalContext.playlistScreen) {
  Toast.show(context.tr('playlist.song_removed', namedArgs: {
    'playlist': playlistName
  }));
}
```

## 🎯 Mejores Prácticas

### ✅ Do's

- **Usar keys descriptivos**: `options.play_next` vs `opt1`
- **Mantener consistencia**: Misma terminología en toda la app
- **Usar parámetros nombrados**: Para textos dinámicos
- **Agrupar por funcionalidad**: Organizar en categorías lógicas
- **Probar ambos idiomas**: Verificar que todo funcione

### ❌ Don'ts

- **No hardcodear textos**: Siempre usar `context.tr()`
- **No duplicar keys**: Reutilizar traducciones cuando sea posible
- **No usar keys genéricos**: `text1`, `msg`, etc.
- **No ignorar contexto**: Considerar donde se usa cada traducción
- **No romper parámetros**: Mantener `{placeholder}` consistente

## 📊 Cobertura de Traducciones

### Estado Actual

| Categoría | Total Keys | ES | EN | Cobertura |
|-----------|------------|----|----|-----------|
| options | 25 | ✅ | ✅ | 100% |
| song | 8 | ✅ | ✅ | 100% |
| playlist | 15 | ✅ | ✅ | 100% |
| player | 12 | ✅ | ✅ | 100% |
| library | 8 | ✅ | ✅ | 100% |
| common | 20 | ✅ | ✅ | 100% |

### Nuevas Adiciones (2024)

- **8 nuevas opciones contextuales** para modales de canción
- **8 campos de información** de canción detallada
- **3 mensajes adicionales** de gestión de playlist
- **Total**: 19 nuevas traducciones

## 🔮 Roadmap Futuro

### Idiomas Planeados
- **Portugués (pt)** - Para mercado brasileño
- **Francés (fr)** - Para mercado europeo
- **Alemán (de)** - Para mercado europeo

### Funcionalidades Futuras
- **Detección automática** de idioma del sistema
- **Pluralización avanzada** para contadores
- **Formatos de fecha/hora** localizados
- **Orden de nombres** específico por cultura

---

El sistema de traducciones de Sonofy proporciona una base sólida para la internacionalización, permitiendo que usuarios de diferentes regiones disfruten de la aplicación en su idioma nativo con terminología apropiada y contextualmente relevante.