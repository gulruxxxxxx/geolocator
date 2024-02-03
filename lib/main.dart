import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Flutter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? myPosition;
  Position? previousPosition;
  double? enteredLatitude;
  double? enteredLongitude;
  double? differenceLatitude;
  double? differenceLongitude;

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    myPosition = await Geolocator.getCurrentPosition();
    if (previousPosition != null) {
      differenceLatitude = myPosition!.latitude - previousPosition!.latitude;
      differenceLongitude = myPosition!.longitude - previousPosition!.longitude;
    }
    previousPosition = myPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'My current position is ${myPosition?.latitude ?? ""},${myPosition?.longitude ?? ""}',
            ),
            ElevatedButton(
              onPressed: () async {
                await _determinePosition();
                setState(() {});
              },
              child: Text('Press'),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter latitude',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  enteredLatitude = double.tryParse(value);
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter longitude',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  enteredLongitude = double.tryParse(value);
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Calculate Difference'),
              onPressed: () async {
                await _determinePosition();
                if (enteredLatitude != null && enteredLongitude != null && myPosition != null) {
                  differenceLatitude = myPosition!.latitude - enteredLatitude!;
                  differenceLongitude = myPosition!.longitude - enteredLongitude!;
                }
                setState(() {});
              },
            ),
            SizedBox(height: 20),
            Text(
              'The location is : ${differenceLatitude ?? ""},${differenceLongitude ?? ""}',
            ),
          ],
        ),
      ),
    );
  }
}
