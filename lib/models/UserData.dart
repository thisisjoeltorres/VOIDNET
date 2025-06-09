import 'package:voidnet/enums/enums.dart';

class UserData {
  String userName;
  Gender userGender = Gender.unknown;
  AgeRange userAgeRange = AgeRange.unknown;
  bool termsAccepted = false;

  UserData({
    required this.userName
  });
}
