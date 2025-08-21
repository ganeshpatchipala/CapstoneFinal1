import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/app_bottom_nav.dart';

class RecipeScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData; // ⬅️ Full JSON object

  const RecipeScreen({super.key, required this.recipeData});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  bool logged = false;
  bool error = false;

  @override
  void initState() {
    super.initState();
    _logMealToBackend();
  }

Future<void> _logMealToBackend() async {
  final uri = Uri.parse('http://localhost:5000/log_meal');

  final recipe = widget.recipeData['recipe']; 

  final payload = {
    'name': recipe['meal_name'],      
    'calories': recipe['calories'],
    'protein': recipe['protein'],
    'carbs': recipe['carbs'],
    'fats': recipe['fats'],
  };

  print('Logging: $payload');

  try {
    print('LOGGING PAYLOAD: $payload');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      setState(() => logged = true);
      _showSnackBar('Meal logged successfully!');
    } else {
      setState(() => error = true);
      _showSnackBar('Failed to log meal. (${response.statusCode})');
    }
  } catch (e) {
    setState(() => error = true);
    _showSnackBar('Logging failed: $e');
  }
}


  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipeData['recipe'] ?? {};
    final recipeText = recipe['recipe_text'] ?? 'No recipe text';

    final calories = recipe['calories'] ?? 0;
    final protein = recipe['protein'] ?? 0;
    final carbs = recipe['carbs'] ?? 0;
    final fats = recipe['fats'] ?? 0;
 
    return Scaffold(
      appBar: AppBar(title: const Text('Generated Recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NutritionStat(
                    icon: Icons.local_fire_department,
                    value: calories,
                    color: Colors.orange,
                  ),
                  _NutritionStat(
                    icon: Icons.egg,
                    value: protein,
                    color: Colors.blue,
                  ),
                  _NutritionStat(
                    icon: Icons.grain,
                    value: carbs,
                    color: Colors.green,
                  ),
                  _NutritionStat(
                    icon: Icons.water_drop,
                    value: fats,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                recipeText,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _NutritionStat extends StatelessWidget {
  final IconData icon;
  final dynamic value;
  final Color color;

  const _NutritionStat({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        Text('$value'),
      ],
    );
  }
}
