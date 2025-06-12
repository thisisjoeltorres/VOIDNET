import 'package:flutter/material.dart';
import 'package:voidnet/views/components/primary_button.dart';
import 'package:voidnet/views/personal_analysis_view.dart';
import 'package:voidnet/views/styles/spaces.dart';
import 'package:voidnet/views/utils/custom-page-router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DisclaimerView extends StatefulWidget {
  final bool isPersonalAnalysis;

  const DisclaimerView({Key? key, required this.isPersonalAnalysis}) : super(key: key);

  @override
  State<DisclaimerView> createState() => _DisclaimerViewState();
}

class _DisclaimerViewState extends State<DisclaimerView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          widget.isPersonalAnalysis ? AppLocalizations.of(context)!.personalAnalysis : AppLocalizations.of(context)!.caringAnalysis,
          style: Theme.of(context).textTheme.labelLarge,
          textScaler: const TextScaler.linear(1.0),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {
            Navigator.of(context).pop()
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.personalDisclaimerTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600
                )
              ),
              VerticalSpacing(8.0),
              Text(
                AppLocalizations.of(context)!.personalDisclaimerInfo,
                style: Theme.of(context).textTheme.bodyMedium
              ),
              VerticalSpacing(16.0),
              const Spacer(),
              PrimaryButton(
                buttonText: AppLocalizations.of(context)!.continueNext,
                onButtonPressed: () => {
                  Navigator.of(context).push(CustomPageRoute(PersonalAnalysisView(isPersonalAnalysis: true, onAnalysisSaved: () => {})))
                },
                hasPadding: false,
                isButtonEnabled: true
              ),
            ],
          ),
        ),
      ),
    );
  }
}