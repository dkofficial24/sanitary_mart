import 'package:flutter/material.dart';
import 'package:molten_navigationbar_flutter/molten_navigationbar_flutter.dart';
import 'package:sanitary_mart/cart/ui/screen/cart_screen.dart';
import 'package:sanitary_mart/category/ui/screen/category_screen.dart';
import 'package:sanitary_mart/profile/ui/screen/user_profile_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({this.selectedTab=0,super.key});
  final int selectedTab;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  List<Widget> tabScreens = [
    const CategoryScreen(),
    //const CategoryScreen(),
    const CartScreen(
    ),
    const UserProfileTab()
  ];

  @override
  void initState() {
    _selectedIndex = widget.selectedTab;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabScreens[_selectedIndex],
      bottomNavigationBar: MoltenBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabChange: (clickedIndex) {
          setState(() {
            _selectedIndex = clickedIndex;
          });
        },
        tabs: [
          MoltenTab(
            icon: const Icon(Icons.home_outlined),
          ),
          // MoltenTab(
          //   icon: const Icon(Icons.category_outlined),
          // ),
          MoltenTab(
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          MoltenTab(
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
    );
  }
}
