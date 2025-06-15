import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:voidnet/enums/enums.dart';
import 'package:voidnet/models/UserData.dart';
import 'package:voidnet/views/components/get_started_name.dart';
import 'package:voidnet/views/components/get_started_gender.dart';
import 'package:voidnet/views/components/get_started_age_range.dart';
import 'package:voidnet/views/components/onboarding_outro.dart';
import 'package:voidnet/views/components/primary_button.dart';
import 'package:voidnet/views/components/progress_nav.dart';
import 'package:voidnet/views/onboarding_view.dart';
import 'package:voidnet/views/utils/custom-page-router.dart';
import 'package:voidnet/views/utils/shared_prefs.dart';

class OnboardingFrame extends StatefulWidget {
  @override
  State<OnboardingFrame> createState() => _OnboardingFrameState();
}

class _OnboardingFrameState extends State<OnboardingFrame> with SingleTickerProviderStateMixin {
  late int currentStep;
  late UserData userData;

  late AnimationController _controller;
  double progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    currentStep = 0;
    userData = UserData(userName: '');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increaseProgress() {
    if (progressValue < 1.0) {
      setState(() {
        progressValue += (100 / 3) / 100;
      });
    }
  }

  void _decreaseProgress() {
    if (progressValue > 0.0) {
      setState(() {
        progressValue -= (100 / 3) / 100;
      });
    }
  }

  void _updateStep(dynamic value) {
    setState(() {
      switch (currentStep) {
        case 0:
          userData.userName = value as String;
          break;
        case 1:
          userData.userGender = value;
          break;
        case 2:
          userData.userAgeRange = value;
          break;
      }
    });
  }

  void _updatePreviousStep() {
    setState(() {
      if (currentStep > 0) {
        setState(() {
          _decreaseProgress();
          currentStep--;
        });
      } else {
        Navigator.of(context).push(CustomPageRoute(const OnboardingView()));
      }
    });
  }

  void _nextStep() {
    if (_isValidInput()) {
      if (currentStep < 2) {
        setState(() {
          _increaseProgress();
          currentStep++;
        });
      } else {
        _saveUserData();
        Navigator.of(context).push(CustomPageRoute(const OnboardingOutro()));
      }
    }
  }

  bool _isValidInput() {
    switch (currentStep) {
      case 0:
        return userData.userName.isNotEmpty;
      case 1:
        return userData.userGender != Gender.unknown;
      case 2:
        return userData.userAgeRange != AgeRange.unknown;
      default:
        return false;
    }
  }

  void _saveUserData() async {
    await SharedPrefs().prefs.setString('userName', userData.userName);
    await SharedPrefs().prefs.setInt('userGender', userData.userGender.index);
    await SharedPrefs().prefs.setInt('userAgeRange', userData.userAgeRange.index);
    await SharedPrefs().prefs.setBool('enableReminders', true);
    await SharedPrefs().prefs.setBool('tourCompleted', false);
    await SharedPrefs().reload();
  }

  bool _isContinueButtonEnabled() {
    switch(currentStep) {
      case 0:
        return userData.userName.isNotEmpty;
      case 1:
        return userData.userGender != Gender.unknown;
      case 2:
        return userData.userAgeRange != AgeRange.unknown;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Column(
          children: [
            SizedBox(
              height: 60,
              width: screenWidth,
              child: ProgressNav(
                  progressValue: progressValue,
                  onBackPressed: _updatePreviousStep),
            ),
            Expanded(
              child: _buildCurrentStep(),
            ),
            PrimaryButton(
              onButtonPressed: _nextStep,
              buttonText: AppLocalizations.of(context)!.continueNext,
              isButtonEnabled: _isContinueButtonEnabled(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return GetStartedName(
          userData: userData,
          onNameChanged: _updateStep,
        );
      case 1:
        return GetStartedGender(
          userData: userData,
          onGenderChanged: _updateStep,
        );
      case 2:
        return GetStartedAgeRange(
          userData: userData,
          onAgeRangeChanged: _updateStep,
        );
      default:
        return Container();
    }
  }
}
