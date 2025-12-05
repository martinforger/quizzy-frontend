# Quizzy - Kahoot Clone 🎓📱

Bienvenido a **Quizzy**, un clon funcional de Kahoot desarrollado como proyecto académico para la asignatura **Desarrollo de Software** de la **Universidad Católica Andrés Bello (UCAB)**.

Este proyecto tiene como objetivo demostrar la implementación de una arquitectura robusta, escalable y mantenible aplicando los principios de la **Arquitectura Hexagonal (Puertos y Adaptadores)** en un entorno de desarrollo móvil con **Flutter**.

---

## 🏗 Arquitectura del Proyecto

El proyecto sigue estrictamente los principios de la **Arquitectura Hexagonal**, separando el código en capas distintas para asegurar que la lógica de negocio permanezca independiente de la interfaz de usuario, bases de datos o servicios externos.

Esta estructura facilita:
- **Testabilidad**: La lógica de negocio puede ser probada independientemente de la UI o DB.
- **Mantenibilidad**: Cambios en la UI o en servicios externos no afectan la lógica core.
- **Escalabilidad**: Nuevas características pueden agregarse siguiendo patrones establecidos.

### 📂 Estructura de Capas (Layers)

El código fuente (`lib/`) está organizado en las siguientes capas fundamentales:

#### 1. Domain (`lib/domain`) 🧠
Es el núcleo del sistema. Contiene la lógica de negocio pura y las reglas que gobiernan la aplicación.
- **Entidades**: Objetos fundamentales del negocio (ej. `Question`, `Quiz`).
- **Interfaces de Repositorios (Puertos)**: Contratos abstractos que definen cómo se debe acceder a los datos, sin preocuparse por la implementación técnica.

#### 2. Application (`lib/application`) ⚙️
Actúa como intermediario entre el Dominio y la Presentación o Infraestructura.
- **Casos de Uso (Use Cases)**: Representan acciones específicas que un usuario puede realizar en el sistema (ej. `StartGame`, `AnswerQuestion`). Orquestan el flujo de datos hacia y desde las entidades del dominio.

#### 3. Infrastructure (`lib/infrastructure`) 🔌
Contiene las implementaciones concretas de las interfaces definidas en el dominio.
- **Repositorios**: Implementación de los contratos del dominio (ej. `QuizRepositoryImpl`).
- **Fuentes de Datos (Data Sources)**: Conexiones a APIs, bases de datos locales (`shared_preferences`), etc.
- **DTOs (Data Transfer Objects)**: Modelos para transformar datos externos (JSON) a entidades de dominio.

#### 4. Presentation (`lib/presentation`) 🎨
Responsable de todo lo que el usuario ve y con lo que interactúa.
- **Screens/Pages**: Pantallas de la aplicación (ej. `GameScreen`, `HomeScreen`).
- **Widgets**: Componentes reutilizables de UI.
- **State Management (Bloc/Cubit)**: Gestiona el estado de la UI y comunica eventos a la capa de Aplicación.

---

## 🚀 Tecnologías y Herramientas

- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.9.2)
- **Lenguaje**: Dart
- **Gestión de Estado**: `flutter_bloc`
- **Animaciones**: `flutter_animate`, `confetti`
- **Tipografía**: `google_fonts`
- **HTTP Client**: `http`
- **Almacenamiento Local**: `shared_preferences`

---

## 🌟 Funcionalidades Principales

El proyecto está modularizado por características ("features") que atraviesan las capas de la arquitectura:

*   **Discovery**: Exploración de quizzes y kahoots disponibles.
*   **Solo Game**: Modo de juego individual donde el usuario responde preguntas, recibe feedback inmediato y acumula puntuación.
*   **Kahoots**: Visualización y gestión de los cuestionarios.
*   **Library**: Gestión de la biblioteca personal del usuario.

### Flujo de Funcionamiento Típico
1.  **UI**: El usuario interactúa con la pantalla (ej. presiona "Jugar").
2.  **Bloc**: Captura el evento y llama al Caso de Uso correspondiente en la capa **Application**.
3.  **Use Case**: Ejecuta la lógica y solicita datos al repositorio (interfaz en **Domain**).
4.  **Infrastructure**: El repositorio concreto obtiene los datos (API/Local) y devuelve Entidades de Dominio.
5.  **Bloc**: Recibe el resultado y emite un nuevo estado a la **UI**.
6.  **UI**: Se actualiza para mostrar la información al usuario.

---

## 🛠 Instalación y Ejecución

1.  **Clonar el repositorio**:
    ```bash
    git clone <url-del-repositorio>
    ```
2.  **Instalar dependencias**:
    ```bash
    flutter pub get
    ```
3.  **Ejecutar la aplicación**:
    ```bash
    flutter run
    ```

---

_Desarrollado con MUCHO ☕ por el equipo NARANJA LABS de Quizzy para CALONZO._
