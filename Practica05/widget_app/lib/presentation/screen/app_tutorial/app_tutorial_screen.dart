import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SlideInfo {
  const SlideInfo(this.title, this.caption, this.icon);

  final String title;
  final String caption;
  final IconData icon;
}

const slides = <SlideInfo>[
  SlideInfo(
    'Explora los widgets',
    'Conoce los componentes y patrones de interfaz de Flutter.',
    Icons.widgets_outlined,
  ),
  SlideInfo(
    'Prueba cada control',
    'Interactúa con botones, tarjetas, indicadores y controles.',
    Icons.touch_app_outlined,
  ),
  SlideInfo(
    'Personaliza la app',
    'Cambia el color principal y alterna entre los temas claro y oscuro.',
    Icons.palette_outlined,
  ),
];

class AppTutorialScreen extends StatefulWidget {
  static const name = 'tutorial_screen';

  const AppTutorialScreen({super.key});

  @override
  State<AppTutorialScreen> createState() => _AppTutorialScreenState();
}

class _AppTutorialScreenState extends State<AppTutorialScreen> {
  final PageController pageController = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == slides.length - 1;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: slides.length,
            onPageChanged: (page) => setState(() => currentPage = page),
            itemBuilder: (context, index) => _Slide(slide: slides[index]),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            right: 20,
            child: TextButton(
              onPressed: () => context.pop(),
              child: const Text('Salir'),
            ),
          ),
          Positioned(
            bottom: 34,
            left: 28,
            child: Text('${currentPage + 1} / ${slides.length}'),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: isLastPage
                ? FadeInRight(
                    from: 15,
                    child: FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Comenzar'),
                    ),
                  )
                : FilledButton.icon(
                    onPressed: () => pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Siguiente'),
                  ),
          ),
          Positioned(
            bottom: 42,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == currentPage ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == currentPage
                        ? colors.primary
                        : colors.outlineVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final SlideInfo slide;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Icon(slide.icon, size: 112, color: colors.primary)),
              const SizedBox(height: 32),
              Text(
                slide.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(slide.caption, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
