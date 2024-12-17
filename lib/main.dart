import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:methld_chanels_demo/talker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IOT Weight Scale Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WeightScalePage(),
    );
  }
}

class WeightScalePage extends StatefulWidget {
  const WeightScalePage({super.key});

  @override
  State<WeightScalePage> createState() => _WeightScalePageState();
}

class _WeightScalePageState extends State<WeightScalePage> {
  static const String _tag = 'WeightScale';
  static const methodChannel = MethodChannel('com.jboycode/weight_scale/method');
  static const eventChannel = EventChannel('com.jboycode/weight_scale/event');

  bool isScaleOn = false;
  double currentWeight = 0.0;

  @override
  void initState() {
    super.initState();
    talker.debug('$_tag: Initializing weight scale page');
    setupEventChannel();
  }

  void setupEventChannel() {
    eventChannel.receiveBroadcastStream().listen(
          (weight) {
        talker.debug('$_tag: Received weight: $weight');
        setState(() {
          currentWeight = weight as double;
        });
      },
      onError: (error) {
        talker.error('$_tag: Error: $error');
      },
      onDone: () {
        talker.info('$_tag: Stream closed');
      },
    );
  }

  Future<void> toggleScale() async {
    try {
      talker.debug('$_tag: Toggling scale to: ${!isScaleOn}');
      final bool result = await methodChannel.invokeMethod('toggleScale', !isScaleOn);
      talker.debug('$_tag: Toggle result: $result');
      setState(() {
        isScaleOn = result;
      });
    } on PlatformException catch (e) {
      talker.error('$_tag: Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IOT Weight Scale'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ON/OFF スイッチ
            Switch(
              value: isScaleOn,
              onChanged: (value) => toggleScale(),
            ),
            const SizedBox(height: 20),
            // 体重表示
            Text(
              isScaleOn ? '${currentWeight.toStringAsFixed(1)} kg' : '-- kg',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}