import 'package:go_router/go_router.dart';
import 'package:cinemapedia/presentation/screens/screens.dart';

/// Rutas de Cinemapedia.
///
/// * `/`                       → pantalla de carga (inicialización).
/// * `/home/:page`             → Inicio (0), Categorías (1), Favoritos (2).
/// * `/home/:page/movie/:id`   → detalle de película.
/// * `/settings`               → configuración de país e idioma.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [

    GoRoute(
      path: '/',
      name: SplashScreen.name,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      builder: (context, state) {
        final page = int.tryParse(state.pathParameters['page'] ?? '0') ?? 0;
        return HomeScreen(pageIndex: page.clamp(0, HomeScreen.pageCount - 1));
      },
      routes: [
        GoRoute(
          path: 'movie/:id',
          name: MovieScreen.name,
          builder: (context, state) {
            final movieId = state.pathParameters['id'] ?? 'no-id';
            return MovieScreen(movieId: movieId);
          },
        ),
      ],
    ),

    // Compatibilidad con enlaces antiguos a /movie/:id.
    GoRoute(
      path: '/movie/:id',
      redirect: (context, state) => '/home/0/movie/${state.pathParameters['id']}',
    ),

    GoRoute(
      path: '/settings',
      name: SettingsScreen.name,
      builder: (context, state) => const SettingsScreen(),
    ),

  ],
);
