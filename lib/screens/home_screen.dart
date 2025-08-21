import 'package:flutter/material.dart';
import 'detection_screen.dart';
import 'daily_summary_screen.dart';
import '../widgets/app_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Fridge Image')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DetectionScreen()),
                );
              },
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DailySummaryScreen()),
                );
              },
              child: const Text('Daily Summary'),
            ),
          ],
        ),
      ),
    bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}