import 'package:flutter/material.dart';
import 'analysis_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AnalysisScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1B4332),
        indicatorColor: const Color(0xFF52B788),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.camera_alt, color: Color(0xFF1B4332)),
            label: 'Analizar',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.history, color: Color(0xFF1B4332)),
            label: 'Historial',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
