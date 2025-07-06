import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/providers/time_entry_provider.dart';
import 'package:time_tracker/providers/project_provider.dart';
import 'package:time_tracker/providers/task_provider.dart';
import 'package:time_tracker/screens/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProjectProvider()),
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => TimeEntryProvider()),
      ],
      child: MaterialApp(
        title: 'Time Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
