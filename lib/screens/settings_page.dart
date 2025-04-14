import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vermeni/components/connection_flag.dart';
import 'package:vermeni/connections/ssh.dart';
import 'package:vermeni/services/gemini_service.dart'; // Import GeminiService

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool connectionStatus = false;
  bool isApiKeyValid = false; // Track API key validation status
  late SSH ssh;
  late GeminiService _geminiService; // Initialize GeminiService

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sshPortController = TextEditingController();
  final TextEditingController _rigsController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _geminiService = GeminiService(); // Initialize GeminiService
    _loadSettings();
    _connectToLG();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _sshPortController.dispose();
    _rigsController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _connectToLG() async {
    try {
      bool? result = await ssh.connectToLG();
      setState(() {
        connectionStatus = result ?? false;
      });
    } catch (e) {
      print('Connection error: $e');
      setState(() {
        connectionStatus = false;
      });
    }
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('ipAddress') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _sshPortController.text = prefs.getString('sshPort') ?? '';
      _rigsController.text = prefs.getString('numberOfRigs') ?? '';
      _apiKeyController.text = prefs.getString('apiKey') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ipAddress', _ipController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('sshPort', _sshPortController.text);
    await prefs.setString('numberOfRigs', _rigsController.text);
    await prefs.setString('apiKey', _apiKeyController.text);
  }

  Future<void> _validateApiKey() async {
    try {
      String apiKey = _apiKeyController.text;
      if (apiKey.isNotEmpty) {
        // Validate the API Key using GeminiService
        bool isValid = await _geminiService.validateApiKey();
        setState(() {
          isApiKeyValid = isValid;
        });
      }
    } catch (e) {
      setState(() {
        isApiKeyValid = false;
      });
      print('Error validating API key: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, connectionStatus);
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Connection Settings',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Color(0xFF4B0082), // Deep purple
                Colors.blueAccent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConnectionFlag(status: connectionStatus),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _ipController,
                    label: 'IP Address',
                    hint: 'Enter Master IP',
                    icon: Icons.computer,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'LG Username',
                    hint: 'Enter your username',
                    icon: Icons.person,
                  ),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'LG Password',
                    hint: 'Enter your password',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  _buildTextField(
                    controller: _sshPortController,
                    label: 'SSH Port',
                    hint: '22',
                    icon: Icons.settings_ethernet,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _rigsController,
                    label: 'No. of LG Rigs',
                    hint: 'Enter the number of rigs',
                    icon: Icons.memory,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _apiKeyController,
                    label: 'Gemini API Key',
                    hint: 'Enter your Gemini API key',
                    icon: Icons.vpn_key,
                    obscureText: false,
                    onChanged: (_) => _validateApiKey(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isApiKeyValid ? 'API Key is valid' : 'Check Your Api Key Before Entering',
                    style: TextStyle(
                      color: isApiKeyValid ? Colors.green : Color.fromARGB(255, 238, 250, 2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildActionButton(
                    label: 'CONNECT TO LG',
                    icon: Icons.cast,
                    onPressed: () async {
                      await _saveSettings();
                      await _connectToLG();
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    label: 'SEND COMMAND TO LG',
                    icon: Icons.send,
                    onPressed: () async {
                      try {
                        await ssh.connectToLG();
                        SSHSession? execResult = await ssh.execute();
                        if (execResult != null) {
                          print('Command executed successfully');
                        } else {
                          print('Failed to execute command');
                        }
                      } catch (e) {
                        print('Error: $e');
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(icon, color: Colors.deepPurple),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.shade700,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
