import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:ssh_client/presentation/screens/home/home_screen.dart';
import 'package:ssh_client/presentation/screens/snippet/snippet_screen.dart';
import 'package:ssh_client/presentation/screens/settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _index = i),
        children: const [
          HomeScreen(),
          SnippetScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: CircleNavBar(
        activeIcons: const [
          Icon(Icons.dns_rounded, color: Colors.black),
          Icon(Icons.code_rounded, color: Colors.black),
          Icon(Icons.settings_rounded, color: Colors.black),
        ],
        inactiveIcons: const [
          Icon(Icons.dns_outlined, color: Colors.white54),
          Icon(Icons.code_outlined, color: Colors.white54),
          Icon(Icons.settings_outlined, color: Colors.white54),
        ],
        height: 60,
        circleWidth: 50,
        color: const Color(0xFF0F0F0F),
        circleColor: const Color(0xFFB0B0B0),
        activeIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          _pageController.animateToPage(i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        },
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        cornerRadius: const BorderRadius.all(Radius.circular(24)),
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
