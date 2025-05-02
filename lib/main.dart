import 'package:flutter/material.dart';
import 'package:googlemap_tracking/pages/map_page.dart';
import 'background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Background Location Tracker',
      home: const MapPage(),
    );
  }
}
