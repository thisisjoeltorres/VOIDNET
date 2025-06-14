import 'package:flutter/material.dart';
import 'package:voidnet/views/styles/spaces.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmptyHistory extends StatelessWidget {
  const EmptyHistory({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        width: screenWidth * 0.6,
        child: Column(
          children: [
            VerticalSpacing(32.0),
            Image.asset(
              "assets/images/illustrations/kana-sleeping.png",
              width: screenWidth * 0.4,
            ),
            VerticalSpacing(16.0),
            Text(
              AppLocalizations.of(context)!.noHistoryYet,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface
              ),
              textScaler: TextScaler.linear(1.0),
            ),
          ],
        ),
      ),
    );
  }
}
