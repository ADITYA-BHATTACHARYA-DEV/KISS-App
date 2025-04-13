import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SSH {
  
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;

  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      final socket = await SSHSocket.connect(_host, int.parse(_port));
      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );
      print('Connected to $_host on port $_port');
      return true;
    } catch (e) {
      print('Connection failed: $e');
      return false;
    }
  }

  Future<SSHSession?> execute() async {
    if (_client == null) {
      print('SSH client is not initialized.');
      return null;
    }
    try {
      final session = await _client!.execute('echo "search=Lleida" > /tmp/query.txt');
      print('Command executed.');
      return session;
    } catch (e) {
      print('Execution failed: $e');
      return null;
    }
  }
Future<SSHSession?> sendKMLWithText(String kmlContent) async {
  try {
    if (_client == null) {
      print('SSH client is not initialized.');
      return null;
    }

    final escapedKML = kmlContent.replaceAll("'", "\\'");
    final execResult = await _client!.execute(
      "echo '$escapedKML' > /var/www/html/kml/slave_3.kml"
    );

    print("KML content with text sent successfully.");
    return execResult;
  } catch (e) {
    print('An error occurred while sending text KML: $e');
    return null;
  }
}

Future<SSHSession?> rebootLG() async{
  try{
    if(_client == null)
    {
      print('SSH client is not initialized');
      return null;
    }

    for(int i=int.parse(_numberOfRigs);i>0;i--){
      await _client!.execute(
        'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot"');
      print(
        'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot"'
      );
    }
    return null;
  }
  catch(e){
    print('An error occured while executing the command: $e');
    return null;
  }
  
} 
/////////
Future<SSHSession?> sendKML() async {
  try {
    if (_client == null) {
      print('SSH client is not initialized.');
      return null;
    }

    // Multi-line KML content
    final kmlContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<ScreenOverlay>
	<name>My_Screen_Overlay</name>
	<Icon>
		<href>https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png</href>
	</Icon>
	<overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
	<screenXY x="0" y="1" xunits="fraction" yunits="fraction"/>
	<rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
	<size x="200" y="200" xunits="pixels" yunits="pixels"/>
</ScreenOverlay>
</kml>
''';

    // Escape the KML content to handle special characters
    final escapedKML = kmlContent.replaceAll("'", "\\'");

    // Execute the command with the escaped KML content
    final execResult = await _client!.execute(
      "echo '$escapedKML' > /var/www/html/kml/slave_3.kml"
    );

    print("KML content has been successfully uploaded to /var/www/html/kml/slave_3.kml");
    return execResult;
  } catch (e) {
    print('An error occurred while sending the KML content: $e');
    return null;
  }
}

/////
///
///
///
Future<SSHSession?> sendKML2() async {
  try {
    if (_client == null) {
      print('SSH client is not initialized.');
      return null;
    }

    // Multi-line KML content
    final kmlContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<ScreenOverlay>
	<name>My_Screen_Overlay</name>
	<Icon>
		<href>https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEihAE_IUZLWwgTw6jQ1oxA4jwMSjIdnXTszGFSoF5OH7Cz9UaSau-X4HVbf8SbzNi7tNT7GmCfYyUa8cSrMdkTK4Zk9W2zhaEsrpbhC3ZHJxKc0GS_7LsSH6BNPp-ClPz1zqVG6yPV3DYs/s1600-rw/logo-liquidgalaxylab.png</href>
	</Icon>
	<overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
	<screenXY x="0" y="1" xunits="fraction" yunits="fraction"/>
	<rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
	<size x="200" y="200" xunits="pixels" yunits="pixels"/>
</ScreenOverlay>
</kml>
''';

    // Escape the KML content to handle special characters
    final escapedKML = kmlContent.replaceAll("'", "\\'");

    // Execute the command with the escaped KML content
    final execResult = await _client!.execute(
      "echo '$escapedKML' > /var/www/html/kml/slave_2.kml"
    );

    print("KML content has been successfully uploaded to /var/www/html/kml/slave_2.kml");
    return execResult;
  } catch (e) {
    print('An error occurred while sending the KML content: $e');
    return null;
  }
}

/////




///////

Future<SSHSession?> clearKML() async {
  try{
    if(_client == null){
      print('SSH client is not initialized.');
      return null;
    }
    String KML = '';
    final execResult= 
            await _client!.execute("echo '$KML' > /var/www/html/kml/slave_3.kml");
    
    print(
      "chmod 777 /var/www/html/kmls.txt; echo '$KML'> /var/www/html/kml/slave_3.kml"
    );
    return execResult;
  }
  catch(e){
    print('An error occured while executing the command: $e');
    return null;
  }

 
}


////Clear ALL KMLS


 Future<void> clearAllKml() async {
  try {
    
    if (_client == null) {
      print('SSH client is not initialized.');
      return;
    }

    
    String emptyKml = '';

    
    int numberOfRigs = int.tryParse(_numberOfRigs) ?? 0;
    if (numberOfRigs < 2) {
      print('Invalid _numberOfRigs value.');
      return;
    }

    // Iterate through the rigs and clear KML files
    for (int i = 2; i <= numberOfRigs; i++) {
      final command = "echo '$emptyKml' > /var/www/html/kml/slave_$i.kml";
      try {
        final execResult = await _client!.execute(command);
        print('Cleared KML for slave_$i: $execResult');
      } catch (e) {
        print('Error clearing KML for slave_$i: $e');
      }
    }
  } catch (e) {
    print('An error occurred while executing the command: $e');
  }
}
/////

  Future<SSHSession?> poweroff() async {
   

    try{
    if(_client == null)
    {
      print('SSH client is not initialized');
      return null;
    }

    for(int i=int.parse(_numberOfRigs);i>0;i--){
      await _client!.execute(
            'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S poweroff"');
      print(
        'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot"'
      );
    }
    return null;
  }
  catch(e){
    print('An error occured while executing the command: $e');
    return null;
  }
     
  }

Future<SSHSession?> relaunch() async {
  
    try{
    if(_client == null)
    {
      print('SSH client is not initialized');
      return null;
    }

    for(int i=int.parse(_numberOfRigs);i>0;i--){
       final relaunchCommand = """RELAUNCH_CMD="\\
if [ -f /etc/init/lxdm.conf ]; then
  export SERVICE=lxdm
elif [ -f /etc/init/lightdm.conf ]; then
  export SERVICE=lightdm
else
  exit 1
fi
if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
  echo $_passwordOrKey | sudo -S service \\\${SERVICE} start
else
  echo $_passwordOrKey | sudo -S service \\\${SERVICE} restart
fi
" && sshpass -p $_passwordOrKey ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await _client!
            .execute('"/home/$_username/bin/lg-relaunch" > /home/$_username/log.txt');
        await _client!.execute(relaunchCommand);
    }
    return null;
  }
  catch(e){
    print('An error occured while executing the command: $e');
    return null;
  }
    

   
  }


Future<SSHSession?> searchPlace(String place) async {
  try{
    if (_client == null )
    {
      print('SSH client is not initialized.');
      return null;
    }

    //Execute the command and return the result
    final execResult=
       await _client!.execute(
      'echo "search=$place" > /tmp/query.txt');
      return execResult;
    
    
  }
  catch(e)
  {
    print('An error occured while executing the command: $e');
    return null;
  }
}

Future<SSHSession?> searchPlace2(String place) async {
  try{
    if (_client == null )
    {
      print('SSH client is not initialized.');
      return null;
    }

    //Execute the command and return the result
    final execResult=
       await _client!.execute(
      'echo "search=$place" > /tmp/query.txt');
      return execResult;
    
    
  }
  catch(e)
  {
    print('An error occured while executing the command: $e');
    return null;
  }
}



//For reset-refresh

//  Future<SSHSession?> setRefresh() async {
   

//     const search = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';
//     const replace =
//         '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
//     final command =
//         'echo $_passwordOrKey | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

//     final clear =
//         'echo $_passwordOrKey | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml';

//     for (var i = 2; i <= int.parse(_numberOfRigs); i++) {
//       final clearCmd = clear.replaceAll('{{slave}}', i.toString());
//       final cmd = command.replaceAll('{{slave}}', i.toString());
//       String query = 'sshpass -p $_passwordOrKey ssh -t lg$i \'{{cmd}}\'';

//       try {
//         await _client!.execute(query.replaceAll('{{cmd}}', clearCmd));
//         await _client!.execute(query.replaceAll('{{cmd}}', cmd));
//       } catch (e) {
//         // ignore: avoid_print
//         print(e);
//       }
//     }

//     await rebootLG();
//   }

//   Future<SSHSession?> resetRefresh() async {
    

//     const search =
//         '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
//     const replace = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';

//     final clear =
//         'echo $_passwordOrKey | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

//     for (var i = 2; i <= int.parse(_numberOfRigs); i++) {
//       final cmd = clear.replaceAll('{{slave}}', i.toString());
//       String query = 'sshpass -p $_passwordOrKey ssh -t lg$i \'$cmd\'';

//       try {
//         await _client!.execute(query);
//       } catch (e) {
//         // ignore: avoid_print
//         print(e);
//       }
//     }

//     await rebootLG();
//   }



//







startOrbit() async{
  try{
    await _client!.run('echo "playtour=Orbit"> /tmp/query.txt');

  }
  catch(error)
  {
    stopOrbit();
  }
}


beginOrbiting() async{
  try{
    final res=await _client!.run('echo"playtour=Orbit">/tmp/query.txt');

  }
  catch(error)
  {
    await beginOrbiting();
  }
}




stopOrbit() async {
    
    SSHClient client = SSHClient(
      await SSHSocket.connect(_host, int.parse(_port)),
      // host: '${credencials['ip']}',
      // port: int.parse('${credencials['port']}'),
      username: _username,
      onPasswordRequest: () => _passwordOrKey,
    );

    try {
      await client;
      return await client.execute('echo "exittour=true" > /tmp/query.txt');
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
    }
  }


Future cleanBalloon() async {
  
    SSHClient client = SSHClient(
      await SSHSocket.connect(_host, int.parse(_port)),
    
      username: _username,
      onPasswordRequest: () => _passwordOrKey,
    );
    int rigs = int.parse(_numberOfRigs);
    String blank = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
  </Document>
</kml>''';
    rigs = (int.parse(_numberOfRigs) / 2).floor() + 1;
    try {
      await client;
      return await client
          .execute("echo '$blank' > /var/www/html/kml/slave_$rigs.kml");
    } catch (e) {
      return Future.error(e);
    }
  }


 Future cleanlogos() async {
    
try{
    if(_client == null){
      print('SSH client is not initialized.');
      return null;
    }
    String KML = '';
    final execResult= 
            await _client!.execute("echo '$KML' > /var/www/html/kml/slave_2.kml");
    
    print(
      "chmod 777 /var/www/html/kmls.txt; echo '$KML'> /var/www/html/kml/slave_2.kml"
    );
    return execResult;
  }
  catch(e){
    print('An error occured while executing the command: $e');
    return null;
  }

  }
  ///
  ///
  ///
  ///
 Future setRefresh() async {
   

    SSHClient client = SSHClient(
      await SSHSocket.connect(_host, int.parse(_port)),
     
      username: _username,
      onPasswordRequest: () => _passwordOrKey,
    );
    try {
      const search = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';
      const replace =
          '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
      final command =
          'echo $_passwordOrKey | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

      final clear =
          'echo $_passwordOrKey | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml';
      await client;
      for (var i = 2; i <= int.parse(_numberOfRigs); i++) {
        final clearCmd = clear.replaceAll('{{slave}}', i.toString());
        final cmd = command.replaceAll('{{slave}}', i.toString());
        String query =
            'sshpass -p $_passwordOrKey ssh -t lg$i \'{{cmd}}\'';

        await client.execute(query.replaceAll('{{cmd}}', clearCmd));
        await client.execute(query.replaceAll('{{cmd}}', cmd));
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  Future resetRefresh() async {
    

    SSHClient client = SSHClient(
      await SSHSocket.connect(_host, int.parse(_port)),
      
      username: _username,
      onPasswordRequest: () => _numberOfRigs,
    );
    try {
      const search =
          '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
      const replace = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';

      final clear =
          'echo $_passwordOrKey | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';
      await client;
      for (var i = 2; i <= int.parse(_numberOfRigs); i++) {
        final cmd = clear.replaceAll('{{slave}}', i.toString());
        String query = 'sshpass -p $_passwordOrKey ssh -t lg$i \'$cmd\'';

        await client.execute(query);
      }
    } catch (e) {
      return Future.error(e);
    }
  }

//////
///




}


///
///
///






 
    
  

  

