import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:voidnet/views/components/nav-button.dart';
import 'package:voidnet/views/utils/shared_prefs.dart';

class BottomNavbar extends StatefulWidget {
  final BuildContext context;
  final int currentIndex;
  final Function(int) onTap;
  const BottomNavbar({super.key, required this.currentIndex, required this.onTap, required this.context});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  bool isTourCompleted = true;
  GlobalKey homeNavKey = GlobalKey();
  GlobalKey chatNavKey = GlobalKey();
  GlobalKey historyNavKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkTourCompletion(widget.context);
  }

  void _checkTourCompletion(BuildContext context) async {
    try {
      bool? isTourCompleted = SharedPrefs().prefs.getBool('tourCompleted');

      if (isTourCompleted == null || !isTourCompleted) {
        _startShowcase();
      }
    } catch (e) {
      print('Error while checking tour completion: $e');
    }
  }

  void _startShowcase() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ShowCaseWidget.of(widget.context).startShowCase(
        [homeNavKey, chatNavKey, historyNavKey],
      );
    });
  }

  void _updateTourCompletion() async {
    await SharedPrefs().prefs.setBool('tourCompleted', true);
    await SharedPrefs().reload();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(64.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Showcase(
              key: homeNavKey,
              title: AppLocalizations.of(context)!.tourHome,
              tooltipBorderRadius: BorderRadius.circular(24.0),
              tooltipPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              targetPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
              targetBorderRadius: BorderRadius.circular(32.0),
              tooltipBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              titlePadding: const EdgeInsets.only(bottom: 8.0),
              scaleAnimationCurve: Curves.ease,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontFamily: 'Inter',
                color: Theme.of(context).colorScheme.onSurface,
              ),
              descTextStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
                fontFamily: 'Inter',
                color: Theme.of(context).colorScheme.tertiary,
              ),
              description: AppLocalizations.of(context)!.tourHomeDescription,
              child: GestureDetector(
                onTap: () => widget.onTap(0),
                child: NavButton(
                  icon: Icons.home_rounded,
                  selected: widget.currentIndex == 0,
                ),
              ),
            ),
            Showcase(
              key: chatNavKey,
              title: AppLocalizations.of(context)!.tourChat,
              tooltipBorderRadius: BorderRadius.circular(24.0),
              tooltipPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              targetPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
              targetBorderRadius: BorderRadius.circular(32.0),
              tooltipBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              titlePadding: const EdgeInsets.only(bottom: 8.0),
              scaleAnimationCurve: Curves.ease,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontFamily: 'Inter',
                color: Theme.of(context).colorScheme.onSurface,
              ),
              descTextStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
                fontFamily: 'Inter',
                color: Theme.of(context).colorScheme.tertiary,
              ),
              description: AppLocalizations.of(context)!.tourChatDescription,
              child: GestureDetector(
                onTap: () => widget.onTap(1),
                child: NavButton(
                  icon: Icons.chat_rounded,
                  selected: widget.currentIndex == 1,
                ),
              ),
            ),
            Showcase(
              key: historyNavKey,
              title: AppLocalizations.of(context)!.tourHistory,
              tooltipBorderRadius: BorderRadius.circular(24.0),
              tooltipPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              targetPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
              targetBorderRadius: BorderRadius.circular(32.0),
              tooltipBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              titlePadding: const EdgeInsets.only(bottom: 8.0),
              scaleAnimationCurve: Curves.ease,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontFamily: 'Inter',
                color: Theme.of(context).colorScheme.onSurface,
              ),
              descTextStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
                fontFamily: 'Inter',
                color: Theme.of(context).colorScheme.tertiary,
              ),
              description: AppLocalizations.of(context)!.tourHistoryDescription,
              child: GestureDetector(
                onTap: () => widget.onTap(2),
                child: NavButton(
                  icon: Icons.history_rounded,
                  selected: widget.currentIndex == 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}