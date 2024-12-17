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
  
  final platform = MethodChannel("com.jboycode/platforms");
  String message = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _callNativeMethod,
              child: const Text('Call Native Methods'),
            ),
            Text("Message From Native $message"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  _callNativeMethod() async {
    /// メソッドには任意の名前をつけることできる。("")
    /// Native側も同じ名前にする必要がある。
    try {
      String message = await platform.invokeMethod("callNative");
      setState(() {
        this.message = message;
      });
      talker.debug("👻 Message From Native: $message");
    } on PlatformException catch (e) {
      talker.error(e.message);
    } finally {
      talker.info("MethodChannelを実行した");
  }
  }
}
