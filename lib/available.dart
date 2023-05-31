import 'package:flutter/material.dart';
import 'package:sensor_manager_android/sensor.dart';
import 'package:sensor_manager_android/sensor_event.dart';
import 'package:sensor_manager_android/sensor_manager_android.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SensorListWidget(sensorList: sensorList!),
                    ),
                  );
                },
                child: const Text("View available sensors"),
              ),
          ],
        ),
      ),
    );
  }
}

class SensorListWidget extends StatelessWidget {
  final List<Sensor> sensorList;
  const SensorListWidget({
    Key? key,
    required this.sensorList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Sensors"),
      ),
      body: ListView.builder(
        itemCount: sensorList.length,
        itemBuilder: (context, index) {
          final sensor = sensorList[index];
          return ListTile(
            title: Text(sensor.name),
            subtitle: Text(Sensor.getSensorName(sensor.type)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SensorWidget(
                  sensor: sensor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SensorWidget extends StatefulWidget {
  final Sensor sensor;
  const SensorWidget({Key? key, required this.sensor}) : super(key: key);

  @override
  State<SensorWidget> createState() => _SensorWidgetState();
}

class _SensorWidgetState extends State<SensorWidget> {
  SensorEvent? sensorEvent;

  @override
  void initState() {
    super.initState();
    SensorManagerAndroid.instance.registerListener(
      widget.sensor.type,
      onSensorChanged: (p0) {
        setState(() {
          sensorEvent = p0;
        });
      },
      onAccuracyChanged: (p0, p1) {},
    );
  }

  @override
  void dispose() {
    super.dispose();
    SensorManagerAndroid.instance.unregisterListener(widget.sensor.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sensor.name,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SensorManagerAndroid.instance.unregisterListener(widget.sensor.type);
        },
        child: const Text("Cancel"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SensorDataWidget("Vendor", widget.sensor.vendor),
            SensorDataWidget(
                "Version", " ${widget.sensor.version.toString()}"),
            SensorDataWidget("Type", " ${widget.sensor.type.toString()}"),
            SensorDataWidget(
                "Resolution", " ${widget.sensor.resolution.toString()}"),
            SensorDataWidget("Reporting mode",
                " ${widget.sensor.reportingMode.toString()}"),
            SensorDataWidget(
                "Power", " ${widget.sensor.power.toString()}"),
            SensorDataWidget(
                "Min Delay", widget.sensor.minDelay.toString()),
            SensorDataWidget(
                "Max range", " ${widget.sensor.maxRange.toString()}"),
            SensorDataWidget("Is Wake up sensor",
                " ${widget.sensor.isWakeUpSensor.toString()}"),
            SensorDataWidget("Is Dynamic sensor",
                " ${widget.sensor.isDynamicSensor.toString()}"),
            const Text("Sensor data"),
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < (sensorEvent?.values.length ?? 0); i++)
                    SensorDataWidget("Value ${i + 1} ",
                        sensorEvent!.values[i].toStringAsFixed(5))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SensorDataWidget extends StatelessWidget {
  const SensorDataWidget(this.sensor, this.data, {Key? key}) : super(key: key);
  final String sensor;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$sensor:"),
          Text(
            data,
            style: TextStyle(color: Theme.of(context).primaryColor),
          )
        ],
      ),
    );
  }
}
