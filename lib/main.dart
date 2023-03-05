import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_test_app/ui/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'app',
      title: 'Ставки',
      home: HomeScreen(),
    );
  }
}
