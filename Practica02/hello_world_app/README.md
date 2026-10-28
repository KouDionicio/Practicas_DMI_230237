# Práctica 01: Hello World App

<div align="center">
  <table>
    <tr>
      <td align="center" valign="middle">
        <img src="../../LOGOS/LOGO%20UTXJ%20PNG.png" alt="Logotipo de la UTXJ" height="90">
      </td>
      <td align="center" valign="middle">
        <img src="../../LOGOS/LOGO%20TIC%20(4).png" alt="Logotipo de Tecnologías de la Información y Comunicación" height="90">
      </td>
    </tr>
  </table>

  ### Desarrollo Móvil Integral

  **Introducción al desarrollo de aplicaciones móviles con Flutter**

  [![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-Lenguaje-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
  [![Android](https://img.shields.io/badge/Android-Plataforma-3DDC84?logo=android&logoColor=white)](https://developer.android.com/)
  [![Material Design](https://img.shields.io/badge/Material%20Design-Interfaz-757575?logo=materialdesign&logoColor=white)](https://m3.material.io/)
  [![GitHub](https://img.shields.io/badge/GitHub-Código%20fuente-181717?logo=github&logoColor=white)](https://github.com/)

  **[Ver repositorio en GitHub](https://github.com/KouDionicio/Practicas_DMI_230237)**

  **[Consultar diagrama de arquitectura](https://koudionicio.github.io/Practicas_DMI_230237/project_architecture.html)**
</div>

---

## Descripción

Esta práctica consiste en la creación de una aplicación básica con Flutter y Dart para familiarizarse con el entorno de desarrollo, la estructura de un proyecto móvil y la ejecución de una aplicación sencilla en un dispositivo, emulador o navegador.

El proyecto incluye una interfaz de contador que permite incrementar y decrementar valores, mostrando diferentes colores para representar el estado numérico.

## Objetivo

Aprender a crear, ejecutar y comprender una aplicación mínima en Flutter, identificando los elementos esenciales de un proyecto móvil y familiarizándose con la estructura del código, los widgets y la ejecución multiplataforma.

## Tecnologías utilizadas

| Tecnología | Icono | Aplicación |
|---|---|---|
| **Flutter** | <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" alt="Flutter" width="28"> | Framework para crear la interfaz de usuario. |
| **Dart** | <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg" alt="Dart" width="28"> | Lenguaje de programación de la aplicación. |
| **Material Design** | <img src="https://cdn.simpleicons.org/materialdesign/757575" alt="Material Design" width="28"> | Componentes y estilos visuales. |
| **Android** | <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/android/android-original.svg" alt="Android" width="28"> | Plataforma para ejecutar y probar la aplicación. |
| **Git y GitHub** | <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/github/github-original.svg" alt="GitHub" width="28"> | Control de versiones y alojamiento del código fuente. |

## Actividades realizadas

- Inicialización del proyecto Flutter.
- Configuración del entorno de trabajo.
- Creación de la interfaz principal con un contador interactivo.
- Implementación de acciones para incrementar y decrementar el contador.
- Representación visual de valores positivos, negativos y del valor inicial.
- Ejecución de la aplicación en un emulador, dispositivo o navegador.
- Revisión de la estructura del proyecto y sus archivos principales.
- Consulta del diagrama de arquitectura para comprender la organización general.

## Funcionalidades

- **Contador inicial:** comienza en cero.
- **Incremento:** permite aumentar el valor del contador.
- **Decremento:** permite disminuir el valor del contador.
- **Indicadores de color:** azul para el valor inicial, verde para valores positivos y rojo para valores negativos, de acuerdo con las evidencias proporcionadas.
- **Interfaz interactiva:** actualiza el valor visible después de cada acción.

## Capturas de pantalla

Las evidencias se presentan en una cuadrícula de dos columnas para mantener un tamaño moderado y facilitar su comparación.

<table>
  <tr>
    <td align="center" width="50%">
      <strong>1. Contador en cero</strong><br><br>
      <img src="image/1.png" alt="Contador en cero de color azul" width="260"><br>
      <em>Valor inicial del contador antes de realizar alguna acción.</em>
    </td>
    <td align="center" width="50%">
      <strong>2. Números positivos</strong><br><br>
      <img src="image/2.png" alt="Contador con valores positivos de color verde" width="260"><br>
      <em>Incremento del contador y representación de valores positivos.</em>
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <strong>3. Números negativos</strong><br><br>
      <img src="image/3.png" alt="Contador con valores negativos de color rojo" width="260"><br>
      <em>Decremento del contador y representación de valores negativos.</em>
    </td>
    <td align="center" width="50%">
      <strong>Resumen de la práctica</strong><br><br>
      <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" alt="Icono de Flutter" width="80"><br>
      <em>Primera aproximación al desarrollo de interfaces con Flutter.</em>
    </td>
  </tr>
</table>

## Ejecución de la aplicación

Instala Flutter y configura un dispositivo, emulador o navegador compatible. Desde la carpeta raíz del proyecto, ejecuta:

```bash
flutter pub get
flutter run
```

Para comprobar el código y ejecutar las pruebas, si el proyecto dispone de ellas:

```bash
flutter analyze
flutter test
```

## Diagrama de arquitectura

Consulta el diagrama publicado mediante GitHub Pages:

<div align="center">

[![Diagrama de arquitectura](https://img.shields.io/badge/Ver-Diagrama%20de%20arquitectura-6C5CE7?logo=githubpages&logoColor=white)](https://koudionicio.github.io/Practicas_DMI_230237/project_architecture.html)

**[Abrir diagrama de arquitectura](https://koudionicio.github.io/Practicas_DMI_230237/project_architecture.html)**

</div>

El diagrama complementa las evidencias visuales y permite consultar la organización general del proyecto.

## Resultados

Se creó una aplicación básica en Flutter con una interfaz funcional de contador. Se practicó la configuración del entorno, la construcción de widgets interactivos, la actualización de la interfaz y la ejecución del proyecto.

Las capturas documentan los estados del contador y el diagrama de arquitectura proporciona una referencia adicional para comprender la estructura de la aplicación.

## Conclusión

La práctica constituye una introducción al desarrollo móvil con Flutter y Dart. A través de una aplicación sencilla se exploran los fundamentos de la interfaz de usuario, la interacción, la actualización de estado y la organización de un proyecto, sentando las bases para desarrollar aplicaciones más complejas.

---

<div align="center">

**Práctica 01 · Desarrollo Móvil Integral**

*Flutter · Dart · Fundamentos del desarrollo móvil*

[Repositorio en GitHub](https://github.com/KouDionicio/Practicas_DMI_230237) · [Diagrama de arquitectura](https://koudionicio.github.io/Practicas_DMI_230237/project_architecture.html)

</div>