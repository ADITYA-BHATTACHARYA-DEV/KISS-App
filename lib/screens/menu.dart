import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vermeni/components/connection_flag.dart';
import 'package:vermeni/connections/ssh.dart';

bool connectionStatus = false;
const String searchPlace = 'India';
const String searchPlace2 = 'Brazil';

class ControlPanelScreen extends StatefulWidget {
  const ControlPanelScreen({super.key});

  @override
  State<ControlPanelScreen> createState() => _ControlPanelScreenState();
}

class _ControlPanelScreenState extends State<ControlPanelScreen> {
  late SSH ssh;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final buttonTextStyle = TextStyle(
      color: Colors.white,
      fontSize: isPortrait ? 16 : 14,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
            Icon(FontAwesomeIcons.satellite, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            const Text(
              'Cosmic Control Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.gear, color: Colors.white),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              _connectToLG();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple, Colors.blueGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ConnectionFlag(
                  status: connectionStatus,
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: isPortrait ? 2 : 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildButton(
                      'RELAUNCH LG',
                      Colors.deepPurple,
                      buttonTextStyle,
                      FontAwesomeIcons.sync,
                      () async => await ssh.relaunch(),
                    ),
                    _buildButton(
                      'SHUT DOWN LG',
                      Colors.pinkAccent,
                      buttonTextStyle,
                      FontAwesomeIcons.powerOff,
                      () async => await ssh.poweroff(),
                    ),
                    _buildButton(
                      'CLEAN KML',
                      Colors.indigo,
                      buttonTextStyle,
                      FontAwesomeIcons.broom,
                      () async => await ssh.clearKML(),
                    ),
                    _buildButton(
                      'REBOOT LG',
                      Colors.blueAccent,
                      buttonTextStyle,
                      FontAwesomeIcons.redo,
                      () async => await ssh.rebootLG(),
                    ),
                    _buildButton(
                      'SEARCH = $searchPlace',
                      Colors.purpleAccent,
                      buttonTextStyle,
                      FontAwesomeIcons.search,
                      () async => await ssh.searchPlace(searchPlace),
                    ),
                    _buildButton(
                      'SEARCH = $searchPlace2',
                      Color.fromARGB(255, 31, 227, 67),
                      buttonTextStyle,
                      FontAwesomeIcons.search,
                      () async => await ssh.searchPlace(searchPlace2),
                    ),
                    _buildButton(
                      'SEND KML',
                      Colors.cyan,
                      buttonTextStyle,
                      FontAwesomeIcons.upload,
                      () async => await ssh.sendKML(),
                    ),
                    _buildButton(
                      'SEND KML 2',
                      Colors.orangeAccent,
                      buttonTextStyle,
                      FontAwesomeIcons.upload,
                      () async => await ssh.sendKML2(),
                    ),
                    _buildButton(
                      'Clear All KMLs',
                      Color.fromARGB(255, 48, 7, 232),
                      buttonTextStyle,
                      FontAwesomeIcons.trash,
                      () async => await ssh.clearAllKml(),
                    ),
                    _buildButton(
                      'CLEAN LOGOS',
                      Colors.teal,
                      buttonTextStyle,
                      FontAwesomeIcons.trash,
                      () async => await ssh.cleanlogos(),
                    ),
                    _buildButton(
                      'REFRESH',
                      Colors.greenAccent,
                      buttonTextStyle,
                      FontAwesomeIcons.redoAlt,
                      () async => await ssh.setRefresh(),
                    ),
                    
                    _buildButton(
                      'RESET REFRESH',
                      Colors.redAccent,
                      buttonTextStyle,
                      FontAwesomeIcons.timesCircle,
                      () async => await ssh.resetRefresh(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, TextStyle textStyle, IconData icon, Function() onPress) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 10),
            Text(text, style: textStyle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
