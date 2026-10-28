import 'package:go_router/go_router.dart';

import '../../presentation/screen/animated/animated_screen.dart';
import '../../presentation/screen/app_tutorial/app_tutorial_screen.dart';
import '../../presentation/screen/buttons/buttons_screen.dart';
import '../../presentation/screen/cards/cards_screen.dart';
import '../../presentation/screen/counter/counter_screen.dart';
import '../../presentation/screen/home/home_screen.dart';
import '../../presentation/screen/infinite_scroll/infinite_scroll_screen.dart';
import '../../presentation/screen/progress/progress_screen.dart';
import '../../presentation/screen/snackbar/snackbar_screen.dart';
import '../../presentation/screen/theme_changer/theme_changer_screen.dart';
import '../../presentation/screen/ui_controls/ui_controls_screen.dart';

// GoRouter configuration
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/buttons',
      name: ButtonsScreen.name,
      builder: (context, state) => const ButtonsScreen(),
    ),

    GoRoute(
      path: '/cards',
      name: CardsScreen.name,
      builder: (context, state) => const CardsScreen(),
    ),

    GoRoute(
      path: '/progress',
      name: ProgressScreen.name,
      builder: (context, state) => const ProgressScreen(),
    ),

    GoRoute(
      path: '/snackbars',
      name: SnackbarScreen.name,
      builder: (context, state) => const SnackbarScreen(),
    ),

    GoRoute(
      path: '/animated',
      name: AnimatedScreen.name,
      builder: (context, state) => const AnimatedScreen(),
    ),

    GoRoute(
      path: '/ui-controls',
      name: UiControlsScreen.name,
      builder: (context, state) => const UiControlsScreen(),
    ),

    GoRoute(
      path: '/tutorial',
      name: AppTutorialScreen.name,
      builder: (context, state) => const AppTutorialScreen(),
    ),

    GoRoute(
      path: '/infinite',
      name: InfiniteScrollScreen.name,
      builder: (context, state) => const InfiniteScrollScreen(),
    ),

    GoRoute(
      path: '/counter-river',
      name: CounterScreen.name,
      builder: (context, state) => const CounterScreen(),
    ),

    GoRoute(
      path: '/theme-changer',
      name: ThemeChangerScreen.name,
      builder: (context, state) => const ThemeChangerScreen(),
    ),
  ],
);
