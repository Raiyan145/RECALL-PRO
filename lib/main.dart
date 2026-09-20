import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const RecallProApp());
}

class RecallProApp extends StatelessWidget {
  const RecallProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'RecallPro',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
