# 🦉 Turismo Ciudadano - El Búho

Aplicación móvil desarrollada en **Flutter** con backend en **Supabase**, orientada al turismo ciudadano. Permite a los usuarios descubrir, publicar y reseñar sitios turísticos, con una experiencia moderna y profesional.

---

## 🚀 Características principales

- **Registro e inicio de sesión** de usuarios (visitante y publicador).
- **Publicación de sitios turísticos** con ubicación y hasta 5 fotografías.
- **Subida de imágenes** desde galería o cámara, con validación de cantidad y tamaño.
- **Microblog**: cada sitio es una entrada donde los usuarios pueden dejar reseñas.
- **Reseñas y respuestas**: los visitantes pueden dejar reseñas y los publicadores pueden responderlas o eliminarlas.
- **Gestión de roles**:
  - **Visitante**: visualiza contenido y reseñas.
  - **Publicador**: publica sitios, sube fotos y gestiona reseñas.
- **Interfaz moderna**: diseño atractivo, responsivo y accesible.

---

## 🛠️ Tecnologías utilizadas

- **Flutter** (Dart)
- **Supabase** (autenticación, base de datos y almacenamiento de imágenes)
- **Provider** (gestión de estado)
- **Google Fonts** (tipografía moderna)
- **Image Picker** (selección de imágenes)
- **Cached Network Image** (carga eficiente de imágenes)

---

## 📲 Instalación y ejecución

1. **Clona el repositorio:**
   ```bash
   git clone https://github.com/tu_usuario/flutter_turismo_app.git
   cd flutter_turismo_app
   ```
2. **Instala las dependencias:**
   ```bash
   flutter pub get
   ```
3. **Configura Supabase:**
   - Crea un proyecto en [Supabase](https://supabase.com/).
   - Copia tu URL y anon key en `lib/main.dart`:
     ```dart
     await Supabase.initialize(
       url: 'TU_SUPABASE_URL',
       anonKey: 'TU_SUPABASE_ANON_KEY',
     );
     ```
   - Crea las tablas y buckets siguiendo las instrucciones del proyecto.
4. **Ejecuta la app:**
   ```bash
   flutter run
   ```
5. **Genera el APK:**
   ```bash
   flutter build apk --release
   # El APK estará en build/app/outputs/flutter-apk/app-release.apk
   ```

---

## 📝 Estructura del proyecto

```
lib/
  pages/         # Pantallas principales (login, registro, home, detalle, crear post)
  widgets/       # Componentes visuales reutilizables
  services/      # Lógica de acceso a Supabase y autenticación
  models/        # Modelos de datos
```

---

## 📦 Dependencias principales

- supabase_flutter
- image_picker
- flutter_image_compress
- provider
- cached_network_image
- google_fonts

---

## 👤 Autores
- El Búho - Equipo de desarrollo

---

## 📄 Licencia
Este proyecto es de uso académico y demostrativo.
