import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:voidnet/views/components/bottom-navbar.dart';
import 'package:voidnet/views/home_view.dart';
import 'package:voidnet/views/utils/custom-page-router.dart';

class DashboardView extends StatefulWidget {
  final int customIndex;
  const DashboardView({super.key, this.customIndex = 0});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late String? userName;
  int _currentIndex = 0;
  bool isCronRunning = false;
  late ScheduledTask cronTask;
  late final cron = Cron();

  @override
  void initState() {
    _currentIndex = widget.customIndex;
    super.initState();
  }

  void _handleRoutesTap() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeView(
      ),
    ];

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BottomNavbar(
              context: context,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
        body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _screens[_currentIndex])
    );
  }
}