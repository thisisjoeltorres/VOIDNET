import 'package:flutter/material.dart';
import 'package:voidnet/views/disclaimer_view.dart';
import 'package:voidnet/views/styles/spaces.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:voidnet/views/utils/custom-page-router.dart';
import 'package:voidnet/views/utils/shared_prefs.dart';
import 'package:voidnet/views/components/health_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeView extends StatefulWidget {

  const HomeView(
      {super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _healthPrompt = TextEditingController();
  late String? userName;

  @override
  void initState() {
    userName = '';
    super.initState();
    _loadUserData();
  }

  InputDecoration _buildDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      hintText: labelText,
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.tertiary,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      fillColor: Theme.of(context).colorScheme.onSurfaceVariant,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32.0),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline, width: 0.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32.0),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline, width: 0.0),
      ),
      border: const OutlineInputBorder(),
      suffixIcon: Icon(Icons.send_rounded, color: Colors.black)
    );
  }

  void _loadUserData() async {
    await SharedPrefs().reload();

    setState(() {
      userName = SharedPrefs().prefs.getString('userName') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
        child: SizedBox(
      height: screenHeight,
      width: screenWidth,
      child: Padding(
        padding: const EdgeInsets.only(
            top: 32.0, bottom: 32.0, left: 24.0, right: 24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        Theme.of(context).colorScheme.brightness == Brightness.light ? 'assets/images/brand/sentai-logo.svg' : 'assets/images/brand/sentai-logo-dark.svg',
                        height: 24,
                      ),
                      VerticalSpacing(32.0),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Stack(children: [
                CustomScrollView(slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      VerticalSpacing(16.0),
                      Text(
                        getLabelForTime(context),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16.0),
                        textAlign: TextAlign.start,
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      VerticalSpacing(8.0),
                      Text.rich(
                        textScaler: const TextScaler.linear(1.0),
                        TextSpan(
                            text: '${userName ?? AppLocalizations.of(context)!.guestTitle}, ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0, fontFamily: 'DMSans', color: Theme.of(context).colorScheme.onSurface),
                            children: <TextSpan>[
                              TextSpan(text: AppLocalizations.of(context)!.howAreYouFeelingToday,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24.0, fontWeight: FontWeight.normal, fontFamily: 'DMSans'),
                              )
                            ]
                        ),
                      ),
                      VerticalSpacing(24.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _healthPrompt,
                              decoration: _buildDecoration(AppLocalizations.of(context)!.howAreYouFeeling),
                              validator: (value) => value!.isEmpty ? "Required" : null,
                            ),
                            VerticalSpacing(8.0),
                          ],
                        ),
                      ),
                      VerticalSpacing(16.0),
                      Text(
                        style: Theme.of(context).textTheme.labelSmall,
                          "¿Estas preocupado por alguien?"
                      ),
                      VerticalSpacing(16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          HealthCard(onCardTap: () => {
                            Navigator.of(context).push(CustomPageRoute(DisclaimerView(isPersonalAnalysis: true,)))
                          }, cardText: "Quiero entender mis emociones"),
                          HealthCard(onCardTap: () => {}, cardText: "Estoy preocupado por alguien")
                        ],
                      ),
                      VerticalSpacing(24.0),
                      // Text(
                      //     style: Theme.of(context).textTheme.labelSmall,
                      //     "Mis conversaciones recientes"
                      // ),
                    ]),
                  ),
                ]),
                Positioned(
                  top: -1.0,
                  child: SizedBox(
                    width: screenWidth,
                    height: 24.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(1.0),
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: const SizedBox(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -1.0,
                  child: SizedBox(
                    width: screenWidth,
                    height: 24.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.0),
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(1.0),
                          ],
                        ),
                      ),
                      child: const SizedBox(),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    ));
  }

  String timeOfDay() {
    String dayOfTime = 'morning';
    final now = TimeOfDay.now();

    // Convert current time to DateTime
    final currentDateTime = DateTime.now();

    if (currentDateTime.hour > 12 && currentDateTime.hour < 18) {
      dayOfTime = 'afternoon';
    } else if (currentDateTime.hour >= 18 && currentDateTime.hour < 24) {
      dayOfTime = 'evening';
    }

    return dayOfTime;
  }

  String getLabelForTime(BuildContext context) {
    String currentTime = timeOfDay();

    if (currentTime == 'morning') {
      return AppLocalizations.of(context)!.goodMorning;
    } else if (currentTime == 'afternoon') {
      return AppLocalizations.of(context)!.goodAfternoon;
    } else {
      return AppLocalizations.of(context)!.goodEvening;
    }
  }
}
