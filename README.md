# Repositorio de Prácticas para Desarrollo Móvil Integral

<div align="center">
  <img src="LOGOS/LOGO%20UTXJ%20PNG.png" alt="Logotipo de la UTXJ" height="110">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="LOGOS/LOGO%20TIC%20(4).png" alt="Logotipo de la carrera TIC" height="110">

  <h2>Desarrollo Móvil Integral</h2>
  <p><strong>Portafolio académico de prácticas de desarrollo de aplicaciones móviles</strong></p>

  Flutter · Dart · Material Design 3

  <p>
    <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
    <a href="https://dart.dev/"><img src="https://img.shields.io/badge/Dart-Lenguaje-0175C2?logo=dart&logoColor=white" alt="Dart"></a>
    <a href="https://m3.material.io/"><img src="https://img.shields.io/badge/Material%20Design-3-757575?logo=materialdesign&logoColor=white" alt="Material Design 3"></a>
    <a href="https://pub.dev/packages/go_router"><img src="https://img.shields.io/badge/GoRouter-Navegaci%C3%B3n-02569B" alt="GoRouter"></a>
    <a href="https://riverpod.dev/"><img src="https://img.shields.io/badge/Riverpod-Gesti%C3%B3n%20de%20estado-167DAD" alt="Riverpod"></a>
  </p>

  <a href="https://github.com/KouDionicio/Practicas_DMI_230237">Ver repositorio en GitHub</a>
</div>

---

## 🎯 Objetivo

Desarrollar competencias en la creación de aplicaciones móviles multiplataforma mediante **Flutter y Dart**, aplicando conceptos de diseño de interfaces, widgets, navegación, funciones, gestión de estado, personalización visual y organización modular del código.

Este repositorio reúne las prácticas realizadas durante la asignatura **Desarrollo Móvil Integral**, junto con sus respectivas descripciones, evidencias y documentación técnica.

## 🛠️ Tecnologías utilizadas

| Tecnología | Aplicación en el proyecto |
|:---:|---|
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" alt="Flutter" width="36"> **Flutter** | Desarrollo de interfaces y aplicaciones multiplataforma. |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg" alt="Dart" width="36"> **Dart** | Lenguaje de programación utilizado por Flutter. |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/android/android-original.svg" alt="Android" width="36"> **Android** | Ejecución y validación de las aplicaciones móviles. |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/git/git-original.svg" alt="Git" width="36"> **Git** | Control de versiones del código fuente. |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/github/github-original.svg" alt="GitHub" width="36"> **GitHub** | Alojamiento del repositorio y colaboración. |
| **GitHub Pages** | Publicación de documentación, diagramas y contenidos web. |

En las prácticas que lo requieren también se utilizan herramientas y paquetes como **GoRouter**, **Riverpod**, **animate_do** y **Material Design 3**.

---

## 📚 Prácticas realizadas

| N.º | Práctica | Descripción | Potenciador | Estado |
|:---:|---|---|:---:|:---:|
| 01 | Metodología de Evaluación de la Materia | Revisión de los criterios de evaluación, actividades, prácticas y evidencias de la asignatura. | 5 | Completada |
| 02 | [Mi primera aplicación móvil con Flutter](Practica02/hello_world_app/README.md) | Desarrollo de una aplicación básica con Flutter y Dart, utilizando widgets e interfaz para Android. | 25 | Completada |
| 03 | [Yes, No, Maybe — Chat con API de Respuestas Automáticas](Practica03/yes_no_app/README.md) | Aplicación de chat que consulta la API de yesno.wtf y muestra respuestas Sí, No o Tal vez con sus GIF correspondientes. | 30 | Completada |
| 04 | [TokTik — Feed de videos cortos](Practica04/toktik/README.md) | Aplicación Flutter con un feed vertical de videos, navegación mediante gestos y funcionalidades de reproducción. | 30 | Completada |
| 05 | [Widgets App](Practica05/widget_app/README.md) | Aplicación demostrativa de componentes de Material Design 3, navegación con GoRouter, gestión de estado con Riverpod y animaciones. | 40 | Completada |

> **Nota:** Mantén actualizado el estado de cada práctica de acuerdo con su implementación y validación reales.

## 📂 Organización del repositorio

```text
Practicas_DMI_230237/
├── LOGOS/
│   ├── LOGO UTXJ PNG.png
│   └── LOGO TIC (4).png
├── docs/
│   └── Documentación para GitHub Pages
├── Practica02/
│   └── hello_world_app/
│       └── README.md
├── Practica03/
│   └── yes_no_app/
│       └── README.md
├── Practica04/
│   └── toktik/
│       └── README.md
├── Practica05/
│   └── widget_app/
│       └── README.md
└── README.md
```

*La estructura mostrada es una referencia. Conserva las carpetas y los archivos adicionales que existan en el repositorio.*

## 📖 Documentación y evidencias

Cada práctica dispone de su propio archivo `README.md`, donde se describen sus características, tecnologías, instrucciones de ejecución y evidencias correspondientes.

El directorio `docs/` se utiliza para publicar contenidos web mediante GitHub Pages. Puede incluir el índice de documentación y diagramas interactivos de arquitectura sin sustituir los proyectos Flutter.

## ▶️ Ejecución de los proyectos Flutter

Para ejecutar una práctica, abre una terminal en el directorio que contiene su archivo `pubspec.yaml`.

Por ejemplo, para **Widgets App**:

```powershell
cd Practica05/widget_app
flutter pub get
flutter analyze
flutter test
flutter run
```

### Requisitos

- Tener instalado el [SDK de Flutter](https://docs.flutter.dev/get-started/install).
- Contar con Dart, incluido con Flutter.
- Disponer de un emulador o dispositivo Android compatible.
- Tener configuradas las herramientas necesarias para compilar y ejecutar la aplicación.

## 🌿 Control de versiones

El código fuente de las prácticas se administra mediante **Git** y se almacena en GitHub. Se utilizan ramas para organizar el trabajo y facilitar la integración de cambios.

## ✅ Conclusión

Este repositorio constituye un portafolio académico del aprendizaje adquirido en Desarrollo Móvil Integral. Las prácticas permiten aplicar progresivamente los fundamentos de Flutter y Dart, desde la creación de interfaces básicas hasta el desarrollo de aplicaciones con navegación, contenido dinámico, gestión de estado y componentes interactivos.

La documentación y las evidencias complementan el código fuente y facilitan la revisión del trabajo realizado a lo largo de la asignatura.

---

<div align="center">
  <strong>Desarrollo Móvil Integral · Portafolio de prácticas · Flutter & Dart</strong>
  <br>
  <sub>Universidad Tecnológica de Xicotepec de Juárez · TIC</sub>
</div>