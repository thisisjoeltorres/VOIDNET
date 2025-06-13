import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:voidnet/views/components/chat_message.dart';
import 'package:voidnet/views/dashboard_view.dart';
import 'package:voidnet/views/styles/spaces.dart';
import 'package:voidnet/views/utils/chat_service.dart';
import 'package:voidnet/views/utils/custom-page-router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatbotView extends StatefulWidget {
  final List<Map<String, dynamic>>? responses;

  const ChatbotView({super.key, this.responses});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool hasAnalysis = false;
  String loadingMessage = "Analizando tus resultados...";
  int loadingStep = 0;
  late Timer _messageTimer;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  final List<String> loadingMessages = [
    "Analizando tus resultados...",
    "Evaluando con historial existente...",
    "Solo un momento...",
    "Casi listo...",
  ];

  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final List<Map<String, dynamic>> _chatHistory = [];
  final List<String> _summaryHistory = [];
  ChatMessage? _typingMessage;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _progressController.repeat(reverse: true); // animación constante

    if (widget.responses != null && widget.responses!.isNotEmpty) {
      isLoading = true;
      hasAnalysis = true;
      _startLoadingSequence();
    } else {
      _startChat();
    }
  }

  void _addToChatHistory(String message, bool isUser) {
    _chatHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'sender': isUser ? 'user' : 'kana',
      'message': message,
    });
  }

  String _buildDeepseekPrompt(List<dynamic> responses) {
    final buffer = StringBuffer();

    for (final item in responses) {
      final map = item as Map<String, dynamic>;
      final question = map['question'] ?? '';
      final answer = map['answer'] ?? '';
      buffer.writeln('• $question\nRespuesta: $answer\n');
    }

    return """
    IMPORTANTE: Comienza tu respuesta con una línea como esta:
    [RESUMEN OCULTO]: resumen aquí
    Luego continúa con tu respuesta natural para el usuario.
Eres un terapeuta profesional en salud mental llamado Kana 🌧️. Has recibido la siguiente información de un usuario que completó un formulario de evaluación emocional. Analiza sus respuestas con empatía y claridad.

Información del usuario:
---
${buffer.toString()}
---
Recuerda: No repitas los datos textualmente, responde con análisis humano y emocional.
""";
  }

  String _generateInitialMessage(List<Map<String, dynamic>> responses) {
    String emotionalState = '';
    String reason = '';
    String details = '';
    String depressionSigns = '';
    String relationships = '';

    for (var q in responses) {
      final String question = q['question'];
      final String type = q['type'];
      final dynamic answer = q['answer'];

      if (question.contains('¿Cómo te sientes hoy?') && type == 'single') {
        final options = [
          'te sientes bastante bien',
          'te sientes bien',
          'te sientes neutral',
          'te sientes algo mal',
          'te sientes bastante mal',
        ];
        if (answer is Map && answer['selectedIndex'] is int) {
          final index = answer['selectedIndex'];
          if (index >= 0 && index < options.length) {
            emotionalState = options[index];
          }
        }
      }

      if (question.contains('¿Qué te motivó') && type == 'multiple') {
        if (answer is List) {
          final reasons =
              answer
                  .map((item) => item['selectedText'])
                  .whereType<String>()
                  .toList();
          reason = reasons.join(', ').toLowerCase();
        }
      }

      if (question.contains('escribir algo más') && type == 'text') {
        if (answer is String && answer.trim().isNotEmpty) {
          details = answer.trim();
        }
      }

      if (question.contains('Durante los últimos 7 días') && type == 'likert') {
        if (answer is Map<String, String>) {
          // Ponderamos la escala textual
          final scale = {
            'Nunca': 0,
            'Raramente': 1,
            'Algunas veces': 2,
            'Casi siempre': 3,
            'Siempre': 4,
          };
          int total = 0;
          int count = 0;
          for (var value in answer.values) {
            if (scale.containsKey(value)) {
              total += scale[value]!;
              count++;
            }
          }
          if (count > 0) {
            final avg = total ~/ count;
            if (avg >= 3) {
              depressionSigns =
                  'Tuviste varios signos de desánimo como falta de energía, insomnio o pensamientos tristes.';
            } else if (avg >= 2) {
              depressionSigns =
                  'Parece que has tenido algunos días difíciles, con emociones bajas.';
            } else {
              depressionSigns =
                  'Tus respuestas no reflejan un malestar emocional fuerte esta semana.';
            }
          }
        }
      }

      if (question.contains('¿Cómo han estado tus relaciones') &&
          type == 'likert') {
        if (answer is Map<String, String>) {
          final scale = {'Muy bien': 0, 'Normal': 1, 'Mal': 2};
          int total = 0;
          int count = 0;
          for (var value in answer.values) {
            if (scale.containsKey(value)) {
              total += scale[value]!;
              count++;
            }
          }
          if (count > 0) {
            final avg = total ~/ count;
            final relTexts = ['muy bien', 'normales', 'algo distantes'];
            relationships = relTexts[avg.clamp(0, 2)];
          }
        }
      }
    }

    return """
Hola, soy Kana 🌧️  
He leído tus respuestas con atención, y quiero que sepas que no estás sol@ 🫂

Dices que actualmente $emotionalState, y que decidiste hacer este análisis porque $reason.  
$depressionSigns  
Tus relaciones parecen estar $relationships.

${details.isNotEmpty ? "También escribiste:\n❝ $details ❞" : ""}

Gracias por compartir todo esto conmigo.  
Estoy aquí para escucharte con cariño, a tu ritmo. ¿Quieres contarme más sobre cómo te has sentido últimamente?
""";
  }

  Map<String, String> _extractHiddenSummary(String fullResponse) {
    final regex = RegExp(r'^\[RESUMEN OCULTO\]: (.*?)\n', dotAll: true);
    final match = regex.firstMatch(fullResponse);
    if (match != null) {
      final summary = match.group(1) ?? '';
      final visibleText = fullResponse.replaceFirst(regex, '').trim();
      return {
        'summary': summary,
        'visible': visibleText,
      };
    } else {
      return {
        'summary': '',
        'visible': fullResponse.trim(),
      };
    }
  }

  void _startLoadingSequence() {
    // Cambiar mensaje cada 2.5 segundos
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        loadingStep++;
        if (loadingStep >= loadingMessages.length) {
          loadingStep = 0; // Reinicia si quieres bucle infinito
        }
        loadingMessage = loadingMessages[loadingStep];
      });
    });

    // Finaliza la carga tras 8 segundos (puedes ajustar)
    Future.delayed(const Duration(seconds: 8), () {
      _messageTimer.cancel();
      setState(() {
        isLoading = false;
      });

      // Simula mensaje de inicio del chatbot tras carga
      Future.delayed(const Duration(milliseconds: 500), () {
        _startChat();
      });
    });
  }

  void _startChat() async {
    if (widget.responses != null && widget.responses!.isNotEmpty) {
      final systemPrompt = _buildDeepseekPrompt(widget.responses!);

      setState(() {
        _typingMessage = const ChatMessage(
          message: "Kana está escribiendo...",
          isUser: false,
          isTemporary: true,
        );
        _messages.add(_typingMessage!);
      });

      try {
        final response = await ChatService.sendMessage(systemPrompt);
        final parsed = _extractHiddenSummary(response);

        setState(() {
          _messages.remove(_typingMessage);
          _messages.add(ChatMessage(message: parsed['visible']!, isUser: false));
          _addToChatHistory(parsed['visible']!, false);

          if (parsed['summary']!.isNotEmpty) {
            _summaryHistory.add(parsed['summary']!);
            if (_summaryHistory.length > 5) {
              _summaryHistory.removeAt(0);
            }
          }

          _typingMessage = null;
        });
      } catch (e) {
        setState(() {
          _messages.remove(_typingMessage);
          _messages.add(ChatMessage(message: "Error: $e", isUser: false));
          _typingMessage = null;
        });
      }
    } else {
      setState(() {
        _messages.add(
          const ChatMessage(
            message: "Hola, soy Kana 🌧️ ¿Cómo te sientes hoy?",
            isUser: false,
          ),
        );
        _addToChatHistory("Hola, soy Kana 🌧️ ¿Cómo te sientes hoy?", false);
      });
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(message: text, isUser: true));
      _addToChatHistory(text, true);
      _typingMessage = const ChatMessage(
        message: "Kana está escribiendo...",
        isUser: false,
        isTemporary: true,
      );
      _messages.add(_typingMessage!);
    });

    _controller.clear();

    try {
      final contextSummary = _summaryHistory.isNotEmpty
          ? "IMPORTANTE: Comienza tu respuesta con una línea como esta: [RESUMEN OCULTO]: resumen aquí. Contexto reciente:\n" + _summaryHistory.join('\n') + "\n\n"
          : "";
      final fullPrompt = contextSummary + text;
      final response = await ChatService.sendMessage(fullPrompt);
      final parsed = _extractHiddenSummary(response);

      setState(() {
        _messages.remove(_typingMessage);
        _messages.add(ChatMessage(message: parsed['visible']!, isUser: false));
        _addToChatHistory(parsed['visible']!, false);

        if (parsed['summary']!.isNotEmpty) {
          _summaryHistory.add(parsed['summary']!);
          if (_summaryHistory.length > 5) {
            _summaryHistory.removeAt(0);
          }
        }

        _typingMessage = null;
      });
    } catch (e) {
      setState(() {
        _messages.remove(_typingMessage);
        _messages.add(ChatMessage(message: "Error: $e", isUser: false));
        _typingMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _messageTimer.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                CustomPageRoute(
                  ShowCaseWidget(builder: (context) => const DashboardView()),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
          toolbarHeight: 64.0,
          bottomOpacity: 0.5,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              VerticalSpacing(8.0),
              SvgPicture.asset(
                Theme.of(context).colorScheme.brightness == Brightness.light
                    ? 'assets/images/brand/sentai-logo.svg'
                    : 'assets/images/brand/sentai-logo-dark.svg',
                height: 24.0,
              ),
            ],
          ),
        ),
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFDCECF2), Color(0xFFF9F4EF)],
            ),
          ),
          child: Center(
            child: isLoading ? _buildLoadingView() : _buildChatContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/images/illustrations/kana-meditation.svg', height: 160),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                backgroundColor: Colors.grey.shade300,
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          loadingMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.teal,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChatContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) => _messages[index],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)!.howAreYouFeelingToday,
                    labelText:
                        AppLocalizations.of(context)!.howAreYouFeelingToday,
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
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
                    suffixIcon: Container(
                      margin: EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: _sendMessage,
                        icon: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.black,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}