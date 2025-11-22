import 'package:flutter/material.dart';
import 'wardrobe_grid_screen.dart';
import 'wardrobe_form_screen.dart';
import 'outfit_generator_screen.dart';
import 'saved_outfits_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    // IMPORTANT: Ensure all these child screens have their main content
    // wrapped in a SingleChildScrollView to prevent body overflow.
    OutfitGeneratorScreen(),
    WardrobeGridScreen(),
    WardrobeFormScreen(),
    SavedOutfitsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBody:
          true, // Critical: Allows the body to extend behind the floating bar

      body: _screens.elementAt(_selectedIndex),

      // Custom Floating Bottom Navigation Bar
      bottomNavigationBar: Padding(
        // Padding just for the margin/space around the bar (not the safe area itself)
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          // FIX: Use SafeArea to automatically add padding below the bar's content
          // to account for the device's home indicator/notch.
          child: SafeArea(
            // Ensures a minimum vertical space, even on devices without a notch
            minimum: const EdgeInsets.symmetric(vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.auto_fix_high),
                    label: 'Generate',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.grid_view_rounded),
                    label: 'Wardrobe',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle_outline),
                    label: 'Add Item',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border),
                    label: 'Saved',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.pinkAccent,
                unselectedItemColor: Colors.grey[500],
                backgroundColor: Colors.white,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                onTap: _onItemTapped,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                iconSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
