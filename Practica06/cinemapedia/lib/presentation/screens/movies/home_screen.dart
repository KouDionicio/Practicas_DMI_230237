import 'package:flutter/material.dart';

import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:cinemapedia/presentation/views/views.dart';



class HomeScreen extends StatelessWidget {

  static const name = 'home-screen';
  static const pageCount = 3;
  final int pageIndex;

  const HomeScreen({
    super.key,
    required this.pageIndex
  });

  final viewRoutes =  const <Widget>[
    HomeView(),
    CategoriesView(),
    FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menú hamburguesa: se abre con el botón o deslizando desde el borde.
      drawer: SideMenu(currentIndex: pageIndex),
      drawerEnableOpenDragGesture: true,
      body: IndexedStack(
        index: pageIndex,
        children: viewRoutes,
      ),
      bottomNavigationBar: CustomBottomNavigation( currentIndex: pageIndex ),
    );
  }
}
