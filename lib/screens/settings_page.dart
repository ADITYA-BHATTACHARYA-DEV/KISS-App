import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vermeni/components/connection_flag.dart';
import 'package:vermeni/connections/ssh.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool connectionStatus = false;
  late SSH ssh;

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sshPortController = TextEditingController();
  final TextEditingController _rigsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ssh = SSH();
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
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_ipController.text.isNotEmpty) {
      await prefs.setString('ipAddress', _ipController.text);
    }
    if (_usernameController.text.isNotEmpty) {
      await prefs.setString('username', _usernameController.text);
    }
    if (_passwordController.text.isNotEmpty) {
      await prefs.setString('password', _passwordController.text);
    }
    if (_sshPortController.text.isNotEmpty) {
      await prefs.setString('sshPort', _sshPortController.text);
    }
    if (_rigsController.text.isNotEmpty) {
      await prefs.setString('numberOfRigs', _rigsController.text);
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
        appBar: AppBar(
          title: const Text('Connection Settings'),
          backgroundColor: Colors.deepPurple.shade900,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Colors.deepPurple,
                Colors.blueAccent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ConnectionFlag(status: connectionStatus),
                ),
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
                const SizedBox(height: 20),
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
              ],
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.all(16.0),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 20),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
