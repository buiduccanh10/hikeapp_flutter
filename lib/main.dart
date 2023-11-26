import 'package:flutter/material.dart';
import 'package:hike_app/screens/home.dart';
import 'package:hike_app/screens/home_page.dart';
import 'package:hike_app/service/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  await databaseHelper.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hiking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: false,
      ),
      home: Home(),
    );
  }
}
