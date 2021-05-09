import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_directions_api/google_directions_api.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '〇〇したいボタン',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '〇〇したいボタン'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  shadowColor: Colors.red,
                ),
                child: const Text('〇〇したい！！'),
                onPressed: () {
                  Navigator.of(context).push(_createDatailPage());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Route _createDatailPage() {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => DatailPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end);
        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      });
}

class DatailPage extends StatefulWidget {
  DatailPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DatailPageState createState() => _DatailPageState();
}

class _DatailPageState extends State<DatailPage> {
  Future<List> GetWaypoint() async {
    print('its detail page GetWayPoint');
    checkLocation();

    final params = {
      'key': "AIzaSyBZMEXm5GvdYvvfltoqPLDRIi1PcD3X9Xc",
      'origin': "千種駅",
      'destination': "SOUNDBAR MiRAi"
    };
    print('its detail page GetWayPoint, set param');

    var originAddressFuture = getLocation();
    var originAddress;
    originAddressFuture.then((value) => (originAddress = value));
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?language=ja&origin=${originAddress}&destination=OsakaStation&key=AIzaSyBZMEXm5GvdYvvfltoqPLDRIi1PcD3X9Xc');
    print('its detail page GetWayPoint, set uri');
    print(url.toString());
    var response = await http.get(url);
    print('its detail page GetWayPoint, get response');

    Map<String, String> responsedData;
    List result = [];

    print(response.body.toString());

    var responseJson = json.decode(response.body);
    var steps = responseJson["routes"][0]["legs"][0]["steps"];
    print(steps.toString());
    steps.forEach((value) => (result.add((value["html_instructions"]
        .replaceAll(RegExp('<.*?>', dotAll: true), '')
        .replaceAll(RegExp('/', dotAll: true), '')
        .replaceAll(RegExp(' ', dotAll: true), '')
        .replaceAll(RegExp('有料区間', dotAll: true), '')))));
    print("set result list");
    result.forEach((element) {
      print(element.toString());
    });
    return Future.value(result);
  }

  @override
  Widget build(BuildContext context) {
    print('its detail page Build');
    print('its detail page Build2');

    return Scaffold(
        appBar: AppBar(
          title: Text('Detail Page'),
        ),
        body: FutureBuilder(
            future: GetWaypoint(),
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                //非同期処理未完了 = 通信中
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, int index) {
                      if (snapshot.data[index].toString() != null) {
                        return ListTile(
                          title: Text(snapshot.data[index].toString()),
                        );
                      } else {
                        return _buildBlank();
                      }
                    });
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return Text("データが存在しません");
              }
            }));
  }
}

Widget _buildBlank() {
  return Center(
    child: CircularProgressIndicator(),
  );
}

Future<String> getLocation() async {
  Location location = new Location();
  LocationData _locationData = await location.getLocation();
  return "${_locationData.longitude.toString()},${ _locationData.latitude.toString()}";
}

Future<bool> checkLocation() async {
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return false;
    }
  }
  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return false;
    }
  }
  return true;
}