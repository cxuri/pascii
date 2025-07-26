import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pascii/services/local_storage.dart';
import 'package:pascii/services/encryption_service.dart';
import 'package:pascii/pages/generate_password.dart';
import 'package:pascii/pages/select_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pascii/apptheme.dart';

class NewPass extends StatefulWidget {
  final String? id;
  const NewPass({super.key, this.id});

  @override
  _NewPassState createState() => _NewPassState();
}

class _NewPassState extends State<NewPass> {
  final List<String> categories = [
    'Important',
    'Work',
    'School',
    'Entertainment',
    'Social Media',
    'Generic',
    'Secret',
  ];

  final _storage = LocalStorage();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedSocialMedia;
  String? _selectedCategory;
  bool _passVisible = false;
  bool _isSocialMediaSelected = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPassword();
  }

  Future<void> _loadExistingPassword() async {
    if (widget.id != null) {
      setState(() => _isLoading = true);
      try {
        final data = await _storage.getPassword(widget.id!);
        if (data != null) {
          _usernameController.text = data['username'] ?? '';
          if (data['password'] != null) {
            try {
              final decrypted = await _storage.decryptPassword(data['password']);
              _passwordController.text = decrypted;
            } catch (e) {
              debugPrint('Error decrypting password: $e');
              _passwordController.text = '';
              await _showErrorDialog('Failed to decrypt password');
            }
          }
          _selectedCategory = data['category'] ?? categories.first;
          _selectedSocialMedia = data['type'];
          _isSocialMediaSelected = _selectedSocialMedia != null;
        } else {
          await _showErrorDialog('Password data not found');
        }
      } catch (e) {
        debugPrint('Error loading password: $e');
        await _showErrorDialog('Error loading password: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    HapticFeedback.lightImpact();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty || _selectedSocialMedia == null || _selectedCategory == null) {
      await _showErrorDialog('Please fill out all fields and select both an app and category.');
      return;
    }

    try {
      setState(() => _isLoading = true);
      final keys = await _storage.getEncryptionKeys();
      final encryptionService = EncryptionService(keys['key']!, keys['iv']!);
      final encryptedPassword = encryptionService.encryptData(password);

      await _storage.savePassword(
        username: username,
        password: encryptedPassword,
        type: _selectedSocialMedia!,
        category: _selectedCategory!,
      );

      await Fluttertoast.showToast(
        msg: "Password saved",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      await _showErrorDialog('Error saving password: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showErrorDialog(String message) async {
    final theme = Provider.of<ThemeNotifier>(context, listen: false).currentTheme;

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: theme.accentColor, size: 40),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.textColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.id != null ? 'Edit Password' : 'Create New Password',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32,
            color: theme.textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.id == null) ...[
                    _buildWelcomeHeader(theme),
                    const SizedBox(height: 24),
                  ],
                  _buildFormSection(theme),
                  const SizedBox(height: 32),
                  _buildSecurityTipsSection(theme),
                  const SizedBox(height: 32),
                  _buildSaveButton(theme),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Secure Your Account',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add your credentials to keep them safe and encrypted',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: theme.textColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("Application"),
        const SizedBox(height: 8),
        _buildAppSelector(theme),
        const SizedBox(height: 20),
        _buildSectionLabel("Username"),
        const SizedBox(height: 8),
        _buildUsernameField(theme),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel("Password"),
            _buildGenerateButton(theme),
          ],
        ),
        const SizedBox(height: 8),
        _buildPasswordField(theme),
        const SizedBox(height: 20),
        _buildSectionLabel("Category"),
        const SizedBox(height: 8),
        _buildCategoryDropdown(theme),
      ],
    );
  }

  Widget _buildSecurityTipsSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Tips',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 12),
        _buildSecurityTip(
          icon: Icons.shield,
          title: 'Strong Passwords',
          description: 'Use a mix of letters, numbers & special characters',
          color: Colors.blueAccent,
          theme: theme,
        ),
        _buildSecurityTip(
          icon: Icons.autorenew,
          title: 'Regular Updates',
          description: 'Change passwords every 3-6 months',
          color: Colors.green,
          theme: theme,
        ),
        _buildSecurityTip(
          icon: Icons.phonelink_lock,
          title: 'Unique Passwords',
          description: 'Never reuse passwords across sites',
          color: Colors.orange,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;

    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: theme.textColor.withOpacity(0.7),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildAppSelector(AppTheme theme) {
    return Material(
      borderRadius: BorderRadius.circular(14),
      color: theme.cardColor,
      elevation: 0,
      child: InkWell(
        onTap: () async {
          HapticFeedback.selectionClick();
          final selectedApp = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SelectApp()),
          );
          if (selectedApp != null) {
            setState(() {
              _selectedSocialMedia = selectedApp;
              _isSocialMediaSelected = true;
            });
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isSocialMediaSelected
                  ? theme.accentColor.withOpacity(0.3)
                  : theme.cardColor.withOpacity(0.7),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isSocialMediaSelected
                      ? theme.accentColor.withOpacity(0.1)
                      : theme.cardColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.apps_rounded,
                  size: 22,
                  color: _isSocialMediaSelected
                      ? theme.accentColor
                      : theme.textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedSocialMedia ?? "Select application",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: _isSocialMediaSelected
                        ? FontWeight.w500
                        : FontWeight.w400,
                    color: _isSocialMediaSelected
                        ? theme.textColor
                        : theme.textColor.withOpacity(0.6),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.textColor.withOpacity(0.4),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField(AppTheme theme) {
    return Material(
      borderRadius: BorderRadius.circular(14),
      color: theme.cardColor,
      elevation: 0,
      child: TextField(
        controller: _usernameController,
        style: GoogleFonts.inter(
          color: theme.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.cardColor,
          hintText: "Enter username or email",
          hintStyle: GoogleFonts.inter(
            color: theme.textColor.withOpacity(0.5),
            fontSize: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Icon(
              Icons.person_outline_rounded,
              size: 24,
              color: theme.textColor.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton(AppTheme theme) {
    return TextButton(
      onPressed: () async {
        HapticFeedback.selectionClick();
        final generatedPassword = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GeneratePassword()),
        );
        if (generatedPassword != null) {
          setState(() => _passwordController.text = generatedPassword);
        }
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.autorenew_rounded, size: 18, color: theme.accentColor),
          const SizedBox(width: 6),
          Text(
            'Generate',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(AppTheme theme) {
    return Material(
      borderRadius: BorderRadius.circular(14),
      color: theme.cardColor,
      elevation: 0,
      child: TextField(
        controller: _passwordController,
        obscureText: !_passVisible,
        style: GoogleFonts.inter(
          color: theme.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.cardColor,
          hintText: "Enter password",
          hintStyle: GoogleFonts.inter(
            color: theme.textColor.withOpacity(0.5),
            fontSize: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 24,
              color: theme.textColor.withOpacity(0.6),
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _passVisible
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: theme.textColor.withOpacity(0.5),
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _passVisible = !_passVisible);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(AppTheme theme) {
    return Material(
      borderRadius: BorderRadius.circular(14),
      color: theme.cardColor,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedCategory,
          onChanged: (newValue) {
            HapticFeedback.selectionClick();
            setState(() => _selectedCategory = newValue);
          },
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(
                category,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: theme.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: theme.cardColor,
            hintText: "Select category",
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: theme.textColor.withOpacity(0.5),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Icon(
                Icons.category_rounded,
                size: 24,
                color: theme.textColor.withOpacity(0.6),
              ),
            ),
          ),
          dropdownColor: theme.cardColor,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: theme.textColor.withOpacity(0.5),
          ),
          style: GoogleFonts.inter(fontSize: 16, color: theme.textColor),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildSecurityTip({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required AppTheme theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AppTheme theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accentColor,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          animationDuration: const Duration(milliseconds: 150),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'Save Password',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}