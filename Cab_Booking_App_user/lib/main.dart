import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/infoHandler/app_info.dart';
import 'package:user_app/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => AppInfo(),
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cab_Services',
      home: HomePage(),
    ));
  }
}
