import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/firebase_options.dart';

import 'notification.dart';


Future<void> backgroungMessage(RemoteMessage message) async {
  // String title = message.notification?.title ?? "Title";
  // String body = message.notification?.body ?? "Body";
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
        id: 123,
        channelKey: 'call_channel',
        color: Colors.white,
        category: NotificationCategory.Call,
        backgroundColor: Colors.orange,
        title: "TITLE HERE",
        fullScreenIntent: true,
        wakeUpScreen: true,
        body: "BODY HERE",
        autoDismissible: false,
        bigPicture:
        'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
        largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
        notificationLayout: NotificationLayout.BigPicture,
        payload: {'notificationId': '1234567890'}),
    actionButtons: [
      NotificationActionButton(
        key: 'ACCEPT',
        label: 'Accept Call',
        color: Colors.green,
        autoDismissible: true,
        actionType: ActionType.SilentAction,
      ),
      NotificationActionButton(
        key: 'REJECT',
        label: 'Reject Call',
        color: Colors.green,
        autoDismissible: true,
        actionType: ActionType.DismissAction
      ),
    ],
  );
}

void setupLaunchChannel() {
  const channel = MethodChannel('com.example.flutter_module');
  
  channel.setMethodCallHandler((methodCall) async {
    switch (methodCall.method) {
      case 'launchApp':
        final action = methodCall.arguments['action'];
        final callId = methodCall.arguments['callId'];
        
        // Navigate to the appropriate screen
        if (action == 'OPEN_FLUTTER_CALL_SCREEN') {
          // navigatorKey.currentState?.pushNamed('/call-screen', 
          //   arguments: {'callId': callId}
          // );
          print("done");
        }
        break;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLaunchChannel();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  await AwesomeNotifications().initialize(
      null, //'resource://drawable/res_app_icon',//
      [
        NotificationChannel(
            channelKey: 'call_channel',
            channelName: 'Call Channel',
            channelDescription: 'Notification tests as alerts',
            playSound: true,
            enableVibration: true,
            defaultRingtoneType: DefaultRingtoneType.Ringtone,
            // onlyAlertOnce: true,
            // groupAlertBehavior: GroupAlertBehavior.Children,
            importance: NotificationImportance.High,
            locked: true,
            defaultPrivacy: NotificationPrivacy.Private,
            defaultColor: Colors.redAccent,
            ledColor: Colors.white)
      ],
      debug: true);
  FirebaseMessaging.onBackgroundMessage(backgroungMessage);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Module',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Module'),
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
  int _counter = 0;

  @override
  void initState() {
    NotificationController().getToken().then((value){
      print(value);
    });
    NotificationController.startListeningNotificationEvents();
    // TODO: implement initState
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => SystemNavigator.pop(animated: true),
        ),
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
