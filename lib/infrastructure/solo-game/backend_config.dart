/// Enum que define los backends disponibles para el juego solitario.
/// Permite cambiar dinámicamente entre los backends de los dos equipos
/// sin necesidad de recompilar la aplicación.
enum BackendEnvironment {
  /// Backend desarrollado por el Equipo A
  equipoA,

  /// Backend desarrollado por el Equipo B
  equipoB,

  /// Modo mock para desarrollo/testing local
  mock,
}

/// Gestor de configuración dinámico para el backend de solo-game.
///
/// Esta clase centraliza la lógica de conexión a los diferentes backends,
/// siguiendo el principio de Inversión de Dependencias de la arquitectura
/// hexagonal.
///
/// Uso:
/// ```dart
/// // Cambiar de backend
/// BackendSettings.currentEnv = BackendEnvironment.equipoB;
///
/// // O usar el toggle
/// BackendSettings.toggleBackend();
///
/// // Obtener la URL actual
/// final url = BackendSettings.baseUrl;
/// ```
class BackendSettings {
  /// El entorno actual activo.
  /// Por defecto inicia con el Equipo A.
  static BackendEnvironment currentEnv = BackendEnvironment.equipoA;

  /// URLs base de cada equipo.
  ///
  /// IMPORTANTE: Actualizar estas URLs con las URLs reales de producción
  /// de cada equipo de backend.
  static const Map<BackendEnvironment, String> _urls = {
    BackendEnvironment.equipoA: 'https://quizzy-backend-0wh2.onrender.com',
    BackendEnvironment.equipoB: 'Massi: https://backcomun-gc5j.onrender.com',
    BackendEnvironment.mock: 'http://localhost:8080',
  };

  /// Obtiene la URL base del entorno actual.
  static String get baseUrl =>
      _urls[currentEnv] ?? _urls[BackendEnvironment.mock]!;

  /// Obtiene el nombre legible del entorno actual para mostrar en UI.
  static String get currentEnvName {
    switch (currentEnv) {
      case BackendEnvironment.equipoA:
        return 'Equipo A';
      case BackendEnvironment.equipoB:
        return 'Equipo B';
      case BackendEnvironment.mock:
        return 'Mock (Local)';
    }
  }

  /// Cambia al otro equipo de backend (toggle entre A y B).
  ///
  /// Útil para un botón de cambio rápido en la UI.
  /// No cambia a modo mock, solo alterna entre los equipos reales.
  static void toggleBackend() {
    if (currentEnv == BackendEnvironment.equipoA) {
      currentEnv = BackendEnvironment.equipoB;
    } else {
      currentEnv = BackendEnvironment.equipoA;
    }
  }

  /// Establece un entorno específico.
  static void setEnvironment(BackendEnvironment env) {
    currentEnv = env;
  }
}
