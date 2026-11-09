import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';


class CustomBottomNavigation extends StatelessWidget {

  final int currentIndex;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex
  });

  void onItemTapped( BuildContext context, int index ) {
    if ( index == currentIndex ) return;
    context.go('/home/$index');
  }


  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (value) => onItemTapped(context, value),
      elevation: 0,
      items: [
        BottomNavigationBarItem(
          icon: const Icon( Icons.home_outlined ),
          activeIcon: const Icon( Icons.home_rounded ),
          label: l10n.navHome
        ),
        BottomNavigationBarItem(
          icon: const Icon( Icons.category_outlined ),
          activeIcon: const Icon( Icons.category_rounded ),
          label: l10n.navCategories
        ),
        BottomNavigationBarItem(
          icon: const Icon( Icons.favorite_outline_rounded ),
          activeIcon: const Icon( Icons.favorite_rounded ),
          label: l10n.navFavorites
        ),
      ]
    );
  }
}
