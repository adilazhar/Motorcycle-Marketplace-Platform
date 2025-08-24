import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatefulWidget {
  const ScaffoldWithNavBar({super.key, required this.child});
  final Widget child;

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: StylishBottomBar(
        option: AnimatedBarOptions(iconStyle: IconStyle.animated),
        items: [
          BottomBarItem(
            icon: const Icon(CupertinoIcons.house),
            selectedIcon: const Icon(CupertinoIcons.house_fill),
            selectedColor: Colors.black,
            unSelectedColor: Colors.grey,
            title: const Text('Home'),
          ),
          BottomBarItem(
            icon: const Icon(CupertinoIcons.heart),
            selectedIcon: const Icon(CupertinoIcons.heart_fill),
            selectedColor: Colors.black,
            unSelectedColor: Colors.grey,
            title: const Text('Wishlist'),
          ),
          BottomBarItem(
              icon: const Icon(CupertinoIcons.square_list),
              selectedIcon: const Icon(CupertinoIcons.square_list_fill),
              selectedColor: Colors.black,
              unSelectedColor: Colors.grey,
              title: const Text('My Ads')),
          BottomBarItem(
              icon: const Icon(CupertinoIcons.person),
              selectedIcon: const Icon(CupertinoIcons.person_fill),
              selectedColor: Colors.black,
              unSelectedColor: Colors.grey,
              title: const Text('Account')),
        ],
        fabLocation: StylishBarFabLocation.center,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/wishlist');
              break;
            case 2:
              context.go('/my_ads');
              break;
            default:
              context.push('/account');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/sell');
        },
        backgroundColor: Colors.white,
        child: const Icon(
          CupertinoIcons.add,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
