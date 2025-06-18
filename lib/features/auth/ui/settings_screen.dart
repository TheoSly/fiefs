import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/theme_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choix du thème",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text("Thème clair"),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: themeViewModel.themeMode,
                onChanged: (value) {
                  themeViewModel.setThemeMode(value!);
                },
              ),
            ),
            ListTile(
              title: const Text("Thème sombre"),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: themeViewModel.themeMode,
                onChanged: (value) {
                  themeViewModel.setThemeMode(value!);
                },
              ),
            ),
            ListTile(
              title: const Text("Thème système"),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeViewModel.themeMode,
                onChanged: (value) {
                  themeViewModel.setThemeMode(value!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
