import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final platform = const MethodChannel("com.jboycode/platforms");
  bool isScanning = false;
  String bluetoothState = "unknown";
  List<Map<String, dynamic>> devices = [];

  @override
  void initState() {
    super.initState();
    _setupMethodCallHandler();
  }

  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case "bluetoothState":
          setState(() {
            bluetoothState = call.arguments as String;
          });
          break;
        case "deviceFound":
          setState(() {
            devices.add(Map<String, dynamic>.from(call.arguments));
          });
          break;
      }
    });
  }

  Future<void> _toggleScan() async {
    try {
      if (isScanning) {
        await platform.invokeMethod("stopScan");
      } else {
        setState(() {
          devices.clear();
        });
        await platform.invokeMethod("startScan");
      }
      setState(() {
        isScanning = !isScanning;
      });
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bluetooth: $bluetoothState'),
                Switch(
                  value: isScanning,
                  onChanged: (_) => _toggleScan(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device['name'] ?? 'Unknown Device'),
                  subtitle: Text(device['id']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}