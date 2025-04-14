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
  bool _isKmlDisplayed = false;

  @override
  void initState() {
    super.initState();
    _connectToLG();
  }

  Future<void> _connectToLG() async {
    await _sshService.connectToLG();
  }

 Future<void> _displayOnLG(String text) async {
  // Publicly available test image
  const imageUrl = 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png';

  final kml = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <ScreenOverlay>
    <name>ImageOverlay</name>
    <Icon>
      <href>$imageUrl</href>
    </Icon>
    <overlayXY x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
    <screenXY x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
    <size x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
  </ScreenOverlay>
</kml>
''';

  final escapedKml = kml.replaceAll("'", "\\'");

  debugPrint("🛰️ Sending KML to LG with image URL: $imageUrl");

  await _sshService.clearAllKml();
  await _sshService.sendKMLWithText(escapedKml);

  debugPrint("✅ KML image overlay sent to LG");
}

  Future<void> _removeKmlOverlay() async {
  final emptyKml = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <ScreenOverlay>
    <name>ClearOverlay</name>
    <Icon>
      <href></href>
    </Icon>
    <overlayXY x="0" y="0" xunits="fraction" yunits="fraction"/>
    <screenXY x="0" y="0" xunits="fraction" yunits="fraction"/>
    <size x="0" y="0" xunits="fraction" yunits="fraction"/>
  </ScreenOverlay>
</kml>
''';

  final escapedKml = emptyKml.replaceAll("'", "\\'");
  debugPrint("🧹 Sending empty KML to clear LG overlay...");

  await _sshService.clearAllKml();
  await _sshService.sendKMLWithText(escapedKml);

  debugPrint("✅ Empty KML sent, overlay removed");
}


 void _toggleKmlOverlay() async {
  setState(() {
    _isKmlDisplayed = !_isKmlDisplayed;
  });

  if (_isKmlDisplayed) {
    await _displayOnLG("This is a test overlay!");
  } else {
    await _removeKmlOverlay();
  }
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

      // Send the assistant's response to LG
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
    final placeRegex = RegExp(r'\b([A-Z][a-z]+(?:\s[A-Z][a-z]+)*)\b');
    final matches = placeRegex.allMatches(userInput);

    if (matches.isNotEmpty) {
      for (final match in matches) {
        final place = match.group(0);
        if (place != null && place.isNotEmpty) {
          debugPrint("🗺️ Attempting to fly to: $place");
          await _sshService.searchPlace(place);
          break;
        }
      }
    } else {
      debugPrint("⚠️ No obvious place found in text, trying fallback...");

      try {
        final locationPrompt = "Extract the location from this user input: \"$userInput\". Respond with only the place name.";
        final extractedPlace = await _geminiService.getResponse(locationPrompt);
        if (extractedPlace.isNotEmpty) {
          debugPrint("📍 Gemini suggested: $extractedPlace");
          await _sshService.searchPlace(extractedPlace);
        }
      } catch (e) {
        debugPrint("❌ Failed to extract location using Gemini: $e");
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
                  onPressed: _toggleKmlOverlay,
                  child: Text(_isKmlDisplayed ? "Remove Overlay" : "Display Overlay"),
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
