import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() {
  runApp(const MyUniversityApp());
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black, // Set this to match your app's theme
  ));
}

class MyUniversityApp extends StatelessWidget {
  const MyUniversityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My EIU',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  final urlList = const [
    'https://aao.eiu.edu.vn/#/home',
    'https://moodle.eiu.edu.vn/',
    'https://classroom.google.com/',
    'https://poe.com/',
  ];
  final webViewController = Completer<WebViewController>();
  final currentIndexNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    precache();
  }

  void precache() async {
    var cacheManager = DefaultCacheManager();
    for (var url in urlList) {
      await cacheManager.downloadFile(url);
    }
  }

  DateTime? lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (lastPressedAt == null ||
            now.difference(lastPressedAt!) > const Duration(seconds: 2)) {
          lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tap again to exit'),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: ValueListenableBuilder<int>(
            valueListenable: currentIndexNotifier,
            builder: (context, value, child) {
              return WebView(
                key: UniqueKey(),
                initialUrl: urlList[value],
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController w) {
                  webViewController.complete(w);
                },
              );
            },
          ),
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Colors.blue.shade100,
            labelTextStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          child: NavigationBar(
            height: 60,
            backgroundColor: const Color(0xFFf1f5fb),
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              currentIndexNotifier.value = index;
              setState(() => currentIndex = index);
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.laptop_chromebook_rounded), label: 'Moodle'),
              NavigationDestination(
                  icon: Icon(Icons.class_rounded), label: 'Classroom'),
              NavigationDestination(
                  icon: Icon(Icons.chat_outlined), label: 'AI'),
            ],
          ),
        ),
      ),
    );
  }
}
