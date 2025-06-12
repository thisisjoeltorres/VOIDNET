import 'package:flutter/material.dart';
import 'package:voidnet/views/chatbot_view.dart';
import 'package:voidnet/views/components/primary_button.dart';
import 'package:voidnet/views/components/progress_nav.dart';
import 'package:voidnet/views/styles/spaces.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PersonalAnalysisView extends StatefulWidget {
  final bool isPersonalAnalysis;
  final VoidCallback onAnalysisSaved;

  const PersonalAnalysisView({super.key, required this.onAnalysisSaved, required this.isPersonalAnalysis});

  @override
  State<PersonalAnalysisView> createState() => _PersonalAnalysisViewState();
}

class _PersonalAnalysisViewState extends State<PersonalAnalysisView> {
  List<Map<String, dynamic>> _responses = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  List<int> _selectedMultiOptions = [];
  Map<int, int> _likertResponses = {};
  final TextEditingController _textController = TextEditingController();
  double progressValue = 0.0;

  final List<Color> optionColors = [
    Color(0xFFE0FAE4),
    Color(0xFFE0F0F8),
    Color(0xFFE0E4F8),
    Color(0xFFFADFF8),
    Color(0xFFFCD4D2),
  ];

  final List<Map<String, dynamic>> _questions = [
    {
      'type': 'single',
      'question': 'Primero que todo, ¿Cómo te sientes hoy?',
      'icons': [
        Icons.sentiment_very_satisfied_rounded,
        Icons.sentiment_satisfied_rounded,
        Icons.sentiment_neutral_rounded,
        Icons.sentiment_dissatisfied_rounded,
        Icons.sentiment_very_satisfied_rounded,
      ],
      'options': [
        'Me siento bastante bien',
        'Me siento bien',
        'Ni bien ni mal',
        'Me siento algo mal',
        'Me siento bastante mal',
      ]
    },
    {
      'type': 'multiple',
      'question': '¿Qué te motivó a hacer este análisis hoy? (Selecciona todas las que apliquen)',
      'icons': [
        Icons.sentiment_very_satisfied_rounded,
        Icons.sentiment_satisfied_rounded,
        Icons.sentiment_neutral_rounded,
        Icons.sentiment_dissatisfied_rounded,
        Icons.sentiment_very_satisfied_rounded,
      ],
      'options': [
        'Sentirme escuchado',
        'Entenderme mejor',
        'Estoy triste',
        'Siento que algo no está bien',
        'Me siento culpable',
      ]
    },
    {
      'type': 'text',
      'question': 'Si deseas, puedes escribir algo más sobre cómo te sientes hoy:',
    },
    {
      'type': 'likert',
      'question': 'Durante los últimos 7 días, ¿con qué frecuencia te has sentido así?',
      'subQuestions': [
        'Poco interés o placer en hacer cosas',
        'Sentirse decaído, deprimido o sin esperanza',
        'Dificultad para dormir o dormir en exceso',
        'Sentirse cansado o con poca energía',
        'Poca autoestima o sentimiento de inutilidad',
      ],
      'scale': ['Nunca', 'Raramente', 'A veces', 'A menudo', 'Siempre']
    },
    {
      'type': 'likert',
      'question': '¿Cómo han estado tus relaciones últimamente?',
      'subQuestions': [
        'Familiares',
        'Amigos',
        'Pareja',
      ],
      'scale': ['Bien', 'Normal', 'Mal']
    },
  ];

  void _increaseProgress() {
    if (progressValue < 1.0) {
      setState(() {
        progressValue += (100 / _questions.length) / 100;
      });
    }
  }

  void _decreaseProgress() {
    if (progressValue > 0.0) {
      setState(() {
        progressValue -= (100 / _questions.length) / 100;
      });
    }
  }

  void _nextQuestion() {
    final currentType = _questions[_currentQuestionIndex]['type'];
    final currentQuestion = _questions[_currentQuestionIndex];
    bool canContinue = false;

    dynamic answer;

    if (currentType == 'single') {
      canContinue = _selectedOptionIndex != null;
      answer = _selectedOptionIndex;
    } else if (currentType == 'multiple') {
      canContinue = _selectedMultiOptions.isNotEmpty;
      answer = _selectedMultiOptions;
    } else if (currentType == 'text') {
      canContinue = _textController.text.trim().length <= 1000;
      answer = _textController.text.trim();
    } else if (currentType == 'likert') {
      canContinue = _likertResponses.length == currentQuestion['subQuestions'].length;
      answer = Map.from(_likertResponses);
    }

    if (canContinue) {
      _responses.add({
        'type': currentType,
        'question': currentQuestion['question'],
        'answer': answer,
      });

      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _increaseProgress();
          _currentQuestionIndex++;
          _selectedOptionIndex = null;
          _selectedMultiOptions = [];
          _likertResponses = {};
          _textController.clear();
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatbotView(responses: _responses),
          ),
        );
      }
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _decreaseProgress();
        _currentQuestionIndex--;
        _selectedOptionIndex = null;
        _selectedMultiOptions = [];
        _likertResponses = {};
        _textController.clear();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildOptionBox(int currentIndex, IconData currentIcon, String currentText) {
    return Row(
      children: [
        DecoratedBox(
          decoration:
          BoxDecoration(
            color: optionColors[currentIndex],
            borderRadius: BorderRadius.circular(16.0),
          ), child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
              currentIcon,
              color: Theme.of(context).colorScheme.onSurface
          ),
        ),
        ),
        HorizontalSpacing(8.0),
        Expanded(
            child: Text(
              currentText,
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface
              ),
            )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final String type = currentQuestion['type'];

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
          onPressed: _previousQuestion,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, right: 24.0, left: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProgressNav(
                  progressValue: progressValue,
                  hasBackButton: false,
                  onBackPressed: _previousQuestion,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height - 192,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      VerticalSpacing(24.0),
                      Text(
                        currentQuestion['question'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface
                        ),
                      ),
                      VerticalSpacing(24.0),

                      if (type == 'single') ...List.generate(currentQuestion['options'].length, (index) {
                        final option = currentQuestion['options'][index];
                        final questionIcon = currentQuestion['icons'][index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedOptionIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: _selectedOptionIndex == index
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Color(0xFFCECECE),
                                  width: 2,
                                ),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: _buildOptionBox(index, questionIcon, option)
                            ),
                          ),
                        );
                      }),

                      if (type == 'multiple') ...List.generate(currentQuestion['options'].length, (index) {
                        final option = currentQuestion['options'][index];
                        final questionIcon = currentQuestion['icons'][index];
                        final isSelected = _selectedMultiOptions.contains(index);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedMultiOptions.remove(index);
                                } else {
                                  _selectedMultiOptions.add(index);
                                }
                              });
                            },
                            child: Container(
                              padding: const  EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Color(0xFFCECECE),
                                  width: 2,
                                ),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: _buildOptionBox(index, questionIcon, option)
                            ),
                          ),
                        );
                      }),

                      if (type == 'text')
                        TextField(
                          controller: _textController,
                          maxLength: 1000,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF8B8B8B)
                            ),
                            hintText: AppLocalizations.of(context)!.typeYourAnswer,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                        ),

                      if (type == 'likert') ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(currentQuestion['subQuestions'].length, (index) {
                            final questionText = currentQuestion['subQuestions'][index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    questionText,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    )
                                ),
                                VerticalSpacing(4.0),
                                Wrap(
                                  spacing: 8.0,
                                  children: List.generate(currentQuestion['scale'].length, (scaleIndex) {
                                    return ChoiceChip(
                                      label: Text(
                                        currentQuestion['scale'][scaleIndex],
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontWeight: FontWeight.w400
                                        ),
                                      ),

                                      selected: _likertResponses[index] == scaleIndex,
                                      onSelected: (selected) {
                                        setState(() {
                                          _likertResponses[index] = scaleIndex;
                                          print("Current likert responses are: ${_likertResponses}");
                                        });
                                      },
                                    );
                                  }),
                                ),
                                const SizedBox(height: 16.0),
                              ],
                            );
                          }),
                        )
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),
              PrimaryButton(
                buttonText: "Continuar",
                onButtonPressed: _nextQuestion,
                hasPadding: false,
                isButtonEnabled: type == 'single'
                    ? _selectedOptionIndex != null
                    : type == 'multiple'
                    ? _selectedMultiOptions.isNotEmpty
                    : type == 'text'
                    ? _textController.text.length <= 1000
                    : type == 'likert'
                    ? _likertResponses.length == currentQuestion['subQuestions'].length
                    : false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
