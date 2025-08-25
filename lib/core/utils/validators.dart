import 'package:easy_localization/easy_localization.dart';

/// Utility class for form validation following Clean Code principles
class AppValidators {
  AppValidators._();

  /// Validates that a field is not empty
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'common.required'.tr();
    }
    return null;
  }

  /// Validates minimum length for a field
  static String? minLength(String? value, int min) {
    if (value == null || value.trim().length < min) {
      return 'common.min_length'.tr(namedArgs: {'min': min.toString()});
    }
    return null;
  }

  /// Validates maximum length for a field
  static String? maxLength(String? value, int max) {
    if (value != null && value.trim().length > max) {
      return 'common.max_length'.tr(namedArgs: {'max': max.toString()});
    }
    return null;
  }

  /// Validates that a field contains only alphanumeric characters and spaces
  static String? alphanumeric(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9\s]+$');
    if (!alphanumericRegex.hasMatch(value.trim())) {
      return 'common.alphanumeric_only'.tr();
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'common.invalid_email'.tr();
    }
    return null;
  }

  /// Validates URL format for images
  static String? imageUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    
    try {
      final uri = Uri.parse(value.trim());
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'common.invalid_url'.tr();
      }
      
      // Check if URL looks like an image
      final path = uri.path.toLowerCase();
      final query = uri.query.toLowerCase();
      final host = uri.host.toLowerCase();
      
      // Traditional image extensions
      final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'];
      
      // Known image hosting/CDN domains that don't require extensions
      final imageDomains = [
        'cloudfront.net',
        'amazonaws.com',
        'googleusercontent.com',
        'imgix.net',
        'cloudinary.com',
        'fastly.com',
        'akamai.net',
        'imgur.com',
        'gravatar.com',
        'twimg.com',
        'fbcdn.net',
        'cdninstagram.com',
        'unsplash.com',
        'pexels.com',
        'pixabay.com',
        'picsum.photos',
        'placeholder.com',
        'via.placeholder.com',
        'dummyimage.com',
        'placekitten.com',
        'placehold.it',
        'fakeimg.pl',
      ];
      
      // Image format hints in query parameters
      final imageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp'];
      
      // Check traditional extensions
      if (imageExtensions.any(path.endsWith)) {
        return null;
      }
      
      // Check known image domains
      if (imageDomains.any(host.contains)) {
        return null;
      }
      
      // Check for image format hints in query parameters
      if (imageFormats.any(query.contains)) {
        return null;
      }
      
      // Check for image-related path segments
      if (path.contains('/image') || 
          path.contains('/img') || 
          path.contains('/photo') || 
          path.contains('/picture') ||
          path.contains('/avatar') ||
          path.contains('/thumb') ||
          path.contains('/resize')) {
        return null;
      }
      
      // If none of the above, it might still be valid but warn user
      return 'common.url_might_not_be_image'.tr();
      
    } catch (e) {
      return 'common.invalid_url'.tr();
    }
  }

  /// Validates if URL is likely to work with CORS (informational only)
  static String? corsWarning(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    
    try {
      final uri = Uri.parse(value.trim());
      final host = uri.host.toLowerCase();
      
      // List of known hosts that typically have CORS issues
      final problematicHosts = [
        'i.imgur.com',
        'imgur.com',
        'reddit.com',
        'redditstatic.com',
        'wikimedia.org',
        'wikipedia.org',
      ];
      
      if (problematicHosts.any(host.contains)) {
        return 'common.cors_warning'.tr();
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Combines multiple validators
  static String? combine(List<String? Function(String?)> validators, String? value) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }

  /// Validates person name (required + min length)
  static String? personName(String? value) {
    return combine([
      required,
      (v) => minLength(v, 2),
    ], value);
  }

  /// Validates set name (required + min length)
  static String? setName(String? value) {
    return combine([
      required,
      (v) => minLength(v, 2),
    ], value);
  }

  /// Validates optional description (max length only)
  static String? description(String? value) {
    return maxLength(value, 500);
  }
}