//moduleHome.dart
import 'package:flutter/material.dart';
import 'package:modules/Modules/Module1/IdeationScreen.dart';

class ModuleHomeScreen extends StatelessWidget {
  const ModuleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Educational Modules'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildModuleCard(
            context,
            'Module 1: Idea Generation and Evaluation',
            'Learn how to come up with and evaluate business ideas.',
            const IdeationScreen(), // Navigate to IdeationScreen
          ),
          _buildModuleCard(
            context,
            'Module 2: Business Plan Development',
            'Create a solid business plan for your idea.',
            null, // Placeholder for future BusinessPlanScreen
          ),
          _buildModuleCard(
            context,
            'Module 3: Branding and Naming',
            'Develop a strong brand and choose a name.',
            null, // Placeholder for future screen
          ),
          _buildModuleCard(
            context,
            'Module 4: Selecting Location',
            'Find the best location for your business.',
            null, // Placeholder for future screen
          ),
          _buildModuleCard(
            context,
            'Module 5: Registration and Licensing',
            'Understand the legal aspects of starting a business.',
            null, // Placeholder for future screen
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, String description, Widget? screen) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          if (screen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen), // Navigate using MaterialPageRoute
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This module is not available yet.')),
            );
          }
        },
      ),
    );
  }
}
