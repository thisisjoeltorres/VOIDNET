import 'package:flutter/material.dart';
import 'package:voidnet/views/styles/spaces.dart';

class HealthCard extends StatefulWidget {
  final VoidCallback onCardTap;
  final String cardText;

  const HealthCard({super.key, required this.onCardTap, required this.cardText});

  @override
  State<HealthCard> createState() => _HealthCardState();
}

class _HealthCardState extends State<HealthCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(24.0),
        onTap: widget.onCardTap,
        child: SizedBox(
          width: (screenWidth * 0.5) - 32,
          child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE2E2E2), width: 1.0),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0), bottomLeft: Radius.circular(16.0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(widget.cardText, style: TextStyle(color: Theme.of(context).colorScheme.onSurface),),
                    VerticalSpacing(24.0),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.north_east_rounded,
                            size: 24.0,
                            color: Theme.of(context).colorScheme.surface)
                      ),
                    )
                  ],
                ),
              )
          ),
        ),
      ),
    );
  }
}
