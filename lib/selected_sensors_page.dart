import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensor_manager_android/sensor.dart';
import 'package:sensor_manager_android/sensor_event.dart';
import 'package:sensor_manager_android/sensor_manager_android.dart';

class SensorDataScreen extends StatefulWidget {
  final List<Sensor> selectedSensors;
  final List<String> activities;

  const SensorDataScreen({
    Key? key,
    required this.selectedSensors,
    required this.activities,
  }) : super(key: key);

  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  Map<Sensor, SensorEvent?> sensorData = {};
  List<String> selectedActivities = [];
  String currentActivity = '';
  bool isTimerRunning = false;
  int elapsedTime = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    for (final sensor in widget.selectedSensors) {
      sensorData[sensor] = null;
      SensorManagerAndroid.instance.registerListener(
        sensor.type,
        onSensorChanged: (event) {
          setState(() {
            sensorData[sensor] = event;
          });
        },
        onAccuracyChanged: (_, __) {},
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (final sensor in widget.selectedSensors) {
      SensorManagerAndroid.instance.unregisterListener(sensor.type);
    }
    timer?.cancel();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        elapsedTime++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      elapsedTime = 0;
    });
  }

  void addActivity(String activity) {
    setState(() {
      if (widget.activities.length < 12) {
        widget.activities.add(activity);
      }
    });
  }

  void toggleActivity(String activity) {
    setState(() {
      if (selectedActivities.contains(activity)) {
        selectedActivities.remove(activity);
      } else {
        selectedActivities.add(activity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sensor Data"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Add Activity'),
                    content: TextField(
                      onChanged: (value) {
                        currentActivity = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Activity',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          addActivity(currentActivity);
                          Navigator.pop(context);
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text(
              "Add Activity",
              style: TextStyle(color: Colors.white),
            ),
          ),
          if (widget.activities.isNotEmpty)
            Wrap(
              children: [
                for (final activity in widget.activities)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        toggleActivity(activity);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          selectedActivities.contains(activity)
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                      child: Text(
                        activity,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.selectedSensors.length,
              itemBuilder: (context, index) {
                final sensor = widget.selectedSensors[index];
                final event = sensorData[sensor];
                return ListTile(
                  title: Text(sensor.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event != null)
                        for (var i = 0; i < event.values.length; i++)
                          Text(
                            "${Sensor.getSensorName(sensor.type)}: ${event.values[i].toStringAsFixed(5)}",
                            style: const TextStyle(color: Colors.green),
                          ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (isTimerRunning) {
                stopTimer();
              } else {
                startTimer();
              }
              setState(() {
                isTimerRunning = !isTimerRunning;
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                isTimerRunning ? Colors.red : Color(0xFF156EB7),
              ),
            ),
            child: Text(
              isTimerRunning ? "Stop" : "Start",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 20),
          Text('Timer: $elapsedTime seconds'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Generate CSV file logic
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green),
            ),
            child: const Text(
              "Generate CSV File",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
