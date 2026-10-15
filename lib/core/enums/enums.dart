library com.app_track_ota_labs.app.enums;

import 'package:flutter/material.dart';

enum CustomNavigationAnimation {
  slideRight,
  slideBottom,
  fade,
  scale,
  scaleFade,
}

enum SnackbarType { information, success, error }

/// Plataformas destino de una app. [value] es lo que se guarda en
/// `app_track.all_apps.platform` (nombres oficiales de cada plataforma; ver
/// supabase/sql/0007_all_apps_normalize_platform_version_status.sql).
enum AppPlatform {
  ios('iOS', Icons.apple),
  android('Android', Icons.android),
  web('Web', Icons.language),
  macos('macOS', Icons.desktop_mac),
  windows('Windows', Icons.desktop_windows);

  const AppPlatform(this.value, this.icon);

  final String value;
  final IconData icon;

  /// Plataforma de [raw] sin distinguir mayúsculas (`macos` → [macos]);
  /// `null` si no es una plataforma conocida.
  static AppPlatform? tryParse(String raw) {
    String normalized = raw.trim().toLowerCase();
    for (AppPlatform platform in values) {
      if (platform.value.toLowerCase() == normalized) return platform;
    }
    return null;
  }
}

/// Estado de publicación de una app. [value] es lo que se guarda en
/// `app_track.all_apps.status`; [label] es el texto que ve el usuario.
enum AppStatus {
  draft('Draft', 'Borrador'),
  inReview('In Review', 'En revisión'),
  live('Live', 'Publicada');

  const AppStatus(this.value, this.label);

  final String value;
  final String label;

  /// Estado de [raw] sin distinguir mayúsculas; `null` si no es conocido.
  static AppStatus? tryParse(String raw) {
    String normalized = raw.trim().toLowerCase();
    for (AppStatus status in values) {
      if (status.value.toLowerCase() == normalized) return status;
    }
    return null;
  }
}
