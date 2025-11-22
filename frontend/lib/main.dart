import 'package:flutter/material.dart';
import 'package:frontend/src/models/saved_outfit.dart';
import 'package:frontend/src/models/wardrobe_item.dart';
import 'package:frontend/src/providers/wardrobe_provider.dart';
import 'package:frontend/src/screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await dotenv.load(fileName: ".env");
  Hive.registerAdapter(WardrobeItemAdapter());
  Hive.registerAdapter(SavedOutfitAdapter());

  await Hive.openBox<WardrobeItem>('wardrobeBox');
  await Hive.openBox<SavedOutfit>('savedOutfitsBox');
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
      home: const HomeScreen(),
    );
  }
}
