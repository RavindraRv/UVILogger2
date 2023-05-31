import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensor_manager_android/sensor.dart';
import 'package:sensor_manager_android/sensor_event.dart';
import 'package:sensor_manager_android/sensor_manager_android.dart';
import 'selected_sensors_page.dart';

void main() {
  runApp(const MyAppC());
}

class MyAppC extends StatelessWidget {
  const MyAppC({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Device Sensors'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Sensor>? sensorList;
  List<Sensor> selectedSensors = [];
  List<String> activities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                SensorManagerAndroid.instance.getSensorList().then(
                      (value) => setState(() {
                    sensorList = value;
                  }),
                );
              },
              child: const Text("Get list of available sensors"),
            ),
            if (sensorList != null)
              ElevatedButton(
                onPressed: () {
                  _showSensorSelectionDialog();
                },
                child: const Text("Select sensors"),
              ),
            if (selectedSensors.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SensorDataScreen(
                        selectedSensors: selectedSensors,
                        activities: activities,
                      ),
                    ),
                  );
                },
                child: const Text("Start measurement"),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSensorSelectionDialog() async {
    final selected = await showDialog<List<Sensor>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select sensors"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                for (final sensor in sensorList!)
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return CheckboxListTile(
                        title: Text(sensor.name),
                        value: selectedSensors.contains(sensor),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedSensors.add(sensor);
                            } else {
                              selectedSensors.remove(sensor);
                            }
                          });
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, selectedSensors);
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
    if (selected != null) {
      setState(() {
        selectedSensors = selected;
      });
    }
  }
}
