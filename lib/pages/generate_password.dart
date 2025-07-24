import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:pascii/apptheme.dart'; // Assuming this contains your theme classes
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class GeneratePassword extends StatefulWidget {
  const GeneratePassword({Key? key}) : super(key: key);

  @override
  State<GeneratePassword> createState() => _GeneratePasswordState();
}

class _GeneratePasswordState extends State<GeneratePassword> {
  double _passwordLength = 16;
  String _generatedPassword = '';
  bool _includeUpperCase = true;
  bool _includeLowerCase = true;
  bool _includeNumbers = true;
  bool _includeSpecialChars = true;
  late AppTheme _currentTheme;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _generatePassword();
  }

  Future<void> _loadTheme() async {
    _currentTheme = await ThemeManager.getCurrentTheme();
    setState(() {});
  }

  void _generatePassword() {
    setState(() {
      _generatedPassword = _generateSecurePassword();
    });
  }

  String _generateSecurePassword() {
    const upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (_includeUpperCase) chars += upperCase;
    if (_includeLowerCase) chars += lowerCase;
    if (_includeNumbers) chars += numbers;
    if (_includeSpecialChars) chars += specialChars;

    if (chars.isEmpty) return '';

    return List.generate(
      _passwordLength.toInt(),
      (index) => chars[Random().nextInt(chars.length)],
    ).join();
  }

  double _calculateStrength() {
    if (_generatedPassword.isEmpty) return 0.0;

    double strength = 0.0;
    if (_passwordLength >= 8) strength += 0.2;
    if (_passwordLength >= 12) strength += 0.2;
    if (_passwordLength >= 16) strength += 0.1;
    if (_includeUpperCase) strength += 0.2;
    if (_includeLowerCase) strength += 0.2;
    if (_includeNumbers) strength += 0.2;
    if (_includeSpecialChars) strength += 0.2;

    return strength.clamp(0.0, 1.0);
  }

  Color _getStrengthColor() {
    final strength = _calculateStrength();
    if (strength <= 0.3) return const Color(0xFFF44336);
    if (strength <= 0.6) return const Color(0xFFFFC107);
    if (strength <= 0.8) return const Color(0xFF4CAF50);
    return const Color(0xFF2196F3);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _currentTheme.themeData,
      child: Scaffold(
        backgroundColor: _currentTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: _currentTheme.iconColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generate Password',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _currentTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Customize your secure password',
                style: GoogleFonts.inter(
                  color: _currentTheme.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Password Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _currentTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _generatedPassword,
                            style: GoogleFonts.robotoMono(
                              fontSize: 18,
                              color: _currentTheme.textColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          onPressed: _generatePassword,
                          color: _currentTheme.accentColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _calculateStrength(),
                      backgroundColor: _currentTheme.cardColor.withOpacity(0.5),
                      color: _getStrengthColor(),
                      minHeight: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Length Slider
              Text(
                'LENGTH: ${_passwordLength.toInt()}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _currentTheme.textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _passwordLength,
                min: 8,
                max: 64,
                divisions: 56,
                activeColor: _currentTheme.accentColor,
                inactiveColor: _currentTheme.cardColor.withOpacity(0.5),
                onChanged: (value) {
                  setState(() => _passwordLength = value);
                  _generatePassword();
                },
              ),
              const SizedBox(height: 24),

              // Character Options
              Text(
                'INCLUDE:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _currentTheme.textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildToggle('A-Z', _includeUpperCase, (v) {
                    setState(() => _includeUpperCase = v);
                    _generatePassword();
                  }),
                  _buildToggle('a-z', _includeLowerCase, (v) {
                    setState(() => _includeLowerCase = v);
                    _generatePassword();
                  }),
                  _buildToggle('0-9', _includeNumbers, (v) {
                    setState(() => _includeNumbers = v);
                    _generatePassword();
                  }),
                  _buildToggle('!@#', _includeSpecialChars, (v) {
                    setState(() => _includeSpecialChars = v);
                    _generatePassword();
                  }),
                ],
              ),
              const Spacer(),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _generatedPassword),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentTheme.accentColor,
                    foregroundColor: _currentTheme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: value
              ? _currentTheme.accentColor.withOpacity(0.2)
              : _currentTheme.cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value
                ? _currentTheme.accentColor
                : _currentTheme.textColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: value ? _currentTheme.accentColor : _currentTheme.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
