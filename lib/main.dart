import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 存储JSON数据的动态数组
  List<Map<String, dynamic>> _posts = [];
  final Dio dio = Dio();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '按下麥克風開始說話';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _fetchData();
  }

  void _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      var speechEnabled = await _speech.initialize(
        onError: (error) => print('Error: $error'),
        onStatus: (status) => print('Status: $status'),
      );
      if (!speechEnabled) {
        setState(() {
          _text = '語音辨識無法初始化';
        });
      }
    } else {
      setState(() {
        _text = '需要麥克風權限才能使用語音辨識';
      });
    }
  }

  void _toggleListening() async {
    if (!_speech.isAvailable) {
      setState(() {
        _text = '語音辨識不可用';
      });
      return;
    }

    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      bool started = await _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
            if (result.hasConfidenceRating && result.confidence > 0) {
              _confidence = result.confidence;
            }
          });
        },
        localeId: 'zh_TW', // 設定為繁體中文
      );
      setState(() {
        _isListening = started;
        if (!started) {
          _text = '語音辨識啟動失敗';
        }
      });
    }
  }

  void _fetchData() async {
    try {
      final Response response = await dio.get('https://jsonplaceholder.typicode.com/posts');
      final List<dynamic> data = response.data;
      setState(() {
        _posts = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _text,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_speech.isListening)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '信心指數: ${(_confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              const SizedBox(height: 20),
              for (final Map<String, dynamic> post in _posts)
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Title: ${post['title']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Body: ${post['body']}'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleListening,
        elevation: 4.0,
        shape: const CircleBorder(),
        backgroundColor: Colors.cyan.shade400,
        child: Icon(
          _isListening ? Icons.mic_off : Icons.mic,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        bottom: false,
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 50,
          color: Colors.cyan.shade400,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  iconSize: 24,
                  onPressed: () {},
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 48.0),
                child: IconButton(
                  icon: const Icon(Icons.pie_chart, color: Colors.black),
                  iconSize: 24,
                  onPressed: () {},
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 48.0),
                child: IconButton(
                  icon: const Icon(Icons.wallet, color: Colors.black),
                  iconSize: 24,
                  onPressed: () {},
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.black),
                  iconSize: 24,
                  onPressed: () {},
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}