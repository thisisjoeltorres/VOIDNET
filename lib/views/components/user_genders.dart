import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:voidnet/enums/enums.dart';

class UserGenders {
  static List<Gender> genderList = [
    Gender.male,
    Gender.female,
    Gender.nonBinary,
    Gender.other,
    Gender.unknown,
  ];

  static List<String> genderNames(BuildContext context) => [
    AppLocalizations.of(context)!.genderMale,
    AppLocalizations.of(context)!.genderFemale,
    AppLocalizations.of(context)!.genderNonBinary,
    AppLocalizations.of(context)!.genderOther,
    AppLocalizations.of(context)!.genderUnknown,
  ];
}