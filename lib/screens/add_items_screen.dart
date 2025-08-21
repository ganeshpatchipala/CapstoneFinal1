import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'recipe_screen.dart';
import '../widgets/app_bottom_nav.dart';

class AddItemsScreen extends StatefulWidget {
  final List<String> detectedItems;

  const AddItemsScreen({super.key, required this.detectedItems});

  @override
  State<AddItemsScreen> createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  final TextEditingController _controller = TextEditingController();
  late List<String> combinedItems;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    combinedItems = List.from(widget.detectedItems);
  }

  void _addItem() {
    final item = _controller.text.trim();
    if (item.isNotEmpty && !combinedItems.contains(item)) {
      setState(() {
        combinedItems.add(item);
        _controller.clear();
      });
    }
  }

  void _generateRecipe() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final recipe = await ApiService.generateRecipe(combinedItems);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeScreen(recipeData: recipe),
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate recipe: \$e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Ingredients')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add custom ingredient',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addItem,
                ),
              ),
              onSubmitted: (_) => _addItem(),
            ),
            const SizedBox(height: 16),
            const Text('Ingredient List:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: combinedItems.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(combinedItems[index]),
                ),
              ),
            ),
            if (_isGenerating) const CircularProgressIndicator(),
            if (!_isGenerating)
              ElevatedButton(
                onPressed: _generateRecipe,
                child: const Text('Generate2 Recipe'),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}