import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:pascii/apptheme.dart'; // Assuming your theme code is in theme.dart

class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({super.key});

  @override
  State<ThemeSelectionPage> createState() => _ThemeSelectionPageState();
}

class _ThemeSelectionPageState extends State<ThemeSelectionPage> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
  }

  Future<void> _loadCurrentTheme() async {
    final index = await ThemeManager.getCurrentThemeIndex();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Theme'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ThemeManager.themes.length,
        itemBuilder: (context, index) {
          final theme = ThemeManager.themes[index];
          final isSelected = _selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ThemeSelectionCard(
              theme: theme,
              isSelected: isSelected,
              onTap: () async {
                final themeNotifier = Provider.of<ThemeNotifier>(
                  context,
                  listen: false,
                );
                await themeNotifier.setTheme(index);
                if (mounted) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class ThemeSelectionCard extends StatelessWidget {
  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeSelectionCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.cardColor,
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.accentColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    theme.name,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: theme.accentColor),
                ],
              ),
              const SizedBox(height: 12),
              // Color preview chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ColorChip(
                    color: theme.primaryColor,
                    label: 'Primary',
                    textColor: theme.textColor,
                  ),
                  _ColorChip(
                    color: theme.secondaryColor,
                    label: 'Secondary',
                    textColor: theme.textColor,
                  ),
                  _ColorChip(
                    color: theme.backgroundColor,
                    label: 'Background',
                    textColor: theme.textColor,
                  ),
                  _ColorChip(
                    color: theme.cardColor,
                    label: 'Card',
                    textColor: theme.textColor,
                  ),
                  _ColorChip(
                    color: theme.accentColor,
                    label: 'Accent',
                    textColor: Colors.black,
                  ),
                  _ColorChip(
                    color: theme.bannerColor,
                    label: 'Banner',
                    textColor: theme.textColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Example text styles
              Text(
                'Example Text Styles',
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Large Headline',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(color: theme.textColor),
              ),
              Text(
                'Body text example',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: theme.textColor),
              ),
              Text(
                'Small caption text',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: theme.textColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              // Example buttons
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: const Text('Elevated'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: theme.accentColor,
                    ),
                    child: const Text('Text Button'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final Color color;
  final String label;
  final Color textColor;

  const _ColorChip({
    required this.color,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
