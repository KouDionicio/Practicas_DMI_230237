# Práctica 05: Widgets — Componentes e interfaces en Flutter

## Descripción

Aplicación desarrollada en Flutter que reúne diferentes ejemplos de widgets para conocer sus propiedades, funcionamiento e integración en interfaces móviles. El proyecto utiliza una estructura organizada por pantallas, configuración de rutas, proveedores de estado y temas personalizados.

La aplicación permite navegar entre diferentes ejemplos de componentes mediante un menú principal. También incorpora Riverpod para la gestión del estado, GoRouter para la navegación y herramientas de animación para mejorar la experiencia visual.

## Aplicación desarrollada

La aplicación presenta un menú principal con acceso a las diferentes prácticas de widgets. Cada sección permite explorar un componente o funcionalidad específica de Flutter.

Entre las funcionalidades implementadas se encuentran los botones, tarjetas, indicadores de progreso, Snackbars y diálogos, contenedores animados, controles de interfaz, tutorial introductorio, listas con desplazamiento infinito, un contador con Riverpod y la personalización del tema de la aplicación.

La navegación se administra mediante GoRouter, mientras que Riverpod permite gestionar el estado del contador y las preferencias visuales, como el modo oscuro y la selección de colores.

## Actividades realizadas

1. Se organizó la estructura del proyecto Flutter mediante carpetas para configuración, proveedores y pantallas.
2. Se implementó un menú principal con accesos a los diferentes ejemplos de widgets.
3. Se configuró la navegación entre pantallas mediante GoRouter.
4. Se integraron ejemplos de botones, tarjetas e indicadores de progreso.
5. Se incorporaron notificaciones Snackbars y cuadros de diálogo.
6. Se implementaron animaciones mediante el paquete `animate_do` y widgets animados.
7. Se agregaron controles de interfaz y elementos de interacción.
8. Se desarrolló un tutorial introductorio para presentar la aplicación.
9. Se trabajó con listas infinitas y la funcionalidad de actualización mediante Pull to Refresh.
10. Se integró un contador utilizando Riverpod para la gestión del estado.
11. Se configuró el cambio de tema, incluyendo el modo oscuro y la selección de colores.
12. Se instalaron y configuraron las dependencias necesarias para la navegación, gestión del estado y animaciones.
13. Se ejecutó la aplicación en un dispositivo Android mediante conexión inalámbrica para comprobar su funcionamiento.

## Archivos principales

- [Punto de entrada de la aplicación](lib/main.dart)
- [Configuración de rutas](lib/config/router/app_router.dart)
- [Configuración del tema](lib/config/theme/app_theme.dart)
- [Menú principal](lib/config/menu/menu_items.dart)
- [Exportación de pantallas](lib/presentation/screens/screens.dart)
- [Pantalla principal](lib/presentation/screens/home/home_screen.dart)
- [Pantalla de botones](lib/presentation/screens/buttons/buttons_screen.dart)
- [Pantalla de tarjetas](lib/presentation/screens/cards/cards_screen.dart)
- [Indicadores de progreso](lib/presentation/screens/progress/progress_screen.dart)
- [Snackbars y diálogos](lib/presentation/screens/snackbar/snackbar_screen.dart)
- [Contenedor animado](lib/presentation/screens/animated/animated_screen.dart)
- [Controles de interfaz](lib/presentation/screens/ui_controls/ui_controls_screen.dart)
- [Tutorial introductorio](lib/presentation/screens/app_tutorial/app_tutorial_screen.dart)
- [Listas infinitas](lib/presentation/screens/infinite_scroll/infinite_scroll_screen.dart)
- [Contador con Riverpod](lib/presentation/screens/counter/counter_screen.dart)
- [Cambio de tema](lib/presentation/screens/theme_changer/theme_changer_screen.dart)

> Nota: las rutas de configuración y de los archivos principales deben coincidir con la estructura real del proyecto.

## Evidencias

Las siguientes secciones están preparadas para agregar capturas de pantalla de la aplicación ejecutándose en el dispositivo Android. Guarda las imágenes dentro de la carpeta `assets/` ubicada junto a este README.

### 1. Menú principal

Vista inicial de la aplicación con las opciones disponibles para navegar entre los diferentes ejemplos de widgets.

<img src="/Practica05/widget_app/assets/1.jpeg" alt="Menú principal de Widgets" width="250">

### 2. Botones

Ejemplos de los diferentes botones disponibles en Flutter y sus variantes visuales e interactivas.

<img src="/Practica05/widget_app/assets/2.jpeg" alt="Ejemplos de botones en Flutter" width="250">

### 3. Tarjetas

Pantalla que muestra tarjetas como elementos de interfaz para organizar y presentar contenido.

<img src="/Practica05/widget_app/assets/3.jpeg" alt="Tarjetas en Flutter" width="250">

### 4. Indicadores de progreso

Ejemplos de indicadores de progreso generales y controlados para representar procesos o estados de carga.

<img src="/Practica05/widget_app/assets/4.jpeg" alt="Indicadores de progreso" width="250">

### 5. Snackbars y diálogos

Demostración de mensajes temporales y cuadros de diálogo para comunicar información al usuario.

<img src="/Practica05/widget_app/assets/5.jpeg" alt="Snackbars y diálogos" width="250">
<img src="/Practica05/widget_app/assets/5.2.jpeg" alt="Snackbars y diálogos" width="250">
<img src="/Practica05/widget_app/assets/5.3.jpeg" alt="Snackbars y diálogos" width="250">
<img src="/Practica05/widget_app/assets/5.4.jpeg" alt="Snackbars y diálogos" width="250">
<img src="/Practica05/widget_app/assets/5.5.jpeg" alt="Snackbars y diálogos" width="250">

### 6. Contenedor animado

Ejemplo de un contenedor que modifica sus propiedades visuales mediante animaciones.

<img src="/Practica05/widget_app/assets/6.jpeg" alt="Animated Container" width="250">
<img src="/Practica05/widget_app/assets/6.2.jpeg" alt="Animated Container" width="250">

### 7. Controles de interfaz

Pantalla con diferentes controles y elementos de interacción de Flutter.

<img src="/Practica05/widget_app/assets/7.jpeg" alt="Controles de interfaz" width="250">

### 8. Tutorial introductorio

Vista del tutorial inicial que presenta información sobre el uso de la aplicación.

<img src="/Practica05/widget_app/assets/8.jpeg" alt="Tutorial introductorio" width="250">

### 9. Desplazamiento infinito y actualización

Ejemplo de una lista con desplazamiento infinito y la funcionalidad Pull to Refresh para solicitar una actualización del contenido.

<img src="/Practica05/widget_app/assets/9.jpeg" alt="Lista infinita y Pull to Refresh" width="250">
<img src="/Practica05/widget_app/assets/9.2.jpeg" alt="Lista infinita y Pull to Refresh" width="250">

### 10. Contador con Riverpod

Demostración del contador administrado mediante un proveedor de estado, con controles para interactuar con su valor.

<img src="/Practica05/widget_app/assets/10.jpeg" alt="Contador con Riverpod" width="250">

### 11. Cambio de tema

Pantalla para personalizar la apariencia de la aplicación mediante el modo oscuro y la selección de colores.

<img src="/Practica05/widget_app/assets/11.jpeg" alt="Personalización del tema" width="250">
<img src="/Practica05/widget_app/assets/11.2.jpeg" alt="Personalización del tema" width="250">

## Tecnologías y dependencias

- **Flutter:** desarrollo de la interfaz y de la aplicación móvil.
- **Dart:** lenguaje de programación.
- **GoRouter:** configuración y navegación entre pantallas.
- **Riverpod:** gestión del estado de la aplicación.
- **animate_do:** integración de efectos y animaciones.
- **Material Design:** componentes visuales y controles de interfaz.

## Ejecución y pruebas

Desde el directorio del proyecto que contiene `pubspec.yaml`, ejecutar los siguientes comandos:

```bash
flutter pub get
flutter analyze
flutter run
```

Para ejecutar la aplicación en un dispositivo Android conectado por ADB inalámbrico, primero se puede consultar la lista de dispositivos:

```bash
flutter devices
```

Después, ejecutar la aplicación indicando el identificador del dispositivo:

```bash
flutter run -d ID_DEL_DISPOSITIVO
```

Para comprobar que el proyecto no presenta errores detectables mediante el analizador estático, utilizar:

```bash
flutter analyze
```

## Conclusión

La práctica permitió explorar diferentes widgets de Flutter y su aplicación en interfaces móviles, integrando navegación entre pantallas, animaciones, controles de interacción y gestión del estado mediante Riverpod.

Además, se organizó el proyecto en módulos para facilitar el mantenimiento y la incorporación de nuevas funcionalidades. La ejecución en un dispositivo Android permitió comprobar la presentación de la interfaz y continuar con las pruebas de funcionamiento de los componentes implementados.