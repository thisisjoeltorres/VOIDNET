import 'dart:io';

import 'package:flutter/material.dart';
import 'package:voidnet/views/chatbot_view.dart';
import 'package:voidnet/views/components/primary_button.dart';
import 'package:voidnet/views/components/progress_nav.dart';
import 'package:voidnet/views/styles/spaces.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:voidnet/services/audio_import_service.dart';

class ThirdPartyAnalysisView extends StatefulWidget {
  final bool isPersonalAnalysis;
  final VoidCallback onAnalysisSaved;

  const ThirdPartyAnalysisView({super.key, required this.onAnalysisSaved, required this.isPersonalAnalysis});

  @override
  State<ThirdPartyAnalysisView> createState() => _ThirdPartyAnalysisViewState();
}

class _ThirdPartyAnalysisViewState extends State<ThirdPartyAnalysisView> {
  List<Map<String, dynamic>> _responses = [];
  List<File> _importedAudios = [];
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
      'question': '¿Cuál es tu relación con esta persona?',
      'icons': [
        Icons.people,
        Icons.favorite,
        Icons.school,
        Icons.work,
        Icons.help_outline,
      ],
      'options': [
        'Amigo/a',
        'Pareja',
        'Familiar',
        'Compañero/a (estudio o trabajo)',
        'Otro',
      ]
    },
    {
      'type': 'single',
      'question': '¿Por qué quieres analizar a esta persona ahora?',
      'icons': [
        Icons.visibility,
        Icons.support,
        Icons.warning,
        Icons.psychology,
        Icons.favorite_border,
      ],
      'options': [
        'Me preocupa su estado emocional',
        'Quiero entenderle mejor',
        'Ha cambiado últimamente',
        'Pidió ayuda directa',
        'Solo quiero acompañar mejor',
      ]
    },
    {
      'type': 'multiple',
      'question': '¿Qué has notado recientemente en esta persona?',
      'icons': [
        Icons.remove_circle_outline,
        Icons.mood_bad,
        Icons.chat_bubble_outline,
        Icons.schedule,
        Icons.bedtime,
      ],
      'options': [
        'Más silencioso/a de lo normal',
        'Lenguaje negativo o pesimista',
        'Cambios en la forma de hablar',
        'Aislamiento o distancia',
        'Cansancio frecuente',
      ]
    },
    {
      'type': 'text',
      'question': 'Describe brevemente una situación reciente que te haya preocupado:',
    },
    {
      'type': 'likert',
      'question': 'Según tu percepción, en los últimos 7 días esta persona ha mostrado:',
      'subQuestions': [
        'Tristeza o desánimo',
        'Irritabilidad o tensión',
        'Falta de energía',
        'Dificultad para expresarse',
        'Necesidad de apoyo',
      ],
      'scale': ['Nada', 'Poco', 'Algo', 'Bastante', 'Mucho']
    },
    {
      'type': 'audio',
      'question': 'Si lo deseas, puedes importar hasta 3 audios de esta persona (opcional)',
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
      if (canContinue) {
        answer = {
          'selectedIndex': _selectedOptionIndex,
          'selectedText': currentQuestion['options'][_selectedOptionIndex!],
        };
      }
    } else if (currentType == 'multiple') {
      canContinue = _selectedMultiOptions.isNotEmpty;
      if (canContinue) {
        answer = _selectedMultiOptions.map((index) => {
          'selectedIndex': index,
          'selectedText': currentQuestion['options'][index],
        }).toList();
      }
    } else if (currentType == 'text') {
      final text = _textController.text.trim();
      canContinue = text.length <= 1000;
      answer = text;
    } else if (currentType == 'likert') {
      canContinue = _likertResponses.length == currentQuestion['subQuestions'].length;
      if (canContinue) {
        answer = currentQuestion['subQuestions']
            .asMap()
            .map((index, subQuestion) => MapEntry(
          subQuestion,
          currentQuestion['scale'][_likertResponses[index] ?? 0],
        ));
      }
    } else if (currentType == 'audio') {
      answer = _importedAudios.map((file) => {
        'file_path': file.path,
      }).toList();
      canContinue = true;
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

                      if (type == 'audio') ...[
                        Column(
                          children: [
                            Text(
                              'Audios importados: ${_importedAudios.length}/3',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            VerticalSpacing(12.0),

                            PrimaryButton(
                              buttonText: 'Importar audio',
                              hasPadding: false,
                              isButtonEnabled: _importedAudios.length < 3,
                              onButtonPressed: () async {
                                final audio = await AudioImportService.pickAudioFile();
                                if (audio != null) {
                                  setState(() {
                                    _importedAudios.add(audio);
                                  });
                                }
                              },
                            ),

                            VerticalSpacing(16.0),

                            ..._importedAudios.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              return ListTile(
                                leading: const Icon(Icons.audiotrack),
                                title: Text('Audio ${index + 1}'),
                                subtitle: Text(file.path.split('/').last),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _importedAudios.removeAt(index);
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ],
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
                    : type == 'audio'
                    ? true
                    : false
              ),
            ],
          ),
        ),
      ),
    );
  }
}
