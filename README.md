# Quizzy - Kahoot Clone 🎓📱

Bienvenido a **Quizzy**, una plataforma de aprendizaje interactivo y gamificación diseñada como un clon funcional de Kahoot. Este proyecto fue desarrollado como parte de la asignatura **Desarrollo de Software** de la **Universidad Católica Andrés Bello (UCAB)**.

**Quizzy** permite a los usuarios crear, compartir y jugar cuestionarios en tiempo real, ofreciendo una experiencia dinámica tanto para el anfitrión (Host) como para los jugadores.

---

## 🌟 Funcionalidades Principales

### 🔐 Autenticación y Perfil
*   **Gestión de Usuarios**: Registro e inicio de sesión seguro.
*   **Perfiles Personalizados**: Configuración de avatar (incluyendo carga de imágenes) y datos de usuario.

### 🎮 Experiencia de Juego (Multiplayer & Solo)
*   **Modo Multijugador Real-Time**: 
    *   **Anfitrión (Host)**: Controla el flujo de la partida, ve el ranking en tiempo real y gestiona la sala.
    *   **Jugador (Player)**: Se une mediante un **PIN de sesión** o escaneando un **código QR**.
    *   **Sincronización Total**: Comunicación fluida mediante WebSockets para una experiencia sin latencia.
*   **Modo Solo**: Practica y mejora tus conocimientos de forma individual.
*   **Feedback Inmediato**: Animaciones y efectos visuales al acertar o fallar preguntas.

### 📝 Creación y Gestión (Kahoots)
*   **Editor de Cuestionarios**: Crea tus propios "Kahoots" con diferentes tipos de preguntas.
*   **Integración con IA (OpenAI)**: 🤖 Generación automática de imágenes para tus preguntas utilizando inteligencia artificial.
*   **Explorador (Discovery)**: Encuentra y juega cuestionarios creados por la comunidad.

### 📊 Reportes y Analíticas
*   **Historial de Partidas**: Revisa tus resultados en juegos anteriores.
*   **Reportes de Sesión**: Análisis detallado del desempeño de todos los jugadores al finalizar una partida alojada.

### 👥 Social y Notificaciones
*   **Grupos**: Crea comunidades y comparte cuestionarios específicos con grupos de amigos o estudiantes.
*   **Notificaciones Push**: Alertas en tiempo real sobre nuevas actividades, invitaciones a grupos o recordatorios.

---

## 🏗 Arquitectura del Proyecto

El proyecto implementa una arquitectura robusta basada en los principios de **Arquitectura Hexagonal (Pares y Adaptadores)** combinada con **Domain-Driven Design (DDD)**. Esta estructura asegura que la lógica de negocio sea independiente de los detalles de implementación (UI, DB, APIs).

### 📂 Estructura de Capas (lib/)

#### 1. **Domain** (`/lib/domain`) 🧠
Contiene el "corazón" de la aplicación:
*   **Entities**: Objetos de negocio básicos (User, Quiz, Question, Session).
*   **Value Objects**: Datos inmutables con validaciones propias.
*   **Repositories Interfaces**: Contratos que definen las operaciones de datos.

#### 2. **Application** (`/lib/application`) ⚙️
Orquesta el flujo de la aplicación:
*   **Use Cases**: Implementan la lógica de negocio específica para cada acción del usuario (ej. `CreateSession`, `SubmitAnswer`).
*   **DI (Dependency Injection)**: Gestionado por `GetIt` para mantener el desacoplamiento.

#### 3. **Infrastructure** (`/lib/infrastructure`) 🔌
Detalles de implementación técnica:
*   **Repositories Implementation**: Lógica para conectar con PostgreSQL, Firebase o APIs externas.
*   **Data Sources**: Clientes HTTP, Socket.IO, y persistencia local (`SharedPreferences`).
*   **Services**: Integraciones con OpenAI, Firebase Messaging, etc.

#### 4. **Presentation** (`/lib/presentation`) 🎨
Interfaz de usuario y gestión de estado:
*   **State Management (BLoC/Cubit)**: Separación clara entre la lógica de la UI y los componentes visuales.
*   **Atomic Design**: Widgets reutilizables y pantallas organizadas por módulos.
*   **Theming**: Sistema de diseño consistente y animaciones fluidas (`flutter_animate`).

---

## 🚀 Stack Tecnológico

| Tecnología | Propósito |
| :--- | :--- |
| **Flutter / Dart** | Framework de desarrollo multiplataforma. |
| **BLoC (flutter_bloc)** | Gestión de estado predecible y escalable. |
| **Socket.IO** | Comunicación bidireccional en tiempo real para el multijugador. |
| **Firebase** | Push Notifications (Cloud Messaging) y Core Services. |
| **GetIt** | Service Locator para Inyección de Dependencias. |
| **OpenAI API** | Generación de imágenes mediante IA para kahoots. |
| **HTTP client** | Comunicación con el backend REST. |
| **Mobile Scanner / QR Flutter** | Generación y lectura de códigos QR. |
| **Flutter Animate / Confetti** | Micro-interacciones y efectos de gamificación. |

---

## 🛠 Instalación y Configuración

### Pre-requisitos
*   Flutter SDK (^3.9.2)
*   Dart SDK
*   Un emulador o dispositivo físico configurado.

### Pasos
1.  **Clonar el repositorio**:
    ```bash
    git clone https://github.com/martinforger/quizzy-frontend
    cd quizzy
    ```
2.  **Instalar dependencias**:
    ```bash
    flutter pub get
    ```
3.  **Configurar Firebase**:
    Asegúrate de tener el archivo `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) configurados correctamente en las carpetas nativas si deseas probar las notificaciones.
4.  **Ejecutar**:
    ```bash
    flutter run
    ```

### Desarrollo y Testing (Mock Server)
Si deseas probar la aplicación sin depender de un backend externo, el proyecto incluye un servidor de mocks:

1.  **Navegar al directorio**: `cd mock_server`
2.  **Instalar dependencias**: `dart pub get`
3.  **Ejecutar el servidor**: `dart bin/server.dart`
    *   El servidor correrá por defecto en `http://localhost:3000`.

---

## 👥 Equipo de Desarrollo
Proyecto creado por el equipo **NARANJA LABS** para la UCAB.

---
_Desarrollado con pasión, café y Flutter._ ☕✨
