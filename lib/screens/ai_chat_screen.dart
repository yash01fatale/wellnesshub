import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:image_picker/image_picker.dart';

// ---------------- MESSAGE MODEL ----------------
class _Msg {
  final String text;
  final bool fromUser;
  final bool isImage;
  final File? imageFile;

  _Msg(this.text, this.fromUser, {this.isImage = false, this.imageFile});
}

// ---------------- MAIN CHAT SCREEN ----------------
class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});
  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final List<_Msg> _messages = [];
  bool _isTyping = false;
  bool _listening = false;

  String _avatarMood = "🙂";

  final List<String> quickPrompts = [
    "Give me today’s wellness plan",
    "Suggest a low-budget healthy meal",
    "How to improve my sleep?",
    "I feel stressed and anxious",
    "Give me a 10-min home workout"
  ];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    // Intro message built from reliable online wellness guidance (diet, sleep, activity, stress).
    _messages.add(
      _Msg(
        "Hi, I’m your Wellness AI 🧠\n\n"
        "I can share general tips on:\n"
        "• Healthy food choices & routines\n"
        "• Simple at-home workouts\n"
        "• Sleep hygiene & daily habits\n"
        "• Basic stress management ideas\n\n"
        "I’m not a doctor or therapist — "
        "for medical or mental-health emergencies, "
        "please contact a professional or local emergency services.",
        false,
      ),
    );
  }

  // ------------------- SEND MESSAGE -------------------
  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Msg(text, true));
      _avatarMood = _detectMood(text);
      _controller.clear();
    });

    _scrollToBottom();
    _startAIReply(text);
  }

  // ------------------- SEND IMAGE ---------------------
  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (img == null) return;

    final file = File(img.path);

    setState(() {
      _messages.add(_Msg("Image sent", true, isImage: true, imageFile: file));
    });

    _scrollToBottom();
    _startAIImageReply(file);
  }

  // ---------------- MOOD DETECTION ------------------
  String _detectMood(String text) {
    final q = text.toLowerCase();
    if (q.contains("sad") || q.contains("stress") || q.contains("anxious")) {
      return "😟";
    }
    if (q.contains("sleep")) return "😴";
    if (q.contains("workout") || q.contains("exercise")) return "💪";
    if (q.contains("spiritual") || q.contains("meditation")) return "🧘";
    return "🙂";
  }

  // ---------------- AI TEXT REPLY -------------------
  Future<void> _startAIReply(String query) async {
    setState(() => _isTyping = true);

    final response = await _mockAI(query);

    await _streamResponse(response);
    await _tts.speak(response);

    setState(() => _isTyping = false);
  }

  // ---------------- AI IMAGE REPLY -------------------
  Future<void> _startAIImageReply(File img) async {
    setState(() => _isTyping = true);

    // Placeholder for ML model call
    final response =
        "🖼️ I see an image that looks like food.\n\n"
        "Remember: balanced meals usually include:\n"
        "• Vegetables or fruits\n"
        "• A source of protein\n"
        "• Whole grains or healthy carbs\n\n"
        "For exact nutrition or allergies, please consult a nutrition professional.";

    await _streamResponse(response);
    await _tts.speak(response);

    setState(() => _isTyping = false);
  }

  // ---------------- STREAMING TYPING EFFECT ----------------
  Future<void> _streamResponse(String fullText) async {
    String current = "";

    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 18));

      current += fullText[i];

      setState(() {
        if (_messages.isNotEmpty && !_messages.last.fromUser) {
          _messages.removeLast();
        }
        _messages.add(_Msg(current, false));
      });

      _scrollToBottom();
    }
  }

  // ---------------- MOCK AI (replace with backend later) ----------------
  Future<String> _mockAI(String query) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final q = query.toLowerCase();

    if (q.contains("sleep")) {
      return "😴 Sleep hygiene basics:\n\n"
          "• Aim for 7–8 hours most nights.\n"
          "• Keep a consistent sleep & wake time.\n"
          "• Avoid screens & heavy meals 30–60 min before bed.\n"
          "• Make your room dark, quiet and cool.\n\n"
          "If you have long-term sleep problems, talk to a doctor.";
    }
    if (q.contains("diet") || q.contains("food") || q.contains("meal")) {
      return "🍎 Simple healthy eating ideas:\n\n"
          "• Fill half your plate with vegetables or fruits.\n"
          "• Prefer whole grains (like brown rice, oats).\n"
          "• Include a protein source each meal (dal, beans, eggs, paneer, lean meat).\n"
          "• Limit sugary drinks & ultra-processed snacks.\n\n"
          "For special conditions (diabetes, heart issues), follow your doctor’s plan.";
    }
    if (q.contains("stress") || q.contains("anxious") || q.contains("anxiety")) {
      return "🧘 Feeling stressed is common.\n\n"
          "You can try:\n"
          "• 4-4-4 breathing: inhale 4 sec → hold 4 → exhale 4, repeat 5–10 times.\n"
          "• A short walk or light stretching.\n"
          "• Writing down what you feel.\n"
          "• Talking to a trusted person.\n\n"
          "If stress or anxiety feels overwhelming or you think of self-harm, "
          "please contact a mental-health professional or local helpline immediately.";
    }
    if (q.contains("workout") || q.contains("exercise")) {
      return "💪 10-minute no-equipment routine:\n\n"
          "• 1 min brisk marching in place\n"
          "• 15 squats\n"
          "• 10–15 push-ups (wall/knee ok)\n"
          "• 30 sec plank\n"
          "• 1 min slow breathing\n\n"
          "Repeat 2–3 times if you feel comfortable.\n"
          "If you have heart or joint problems, check with a doctor before new workouts.";
    }
    if (q.contains("hydration") || q.contains("water")) {
      return "💧 Hydration tips:\n\n"
          "• Sip water regularly through the day.\n"
          "• Limit sugary drinks.\n"
          "• More water in hot weather or after exercise.\n"
          "• Notice signs like dark urine or headaches as possible dehydration signals.\n\n"
          "For fluid restrictions prescribed by a doctor, always follow their guidance.";
    }

    return "🤖 I’m here for general **wellness support**.\n\n"
        "You can ask about:\n"
        "• Daily routine ideas (sleep, food, activity)\n"
        "• Simple home workouts\n"
        "• Basic stress-relief techniques\n"
        "• Gentle habit-building tips\n\n"
        "I’m not a replacement for doctors, therapists, or emergency services.";
  }

  // ---------------- SPEECH INPUT ----------------
  Future<void> _startListening() async {
    bool available = await _speech.initialize();

    if (available) {
      setState(() => _listening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    setState(() => _listening = false);
    _speech.stop();
  }

  // ---------------- SCROLL ----------------
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ---------------- INFO SHEET ----------------
  void _showInfoSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "About Wellness AI",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.shield_moon_outlined, size: 20),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "This assistant gives general lifestyle and wellness tips only.",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  "What I can help with",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                const Text("• Building simple routines for food, sleep, movement."),
                const Text("• Ideas for low-budget, healthier meals."),
                const Text("• Light stress-management and relaxation techniques."),
                const Text("• Motivation and habit-building suggestions."),
                const SizedBox(height: 16),
                Text(
                  "Important safety reminders",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.redAccent),
                ),
                const SizedBox(height: 6),
                const Text("• Not a doctor, therapist, or emergency service."),
                const Text(
                    "• Don’t rely on this chat for diagnosis, prescriptions or crisis help."),
                const Text(
                    "• Don’t share passwords, financial data, or very private medical records."),
                const Text(
                    "• If you feel at risk or unwell, contact a qualified professional or local helpline."),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- BUILD UI -------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.deepPurple.shade400,
              child: Text(
                _avatarMood,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Wellness AI",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: const [
                    Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                    SizedBox(width: 4),
                    Text(
                      "Online · General guidance only",
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Upload image",
            icon: const Icon(Icons.image_outlined),
            onPressed: _sendImage,
          ),
          IconButton(
            tooltip: "About this AI",
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoSheet,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade900,
                  Colors.deepPurple.shade700,
                  Colors.black87,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Foreground content
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 16),

              // Safety banner
              _buildSafetyBanner(),

              // Quick prompts
              _buildQuickChips(),

              // Chat area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (_isTyping && i == _messages.length) {
                          return _typingIndicator();
                        }
                        return _chatBubble(_messages[i]);
                      },
                    ),
                  ),
                ),
              ),

              // Input bar
              _buildInputBar(theme),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- SAFETY BANNER ----------------
  Widget _buildSafetyBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: const [
          Icon(Icons.health_and_safety_outlined, size: 18, color: Colors.orangeAccent),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "For emergencies or serious medical/mental-health issues, "
              "please contact a doctor or local helpline.",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- QUICK REPLY CHIPS ----------------
  Widget _buildQuickChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () {
              _controller.text = quickPrompts[i];
              _sendText();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade400.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, size: 14, color: Colors.amberAccent),
                  const SizedBox(width: 6),
                  Text(
                    quickPrompts[i],
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: quickPrompts.length,
      ),
    );
  }

  // ---------------- CHAT BUBBLE ----------------
  Widget _chatBubble(_Msg msg) {
    final isUser = msg.fromUser;

    final bubbleColor = isUser
        ? Colors.deepPurpleAccent.shade200.withOpacity(0.9)
        : Colors.white.withOpacity(0.95);

    final textColor = isUser ? Colors.white : Colors.black87;

    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 6),
      bottomRight: Radius.circular(isUser ? 6 : 18),
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black.withOpacity(0.18),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: msg.isImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(msg.imageFile!, width: 220),
                )
              : Text(
                  msg.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.5,
                    height: 1.3,
                  ),
                ),
        ),
      ),
    );
  }

  // ---------------- TYPING INDICATOR ----------------
  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            _dot(),
            const SizedBox(width: 4),
            _dot(delay: 150),
            const SizedBox(width: 4),
            _dot(delay: 300),
            const SizedBox(width: 10),
            const Text("AI is typing...", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _dot({int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: const CircleAvatar(radius: 3, backgroundColor: Colors.black54),
    );
  }

  // ---------------- INPUT BAR ----------------
  Widget _buildInputBar(ThemeData theme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Mic
            IconButton(
              icon: Icon(
                _listening ? Icons.mic : Icons.mic_none,
                color: Colors.deepPurpleAccent.shade100,
              ),
              onPressed: _listening ? _stopListening : _startListening,
            ),

            // Text field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Ask about food, sleep, stress, workouts...",
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            GestureDetector(
              onTap: _sendText,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.deepPurpleAccent.shade200,
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
