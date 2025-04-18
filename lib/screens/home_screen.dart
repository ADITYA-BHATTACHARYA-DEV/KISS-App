import 'package:flutter/material.dart';
import 'package:vermeni/connections/ssh.dart';
import 'package:vermeni/screens/dashboard.dart';
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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isProcessing = false;
  bool _isKmlDisplayed = false;
  bool _showConnectionStatus = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToLG();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _checkConnectionStatus());
  }

  Future<void> _connectToLG() async {
    try {
      await _sshService.connectToLG();
      setState(() => _isConnected = true);
      _showConnectionBanner("Connected to Liquid Galaxy", true);
    } catch (e) {
      setState(() => _isConnected = false);
      _showConnectionBanner("Connection failed: ${e.toString()}", false);
    }
  }

  void _showConnectionBanner(String message, bool isSuccess) {
    setState(() => _showConnectionStatus = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showConnectionStatus = false);
    });
  }

  // Future<void> _checkConnectionStatus() async {
  //   final isAlive = await _sshService.checkConnection();
  //   setState(() => _isConnected = isAlive);
  //   if (!isAlive) {
  //     _showConnectionBanner("Connection lost. Reconnecting...", false);
  //     await _connectToLG();
  //   }
  // }

  Future<void> _displayOnLG(String text) async {
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

    await _sshService.clearAllKml();
    await _sshService.sendKMLWithText(kml.replaceAll("'", "\\'"));
  }

  Future<void> _removeTextOverlay() async {
    const emptyKml = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <ScreenOverlay>
    <name>ClearTextOverlay</name>
    <description><![CDATA[<pre></pre>]]></description>
    <overlayXY x="0" y="0" xunits="fraction" yunits="fraction"/>
    <screenXY x="0" y="0" xunits="fraction" yunits="fraction"/>
    <size x="0" y="0" xunits="fraction" yunits="fraction"/>
    <Icon><href></href></Icon>
  </ScreenOverlay>
</kml>
''';

    await _sshService.clearAllKml();
    await _sshService.sendKMLWithText(emptyKml.replaceAll("'", "\\'"));
  }

  Future<void> _displayTextOverlayOnLG(String text) async {
    final wrappedText = text.replaceAllMapped(
      RegExp(r'(.{1,60})(\s|$)'),
      (match) => '${match.group(1)}\n',
    );

    final kml = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <ScreenOverlay>
    <name>TextOverlay</name>
    <description><![CDATA[
      <pre style="font-size:16px; font-family:monospace; color:white; background:rgba(0,0,0,0.7); padding:10px; border-radius:5px;">
      $wrappedText
      </pre>
    ]]></description>
    <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
    <screenXY x="0.05" y="0.95" xunits="fraction" yunits="fraction"/>
    <size x="0.8" y="0" xunits="fraction" yunits="pixels"/>
    <Icon><href></href></Icon>
  </ScreenOverlay>
</kml>
''';

    await _sshService.clearAllKml();
    await _sshService.sendKMLWithText(kml.replaceAll("'", "\\'"));
  }

  void _toggleKmlOverlay() {
    setState(() => _isKmlDisplayed = !_isKmlDisplayed);
    _isKmlDisplayed ? _displayOnLG("Liquid Galaxy Assistant") : _removeTextOverlay();
  }


  void _sendMessage(String text) async {
  if (text.isEmpty) return;

  setState(() {
    _isProcessing = true;
    _messages.add({'role': 'user', 'content': text});
    _controller.clear();
  });

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  });

  try {
    String response = await _geminiService.getResponse(text);

    // Remove all occurrences of double asterisks (**) from the response
    response = response.replaceAll('**', '');

    setState(() {
      _messages.add({'role': 'assistant', 'content': response});
      _isProcessing = false;
    });

    await _displayTextOverlayOnLG(response);
    await _handleLocationFromText(text);
  } catch (e) {
    final errorMessage = 'Sorry, I encountered an error: ${e.toString()}';
    setState(() {
      _messages.add({'role': 'assistant', 'content': errorMessage});
      _isProcessing = false;
    });

    await _displayTextOverlayOnLG(errorMessage);
  }
}


  // void _sendMessage(String text) async {
  //   if (text.isEmpty) return;

  //   setState(() {
  //     _isProcessing = true;
  //     _messages.add({'role': 'user', 'content': text});
  //     _controller.clear();
  //   });

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _scrollController.animateTo(
  //       _scrollController.position.maxScrollExtent,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //   });

  //   try {
  //     final response = await _geminiService.getResponse(text);
  //     setState(() {
  //       _messages.add({'role': 'assistant', 'content': response});
  //       _isProcessing = false;
  //     });

  //     await _displayTextOverlayOnLG(response);
  //     await _handleLocationFromText(text);
  //   } catch (e) {
  //     final errorMessage = 'Sorry, I encountered an error: ${e.toString()}';
  //     setState(() {
  //       _messages.add({'role': 'assistant', 'content': errorMessage});
  //       _isProcessing = false;
  //     });

  //     await _displayTextOverlayOnLG(errorMessage);
  //   }
  // }

  Future<void> _handleLocationFromText(String userInput) async {
    final placeRegex = RegExp(r'\b([A-Z][a-z]+(?:\s[A-Z][a-z]+)*)\b');
    final matches = placeRegex.allMatches(userInput);

    if (matches.isNotEmpty) {
      for (final match in matches) {
        final place = match.group(0);
        if (place != null && place.isNotEmpty) {
          await _sshService.searchPlace(place);
          break;
        }
      }
    } else {
      try {
        final locationPrompt = "Extract the location from this user input: \"$userInput\". Respond with only the place name.";
        final extractedPlace = await _geminiService.getResponse(locationPrompt);
        if (extractedPlace.isNotEmpty) {
          await _sshService.searchPlace(extractedPlace);
        }
      } catch (e) {
        debugPrint("Failed to extract location using Gemini: $e");
      }
    }
  }

  Widget _buildControlPanelItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20),
      minLeadingWidth: 0,
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liquid Galaxy Assistant'),
         titleTextStyle: const TextStyle(
    color: Colors.white,  // Set the title text color to white
    fontSize: 18, 
     // Adjust the font size as needed
  ),
        backgroundColor: colors.primary,
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
         IconButton(
  icon: const Icon(
    Icons.dashboard,
    color: Colors.white,  // Set the icon color to white
  ),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ControlPanelScreen()),
  ),
),
 IconButton(
  icon: const Icon(
    Icons.map_sharp,
    color: Colors.white,  // Set the icon color to white
  ),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const NavigationDashboard()),
  ),
), 


          // IconButton(
          //   icon: Icon(
          //     _isConnected ? Icons.cloud_done : Icons.cloud_off,
          //     color: _isConnected ? Colors.lightGreenAccent : Colors.red[200],
          //   ),
          //   // onPressed: _checkConnectionStatus,
          // ),
        ],
      ),
     drawer: Drawer(
  width: MediaQuery.of(context).size.width * 0.8,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
  ),
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
            ),
            const SizedBox(height: 10),
            Text(
              'Aditya Bhattacharya',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            Text(
              'aditya@domain.com',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
          if (result is bool) {
            debugPrint("Connection status from SettingsPage: $result");
          }
        },
      ),
      // ✅ New Personal Dashboard Option
      ListTile(
        leading: const Icon(Icons.map_sharp, color: Colors.black87),
        title: const Text('Personal Dashboard'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NavigationDashboard()),
          );
        },
      ),
      ExpansionTile(
        leading: const Icon(Icons.control_camera),
        title: const Text('Control Panel'),
        childrenPadding: const EdgeInsets.only(left: 24),
        children: [
          _buildControlPanelItem(
            icon: Icons.flight,
            title: 'Fly to India',
            onTap: () => _sshService.searchPlace("India"),
          ),
          _buildControlPanelItem(
            icon: Icons.desktop_windows,
            title: 'Show Last Response',
            onTap: () {
              final last = _messages.lastWhere(
                (m) => m['role'] == 'assistant',
                orElse: () => {'content': ''},
              )['content']!;
              if (last.isNotEmpty) {
                _displayTextOverlayOnLG(last);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No assistant response found')),
                );
              }
            },
          ),
          _buildControlPanelItem(
            icon: Icons.clear,
            title: 'Remove Text Overlay',
            onTap: _removeTextOverlay,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.layers, size: 20),
                const SizedBox(width: 24),
                const Text('Display KML Overlay'),
                const Spacer(),
                Switch(
                  value: _isKmlDisplayed,
                  activeColor: colors.primary,
                  onChanged: (_) => _toggleKmlOverlay(),
                ),
              ],
            ),
          ),
        ],
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.help),
        title: const Text('Help & Feedback'),
        onTap: () {},
      ),
    ],
  ),
),

      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.travel_explore, size: 100, color: colors.primary.withOpacity(0.2)),
                            const SizedBox(height: 24),
                            Text('Welcome to Liquid Galaxy Assistant',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: colors.onBackground.withOpacity(0.7),
                                )),
                            const SizedBox(height: 8),
                            Text('Ask me to show you any place on Earth',
                                style: theme.textTheme.bodyLarge),
                            const SizedBox(height: 24),
                          FloatingActionButton.extended(
  onPressed: () => _sendMessage("Show me famous landmarks"),
  icon: const Icon(
    Icons.auto_awesome,
    color: Colors.white, // Set icon color to white
  ),
  label: const Text(
    'Try Example',
    style: TextStyle(color: Colors.white), // Set text color to white
  ),
  backgroundColor: colors.primary,
),


                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
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
                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                      ),
                      const SizedBox(width: 16),
                      Text('Liquid Galaxy is processing your request...',
                          style: TextStyle(color: colors.primary)),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                        decoration: InputDecoration(
                          hintText: 'Ask to show any place...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: colors.surfaceVariant.withOpacity(0.5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.mic, color: colors.primary),
                            onPressed: () {
                              // Voice input logic
                            },
                          ),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          if (_controller.text.isNotEmpty) _sendMessage(_controller.text);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showConnectionStatus)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isConnected ? Icons.check_circle : Icons.error,
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isConnected
                            ? 'Connected to Liquid Galaxy'
                            : 'Connection lost. Reconnecting...',
                        style: TextStyle(
                          color: _isConnected ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _showConnectionStatus = false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _messages.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
              child: const Icon(Icons.arrow_downward),
              backgroundColor: colors.primary,
            )
          : null,
    );
  }
}
