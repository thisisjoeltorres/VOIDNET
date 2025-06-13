import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:voidnet/views/utils/shared_prefs.dart';
import 'package:voidnet/views/dashboard_view.dart';
import 'package:voidnet/views/onboarding_view.dart';
import 'package:voidnet/views/styles/themes.dart';
import 'l10n/l10n.dart';

Future<void> main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  String? userName = SharedPrefs().prefs.getString('userName');
  bool validUser = (userName != null);

  SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ]
  );

  runApp(
      MyApp(userExists: validUser)
  );
}

class MyApp extends StatefulWidget {
  final bool userExists;

  const MyApp({Key? key, required this.userExists}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movilidad',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.defaultLight,
      darkTheme: AppThemes.defaultDark,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: widget.userExists ? ShowCaseWidget(
        builder: (context) => const DashboardView(),
      ) : const OnboardingView(),
    );
  }
}