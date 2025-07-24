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
          } else {
            _passwordController.text = '';
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

    if (username.isEmpty ||
        password.isEmpty ||
        _selectedSocialMedia == null ||
        _selectedCategory == null) {
      await _showErrorDialog(
        'Please fill out all fields and select both an app and category.',
      );
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
    final theme = Provider.of<ThemeNotifier>(
      context,
      listen: false,
    ).currentTheme;

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
          widget.id != null ? 'Edit Password' : 'Add Password',
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
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildSectionLabel("Application"),
                    const SizedBox(height: 8),
                    _buildAppSelector(theme),
                    const SizedBox(height: 24),
                    _buildSectionLabel("Username"),
                    const SizedBox(height: 8),
                    _buildUsernameField(theme),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionLabel("Password"),
                        _buildGenerateButton(theme),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(theme),
                    const SizedBox(height: 24),
                    _buildSectionLabel("Category"),
                    const SizedBox(height: 8),
                    _buildCategoryDropdown(theme),
                    const SizedBox(height: 32),
                    _buildSaveButton(theme, isDark),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String text) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: theme.textColor.withOpacity(0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAppSelector(AppTheme theme) {
    return Material(
      borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isSocialMediaSelected
                  ? theme.accentColor.withOpacity(0.8)
                  : theme.cardColor.withOpacity(0.7),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _isSocialMediaSelected
                      ? theme.accentColor.withOpacity(0.1)
                      : theme.cardColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.apps_rounded,
                  size: 20,
                  color: _isSocialMediaSelected
                      ? theme.accentColor
                      : theme.textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedSocialMedia ?? "Select app",
                  style: GoogleFonts.inter(
                    fontSize: 15,
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
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField(AppTheme theme) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: theme.cardColor,
      elevation: 0,
      child: TextField(
        controller: _usernameController,
        style: GoogleFonts.inter(
          color: theme.textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
          hintText: "Enter username",
          hintStyle: GoogleFonts.inter(
            color: theme.textColor.withOpacity(0.5),
            fontSize: 15,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8, right: 12),
            child: Icon(
              Icons.person_outline_rounded,
              size: 22,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.autorenew_rounded, size: 16, color: theme.accentColor),
          const SizedBox(width: 4),
          Text(
            'Generate',
            style: GoogleFonts.inter(
              fontSize: 12.5,
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
      borderRadius: BorderRadius.circular(12),
      color: theme.cardColor,
      elevation: 0,
      child: TextField(
        controller: _passwordController,
        obscureText: !_passVisible,
        style: GoogleFonts.inter(
          color: theme.textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
          hintText: "Enter password",
          hintStyle: GoogleFonts.inter(
            color: theme.textColor.withOpacity(0.5),
            fontSize: 15,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8, right: 12),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 22,
              color: theme.textColor.withOpacity(0.6),
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _passVisible
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: theme.textColor.withOpacity(0.5),
              size: 22,
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
      borderRadius: BorderRadius.circular(12),
      color: theme.cardColor,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
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
                  fontSize: 15,
                  color: theme.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: InputBorder.none,
            hintText: "Select category",
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: theme.textColor.withOpacity(0.5),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 8, right: 12),
              child: Icon(
                Icons.category_rounded,
                size: 22,
                color: theme.textColor.withOpacity(0.6),
              ),
            ),
          ),
          dropdownColor: theme.cardColor,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: theme.textColor.withOpacity(0.5),
          ),
          style: GoogleFonts.inter(fontSize: 15, color: theme.textColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppTheme theme, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accentColor,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          animationDuration: const Duration(milliseconds: 150),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Save Password',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}
