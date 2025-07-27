import 'package:flutter/material.dart';
import 'package:budget_tracker_flutter/models/genai_question.dart';
import 'package:budget_tracker_flutter/services/question_service.dart';

class AskBudgetScreen extends StatefulWidget {
  const AskBudgetScreen({super.key});

  @override
  State<AskBudgetScreen> createState() => _AskBudgetScreenState();
}

class _AskBudgetScreenState extends State<AskBudgetScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isThinking = false;

  void _sendMessage() async {
    final questionText = _controller.text.trim();
    if (questionText.isEmpty) return;

    setState(() {
      _messages.add({'type': 'user', 'text': questionText});
      _controller.clear();
      _isThinking = true;
    });

    try {
      final question = GenAIQuestion(question: questionText);
      final response = await QuestionService.askQuestion(question);

      setState(() {
        _isThinking = false;
        _messages.add({'type': 'bot', 'text': response.answer});
      });
    } catch (e) {
      setState(() {
        _isThinking = false;
        _messages.add({'type': 'bot', 'text': 'Sorry, something went wrong.'});
      });
    }
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Ask About Your Budget',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6C47FF),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isThinking && index == _messages.length) {
                  return _buildMessageBubble("Thinking...", false);
                }
                final message = _messages[index];
                return _buildMessageBubble(
                  message['text']!,
                  message['type'] == 'user',
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Ask a question...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C47FF),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}