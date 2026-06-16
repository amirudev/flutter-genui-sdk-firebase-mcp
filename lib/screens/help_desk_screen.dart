import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as ai;
import '../models/help_desk_catalog.dart';
import '../models/product.dart';
import '../firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HelpDeskScreen extends StatefulWidget {
  const HelpDeskScreen({super.key});

  @override
  State<HelpDeskScreen> createState() => _HelpDeskScreenState();
}

class _HelpDeskScreenState extends State<HelpDeskScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late final SurfaceController _surfaceController;
  late final A2uiTransportAdapter _transportAdapter;
  late final Conversation _conversation;
  late final ai.GenerativeModel _model;
  
  final List<Message> _messages = [];
  bool _isLoading = false;

  static String get _envApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  String get _apiKey => _envApiKey.isNotEmpty 
      ? _envApiKey 
      : DefaultFirebaseOptions.currentPlatform.apiKey;

  @override
  void initState() {
    super.initState();
    
    final catalog = HelpDeskCatalog.asCatalog();
    _surfaceController = SurfaceController(catalogs: [catalog]);
    
    final promptBuilder = PromptBuilder.chat(
      catalog: catalog,
      systemPromptFragments: [
        'You are an AI support agent. You use a specific protocol for UI.',
        'RULES:',
        '1. If you want to show a UI component, use the JSON protocol.',
        '2. ALWAYS wrap JSON in ```json ... ``` blocks.',
        '3. NEVER mix text and JSON in the same line.',
        '4. Keep conversation natural but concise.',
        'Catalog items available: Column, ProductCard, FAQCard, OrderStatus, PromoCard, ShippingInfo, SupportContact, ComparisonTable.',
        'CRITICAL: EVERY component in the "components" list MUST have a unique "id" string (e.g., "root", "prod_1", "prod_2").',
        'Use the Column component to group multiple components (like multiple ProductCards).',
        'DYNAMIC UPDATES: You can update a widget that you previously sent by reusing its ID.',
        'AUTHORITY: You are allowed to give up to 20% discount if a user complains about the price. Use "updateComponents" to refresh the price on the existing card.',
        'catalogId is always "help_desk".',
        'Current Inventory:',
        ...mockProducts.map((p) => '- ${p.title} (\$${p.price}) ID: prod_${p.id} Image: ${p.images.first}'),
      ],
    );

    _model = ai.GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: ai.Content.system(promptBuilder.systemPromptJoined()),
    );

    _transportAdapter = A2uiTransportAdapter(onSend: (message) async {});
    _conversation = Conversation(controller: _surfaceController, transport: _transportAdapter);

    _surfaceController.surfaceUpdates.listen((update) {
      if (update is SurfaceAdded) {
        setState(() {
          _messages.add(Message(role: Role.assistant, surfaceId: update.surfaceId));
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _surfaceController.dispose();
    _transportAdapter.dispose();
    _conversation.dispose();
    super.dispose();
  }

  // Improved filtering logic that works better with streaming
  String _cleanResponse(String text) {
    // Remove markdown code blocks
    String cleaned = text.replaceAll(RegExp(r'```json[\s\S]*?```'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    
    // Remove raw JSON objects that look like GenUI commands
    // This is a safety net for when the AI forgets backticks
    cleaned = cleaned.replaceAll(RegExp(r'\{[\s\S]*?"version"[\s\S]*?\}'), '');
    
    // Final trim and cleanup
    return cleaned.trim();
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMessage = text.trim();
    _textController.clear();

    setState(() {
      _messages.add(Message(role: Role.user, text: userMessage));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      if (_apiKey.isEmpty) {
        setState(() {
          _messages.add(Message(role: Role.assistant, text: 'API Key missing.'));
          _isLoading = false;
        });
        return;
      }

      final history = _messages
          .where((m) => m.text != null)
          .map((m) => m.role == Role.user ? ai.Content.text(m.text!) : ai.Content.model([ai.TextPart(m.text!)]))
          .toList();

      if (history.isNotEmpty) history.removeLast();

      final chat = _model.startChat(history: history);
      final responseStream = chat.sendMessageStream(ai.Content.text(userMessage));

      String fullResponse = '';
      bool firstTextAdded = false;

      await for (final chunk in responseStream) {
        final chunkText = chunk.text ?? '';
        fullResponse += chunkText;
        
        _transportAdapter.addChunk(chunkText);

        final visibleText = _cleanResponse(fullResponse);

        if (visibleText.isNotEmpty) {
          if (!firstTextAdded) {
            setState(() {
              _messages.add(Message(role: Role.assistant, text: visibleText));
              _isLoading = false;
            });
            firstTextAdded = true;
          } else {
            setState(() {
              final lastIdx = _messages.lastIndexWhere((m) => m.role == Role.assistant && m.text != null);
              if (lastIdx != -1) {
                _messages[lastIdx] = Message(role: Role.assistant, text: visibleText);
              }
            });
          }
        }
        _scrollToBottom();
      }
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() {
        _messages.add(Message(role: Role.assistant, text: 'Error: $e'));
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('AI Help Desk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(onPressed: () => setState(() => _messages.clear()), icon: const Icon(Icons.refresh, size: 20)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                if (message.surfaceId != null) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 44, bottom: 20, top: 4),
                    child: Surface(surfaceContext: _surfaceController.contextFor(message.surfaceId!)),
                  );
                }
                return _MessageBubble(message: message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(width: 40, height: 4, child: LinearProgressIndicator(backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation(Colors.blue))),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                filled: true,
                fillColor: const Color(0xFFF1F3F6),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _handleSubmitted(_textController.text),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class Role {
  static const String user = 'user';
  static const String assistant = 'assistant';
}

class Message {
  final String role;
  final String? text;
  final String? surfaceId;
  Message({required this.role, this.text, this.surfaceId});
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == Role.user;
    if (message.text == null || message.text!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 2, right: 8),
              child: CircleAvatar(radius: 16, backgroundColor: Colors.blue.shade50, child: const Icon(Icons.support_agent, color: Colors.blue, size: 16)),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: Radius.circular(isUser ? 20 : 4), bottomRight: Radius.circular(isUser ? 4 : 20)),
                boxShadow: [if (!isUser) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Text(message.text!, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15, height: 1.4)),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
