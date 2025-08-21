import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DailySummaryScreen extends StatefulWidget {
  const DailySummaryScreen({super.key});

  @override
  State<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends State<DailySummaryScreen> {
  late Future<Map<String, dynamic>> _summaryFuture;

  Future<Map<String, dynamic>> _loadSummary() async {
    final totals = await ApiService.fetchDailyTotals();
    final meals = await ApiService.fetchDailyMeals();
    return {'totals': totals, 'meals': meals};
  }

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Summary')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }

          final totals = snapshot.data!['totals'] as Map<String, dynamic>;
          final meals = snapshot.data!['meals'] as List;

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Calories: ${totals['total_calories'] ?? 0}') ,
                      Text('Protein: ${totals['total_protein'] ?? 0}g'),
                      Text('Carbs: ${totals['total_carbs'] ?? 0}g'),
                      Text('Fats: ${totals['total_fats'] ?? 0}g'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index] as Map<String, dynamic>;
                    return ListTile(
                      title: Text(meal['name'] ?? 'Meal'),
                      subtitle: Text(
                        'Cals: ${meal['calories'] ?? 0}, '
                        'P: ${meal['protein'] ?? 0}g, '
                        'C: ${meal['carbs'] ?? 0}g, '
                        'F: ${meal['fats'] ?? 0}g',
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}