import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatbotView extends StatefulWidget {
  final List<Map<String, dynamic>>? responses;
  const ChatbotView({super.key, this.responses});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> with SingleTickerProviderStateMixin {
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
    "Casi listo..."
  ];

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

  void _startChat() {
    // Aquí iría la lógica para iniciar la conversación con el chatbot
    // Por ejemplo, puedes usar un controlador de mensajes o agregar el primer mensaje automáticamente
    print("💬 Kana: ¡Hola! Estoy lista para hablar contigo.");
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
        backgroundColor: Colors.white,
        body: Center(
          child: isLoading
              ? _buildLoadingView()
              : _buildChatContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/kana-meditation.svg',
          height: 160,
        ),
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
        const SizedBox(height: 80),
        const Text(
          "Kana está aquí para ti 💙",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // Aquí comienza el contenido del chat
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              Text("💬 Kana: ¡Hola! ¿Cómo te sientes hoy?"),
              // Agrega más mensajes o un controlador de chat real
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "¿Cómo te sientes hoy?",
              suffixIcon: const Icon(Icons.send),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onSubmitted: (value) {
              // Envía mensaje del usuario
              print("Usuario: $value");
            },
          ),
        )
      ],
    );
  }
}
