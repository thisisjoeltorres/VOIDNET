import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:voidnet/enums/enums.dart';

class UserAgeRanges {
  static List<AgeRange> ageRangeList = [
    AgeRange.under18,
    AgeRange.from18to24,
    AgeRange.from25to34,
    AgeRange.from35to44,
    AgeRange.from45to54,
    AgeRange.from55to64,
    AgeRange.over65,
    AgeRange.unknown,
  ];

  static List<String> ageRangeNames(BuildContext context) => [
    AppLocalizations.of(context)!.ageUnder18,
    AppLocalizations.of(context)!.ageFrom18to24,
    AppLocalizations.of(context)!.ageFrom25to34,
    AppLocalizations.of(context)!.ageFrom35to44,
    AppLocalizations.of(context)!.ageFrom45to54,
    AppLocalizations.of(context)!.ageFrom55to64,
    AppLocalizations.of(context)!.ageOver65,
    AppLocalizations.of(context)!.ageUnknown,
  ];
}
