import 'package:flutter/material.dart';
import 'package:vermeni/connections/ssh.dart';
import 'package:vermeni/screens/menu.dart';
import 'package:vermeni/screens/settings_page.dart';
import 'package:vermeni/services/gemini_service.dart';
import 'package:vermeni/widgets/chat_message.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GeminiService _geminiService = GeminiService();
  final List<Map<String, String>> _messages = [];
  final SSH _sshService = SSH();
  bool _isProcessing = false;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectToLG();
  }

  Future<void> _connectToLG() async {
    await _sshService.connectToLG();
  }

  Future<void> _displayOnLG(String text) async {
    final kml = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <ScreenOverlay>
    <name>ResponseOverlay</name>
    <Icon>
      <href>http://lg1:81/text2kml?text=${Uri.encodeComponent(text)}</href>
    </Icon>
    <overlayXY x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
    <screenXY x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
    <size x="0" y="0" xunits="pixels" yunits="pixels"/>
  </ScreenOverlay>
</kml>
''';
    final escapedKml = kml.replaceAll("'", "\\'");
    debugPrint("🛰️ Sending KML to LG...");
    await _sshService.clearAllKml();
    await _sshService.sendKMLWithText(escapedKml);
    debugPrint("✅ KML sent!");
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _messages.add({'role': 'user', 'content': text});
    });

    try {
      final response = await _geminiService.getResponse(text);
      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
        _isProcessing = false;
      });

      await _displayOnLG(response);
      await _handleLocationFromText(text);

    } catch (e) {
      final errorMessage = 'Sorry, I encountered an error: $e';
      setState(() {
        _messages.add({'role': 'assistant', 'content': errorMessage});
        _isProcessing = false;
      });

      await _displayOnLG(errorMessage);
    }
  }

  Future<void> _handleLocationFromText(String userInput) async {
    List<String> knownPlaces = [
      'India', 'Brazil', 'USA', 'France', 'Germany',
      'Tokyo', 'London', 'China', 'Mount Everest', 'New York',
      'Africa', 'Canada', 'Australia', 'Japan', 'Russia'
    ];

    for (final place in knownPlaces) {
      if (userInput.toLowerCase().contains(place.toLowerCase())) {
        debugPrint("🎯 Location matched: $place");
        await _sshService.searchPlace(place);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              if (result != null && result is bool) {
                debugPrint("Connection status from SettingsPage: $result");
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Open Control Panel',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ControlPanelScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('Start chatting below!', style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatMessage(
                        text: message['content'] ?? '',
                        isUser: message['role'] == 'user',
                      );
                    },
                  ),
          ),
          if (_isProcessing)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Processing...', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (text) {
                      _sendMessage(text);
                      _controller.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _displayOnLG("This is a test overlay!");
                  },
                  child: const Text("Test Overlay"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    _sshService.searchPlace("India");
                  },
                  child: const Text("Fly to India"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
