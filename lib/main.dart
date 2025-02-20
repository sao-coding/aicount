import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

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

    void _fetchData() async {
      print('獲取麥克風權限');
      // 開啟麥克風權限
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        print('麥克風權限已開啟');
      } else {
        print('麥克風權限未開啟');
      }
      // try {
      //   // 获取所有posts
      //   final Response response = await dio.get('https://jsonplaceholder.typicode.com/posts');
      //   final List<dynamic> data = response.data;
      //
      //   setState(() {
      //     // 将每个post转换为Map并添加到_posts
      //     _posts = List<Map<String, dynamic>>.from(data);
      //   });
      // } catch (e) {
      //   print('Error fetching data: $e');
      // }
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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created byD
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
        onPressed: () {
          _fetchData();
        },
        elevation: 4.0,
        shape: const CircleBorder(),
        backgroundColor: Colors.cyan.shade400,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        bottom: false, // This allows content to slide below the navigation bar
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 50, // 从60减小到50
          color: Colors.cyan.shade400,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // 左侧第一个按钮
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  iconSize: 24, // 确保图标大小合适
                  onPressed: () {},
                  constraints: const BoxConstraints(), // 移除默认的内边距限制
                  padding: EdgeInsets.zero, // 移除内边距
                ),
              ),
              // 左侧第二个按钮 - 距离中间留出足够空间
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
              // 右侧第一个按钮 - 距离中间留出足够空间
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
              // 右侧第二个按钮
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
