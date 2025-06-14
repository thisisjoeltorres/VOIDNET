import 'package:flutter/material.dart';
import 'package:voidnet/views/styles/spaces.dart';

class HistoryCard extends StatelessWidget {
  final VoidCallback onCardTap;
  final String historyTitle;
  final String historyDate;

  const HistoryCard({super.key, required this.onCardTap, required this.historyTitle, required this.historyDate});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.0),
      onTap: onCardTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            width: 1.0,
            color: Color(0xFFE2E2E2)
          )
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFFCEADF),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.forum_rounded, color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              HorizontalSpacing(16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    historyTitle, // 'Analisis para Benito'
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  VerticalSpacing(4.0),
                  Text(
                    historyDate, // '12/02/25 a las 12:00 P.M.'
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFF5F677F),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
