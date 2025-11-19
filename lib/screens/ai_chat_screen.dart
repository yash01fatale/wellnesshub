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
    "Suggest a low-budget meal",
    "How to fix sleep?",
    "I feel anxious",
    "Give me a 10-min workout"
  ];

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
    if (q.contains("sad") || q.contains("stress")) return "😟";
    if (q.contains("sleep")) return "😴";
    if (q.contains("workout")) return "💪";
    if (q.contains("spiritual")) return "🧘";
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

    /// Here you can add ML model call
    final response = "🖼️ Your image looks like a food plate.\nEstimated calories: **420 kcal**.";

    await _streamResponse(response);
    await _tts.speak(response);

    setState(() => _isTyping = false);
  }

  // ---------------- STREAMING TYPING EFFECT ----------------
  Future<void> _streamResponse(String fullText) async {
    String current = "";

    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));

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
    await Future.delayed(const Duration(milliseconds: 800));

    final q = query.toLowerCase();

    if (q.contains("sleep")) {
      return "😴 **Sleep Tip**:\nTry sleeping at the same time daily.\nReduce screens 30 min before bed.";
    }
    if (q.contains("diet")) {
      return "🍎 **Diet Advice**:\nTry oats + fruits for breakfast.\nInclude protein + fiber in lunch.";
    }
    if (q.contains("stressed")) {
      return "🧘 **Stress Relief**:\nTry 4-4-4 breathing.\nInhale 4 sec → hold 4 → exhale 4.";
    }
    if (q.contains("workout")) {
      return "💪 Here's a quick workout:\n• 20 squats\n• 15 pushups\n• 30s plank\nRepeat twice!";
    }

    return "🤖 I can help with **nutrition, fitness, sleep, mental health, spirituality**, and more!";
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
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  // ---------------- BUILD UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
            Text("AI Assistant $_avatarMood"),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.image), onPressed: _sendImage),
        ],
      ),

      body: Column(
        children: [
          _buildQuickChips(),

          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (_isTyping && i == _messages.length) {
                  return _typingIndicator();
                }
                return _chatBubble(_messages[i]);
              },
            ),
          ),

          _buildInputBar(),
        ],
      ),
    );
  }

  // ---------------- QUICK REPLY CHIPS ----------------
  Widget _buildQuickChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () {
              _controller.text = quickPrompts[i];
              _sendText();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(quickPrompts[i], style: const TextStyle(fontSize: 13)),
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
    return Align(
      alignment: msg.fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.fromUser ? Colors.deepPurple.shade300 : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: msg.isImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(msg.imageFile!, width: 180))
            : Text(
                msg.text,
                style: TextStyle(
                  color: msg.fromUser ? Colors.white : Colors.black87,
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
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text("AI is typing..."),
      ),
    );
  }

  // ---------------- INPUT BAR ----------------
  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(
              icon: Icon(_listening ? Icons.mic : Icons.mic_none,
                  color: Colors.deepPurple),
              onPressed: _listening ? _stopListening : _startListening,
            ),

            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    hintText: "Ask anything...",
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
              ),
            ),

            const SizedBox(width: 8),

            CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendText,
              ),
            )
          ],
        ),
      ),
    );
  }
}
