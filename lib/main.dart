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
  String _debugInfo = ''; // 添加調試信息
  int _resultCount = 0; // 添加結果計數器

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _fetchData();
  }

  @override
  void dispose() {
    // 確保在應用程序生命週期結束時停止語音識別
    if (_isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  // 添加調試信息
  void _addDebugInfo(String info) {
    print('DEBUG: $info');
    if (mounted) {
      setState(() {
        _debugInfo = info;
      });
    }
  }

  // 初始化語音辨識
  void _initSpeech() async {
    try {
      _addDebugInfo('初始化中...');

      // 請求麥克風權限
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        _addDebugInfo('麥克風權限已獲取');

        var speechEnabled = await _speech.initialize(
          onError: (error) {
            _addDebugInfo('錯誤: $error');
            if (mounted) {
              setState(() {
                _isListening = false;
              });
            }
          },
          onStatus: (status) {
            _addDebugInfo('狀態: $status');
            if (!mounted) return;

            // 根據狀態更新 _isListening
            if (status == 'done' || status == 'notListening') {
              setState(() {
                _isListening = false;
                // 只有當當前文本為初始狀態時才重置文本
                if (_text == '正在聆聽...' || _text == '啟動中...') {
                  _text = '按下麥克風開始說話';
                }
              });
            } else if (status == 'listening') {
              setState(() {
                _isListening = true;
                if (_text == '啟動中...') {
                  _text = '正在聆聽...';
                }
              });
            }
          },
        );

        _addDebugInfo('初始化結果: $speechEnabled');

        if (!speechEnabled && mounted) {
          setState(() {
            _text = '語音辨識無法初始化';
          });
        }
      } else {
        _addDebugInfo('麥克風權限被拒絕');
        if (mounted) {
          setState(() {
            _text = '需要麥克風權限才能使用語音辨識';
          });
        }
      }
    } catch (e) {
      _addDebugInfo('初始化錯誤: $e');
      if (mounted) {
        setState(() {
          _text = '語音辨識初始化失敗';
        });
      }
    }
  }

  // 安全地停止聆聽
  void _stopListening() {
    try {
      _addDebugInfo('嘗試停止聆聽');
      if (_speech.isListening) {
        _speech.stop();
        _addDebugInfo('已發送停止命令');
      }

      if (mounted) {
        setState(() {
          _isListening = false;
          // 如果沒有識別到任何文字，恢復到初始提示
          if (_text == '正在聆聽...' || _text == '啟動中...') {
            _text = '按下麥克風開始說話';
          }
          _addDebugInfo('已更新UI為停止狀態，文本: $_text');
        });
      }
    } catch (e) {
      _addDebugInfo('停止聆聽錯誤: $e');
    }
  }

  // 安全地開始聆聽
  Future<void> _startListening() async {
    _resultCount = 0; // 重置結果計數器

    if (!_speech.isAvailable) {
      _addDebugInfo('語音辨識不可用');
      if (mounted) {
        setState(() {
          _text = '語音辨識不可用';
        });
      }
      return;
    }

    // 先設定為"啟動中..."，避免狀態延遲
    if (mounted) {
      setState(() {
        _text = '啟動中...';
        _addDebugInfo('UI已更新為啟動狀態');
      });
    }

    try {
      _addDebugInfo('嘗試開始聆聽');
      // 使用 try-catch 並忽略返回值，完全依賴 onStatus 回調
      _speech.listen(
        onResult: (result) {
          _resultCount++;
          _addDebugInfo('收到結果 #$_resultCount: ${result.recognizedWords}, 最終=${result.finalResult}');

          // 移除條件檢查，確保始終更新文本
          if (mounted) {
            setState(() {
              if (result.recognizedWords.isNotEmpty) {
                _text = result.recognizedWords;
                _addDebugInfo('已更新文本: $_text');
              }
              if (result.hasConfidenceRating && result.confidence > 0) {
                _confidence = result.confidence;
                _addDebugInfo('信心指數: $_confidence');
              }
            });
          }
        },
        onSoundLevelChange: (level) {
          // 可選：監控聲音級別變化
          // print('Sound level: $level');
        },
        listenMode: stt.ListenMode.confirmation, // 使用確認模式以提高準確性
        localeId: 'zh_TW', // 設定為繁體中文
        listenFor: const Duration(seconds: 60), // 增加最長聆聽時間
        pauseFor: const Duration(seconds: 5), // 增加暫停時間
        cancelOnError: false, // 出錯時不自動取消
        partialResults: true, // 啟用部分結果
      );

      _addDebugInfo('已發送聆聽請求');
    } catch (e) {
      _addDebugInfo('開始聆聽錯誤: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
          _text = '語音辨識出錯';
        });
      }
    }
  }

  // 切換語音辨識狀態
  void _toggleListening() {
    _addDebugInfo('切換聆聽狀態，當前: $_isListening');

    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _fetchData() async {
    try {
      final Response response = await dio.get(
        'https://jsonplaceholder.typicode.com/posts',
      );
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
              if (_isListening && _confidence > 0)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '信心指數: ${(_confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
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
