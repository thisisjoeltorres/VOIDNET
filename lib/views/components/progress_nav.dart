import 'package:flutter/material.dart';

class ProgressNav extends StatelessWidget {
  final double progressValue;
  final bool hasBackButton;
  final VoidCallback onBackPressed;

  const ProgressNav({Key? key, required this.progressValue, required this.onBackPressed, this.hasBackButton = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          hasBackButton ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: onBackPressed,
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24.0,
              ),
            ),
          ) : SizedBox(),
          Flexible(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progressValue),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  semanticsLabel: 'Onboarding progress indicator',
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onSurface),
                );
              },
            ),
          ),
          Padding(
            padding: hasBackButton ? EdgeInsets.only(left: 24.0, right: 24.0) : EdgeInsets.only(left: 16.0, right: 8.0),
            child: Text(
              '${(progressValue * 100).round()}%',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.0,
                color: Theme.of(context).colorScheme.onSurface
              ),
              textScaler: const TextScaler.linear(1.0),
            ),
          ),
        ],
      ),
    );
  }
}
