import 'package:flutter/material.dart';
import 'package:frontend/src/models/wardrobe_item.dart';
import 'package:frontend/src/providers/wardrobe_provider.dart';
import 'package:frontend/src/screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Import local files

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // We wrap the entire app in the WardrobeProvider
  Hive.registerAdapter(WardrobeItemAdapter());
  await Hive.openBox<WardrobeItem>('wardrobe');
  runApp(
    ChangeNotifierProvider(
      create: (context) => WardrobeProvider(),
      child: const SmartWardrobeApp(),
    ),
  );
}

class SmartWardrobeApp extends StatelessWidget {
  const SmartWardrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Wardrobe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      // The HomeScreen handles all internal navigation via the BottomNavigationBar
      home: const HomeScreen(),
    );
  }
}