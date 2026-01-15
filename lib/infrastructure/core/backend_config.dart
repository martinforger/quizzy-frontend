/// Enum que define los backends disponibles para el juego solitario.
/// Permite cambiar dinámicamente entre los backends de los dos equipos
/// sin necesidad de recompilar la aplicación.
enum BackendEnvironment {
  /// Backend desarrollado por el Equipo A
  equipoA,

  /// Backend desarrollado por el Equipo B
  equipoB,

  /// Modo mock para desarrollo/testing local
  privado,
}

class BackendSettings {
  static BackendEnvironment currentEnv = BackendEnvironment.equipoA;

  /// URLs base de cada equipo.
  static const Map<BackendEnvironment, String> _urls = {
    BackendEnvironment.equipoA:
        'https://quizzy-backend-1-zpvc.onrender.com/api',
    BackendEnvironment.equipoB: 'https://backcomun-gc5j.onrender.com',
    BackendEnvironment.privado: 'https://quizzybackend.app/api',
  };

  /// Obtiene la URL base del entorno actual.
  static String get baseUrl =>
      _urls[currentEnv] ?? _urls[BackendEnvironment.privado]!;

  /// Obtiene el nombre legible del entorno actual para mostrar en UI.
  static String get currentEnvName {
    switch (currentEnv) {
      case BackendEnvironment.equipoA:
        return 'Equipo A';
      case BackendEnvironment.equipoB:
        return 'Equipo B';
      case BackendEnvironment.privado:
        return 'Privado';
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
