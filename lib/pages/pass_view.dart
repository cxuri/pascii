import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pascii/pages/new_pass.dart';
import 'package:pascii/services/local_storage.dart';
import 'package:pascii/services/asset_loader.dart';
import 'package:provider/provider.dart';
import 'package:pascii/apptheme.dart';

class PassView extends StatefulWidget {
  final String username;
  final String password;
  final String socialMedia;
  final String encryptionType;
  final String docId;
  final Function()? onUpdate;

  const PassView({
    required this.username,
    required this.password,
    required this.socialMedia,
    required this.encryptionType,
    required this.docId,
    this.onUpdate,
    super.key,
  });

  @override
  _PassViewState createState() => _PassViewState();
}

class _PassViewState extends State<PassView> {
  bool _obscured = true;
  bool _isDeleting = false;
  bool _isCopying = false;
  final _storage = LocalStorage();

  double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;
    strength += (password.length / 20).clamp(0.0, 0.3);

    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int varietyCount = [hasLower, hasUpper, hasDigit, hasSpecial].where((b) => b).length;
    strength += (varietyCount * 0.175).clamp(0.0, 0.7);

    return strength.clamp(0.0, 1.0);
  }

  String getStrengthStatus(double strength) {
    if (strength < 0.3) return 'Weak';
    if (strength < 0.6) return 'Medium';
    if (strength < 0.8) return 'Strong';
    return 'Very Strong';
  }

  Color getStrengthColor(double strength, BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context, listen: false).currentTheme;
    if (strength < 0.3) return theme.colorScheme.error;
    if (strength < 0.6) return Colors.orange;
    if (strength < 0.8) return Colors.lightGreen;
    return theme.accentColor;
  }

  Future<void> _deletePassword() async {
    if (_isDeleting) return;

    setState(() => _isDeleting = true);

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final theme = Provider.of<ThemeNotifier>(context, listen: false).currentTheme;
          return AlertDialog(
            backgroundColor: theme.cardColor,
            title: Text(
              'Delete Password',
              style: TextStyle(color: theme.textColor),
            ),
            content: Text(
              'Are you sure you want to delete this password?',
              style: TextStyle(color: theme.textColor.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.accentColor),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        setState(() => _isDeleting = false);
        return;
      }
      await _storage.deletePassword(widget.docId);

      if (!mounted) return;

      widget.onUpdate?.call();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final theme = Provider.of<ThemeNotifier>(context, listen: false).currentTheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting password: ${e.toString()}'),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _copyToClipboard() async {
    if (_isCopying) return;

    setState(() => _isCopying = true);

    try {
      await Clipboard.setData(ClipboardData(text: widget.password));
      if (!mounted) return;

      final theme = Provider.of<ThemeNotifier>(context, listen: false).currentTheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password copied to clipboard',
            style: TextStyle(color: theme.textColor),
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.cardColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final theme = Provider.of<ThemeNotifier>(context, listen: false).currentTheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy: ${e.toString()}'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _isCopying = false);
        });
      }
    }
  }

  Widget _buildPasswordCriteria(String text, bool isValid, BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context, listen: false).currentTheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            color: isValid ? theme.accentColor : theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: theme.textColor.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthBar(double strength, BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context, listen: false).currentTheme;
    final status = getStrengthStatus(strength);
    final color = getStrengthColor(strength, context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Strength: $status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.textColor,
              ),
            ),
            Text(
              '${(strength * 100).round()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: strength,
          backgroundColor: theme.cardColor.withOpacity(0.3),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    final assetImage = AssetLoader().getAssetPath(widget.socialMedia);
    final strength = calculatePasswordStrength(widget.password);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Password Details',
          style: TextStyle(
            color: theme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.iconColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: theme.iconColor,
            ),
            tooltip: 'Edit Password',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewPass(id: widget.docId),
                ),
              );
            },
          ),
          IconButton(
            icon: _isDeleting
                ? CircularProgressIndicator(color: theme.colorScheme.error)
                : Icon(Icons.delete, color: theme.colorScheme.error),
            tooltip: 'Delete Password',
            onPressed: _isDeleting ? null : _deletePassword,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform logo and title
            Center(
              child: Column(
                children: [
                  if (assetImage != null)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        assetImage,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.lock,
                          size: 40,
                          color: theme.iconColor,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    widget.socialMedia,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Password information card
            Card(
              elevation: 0,
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Username:', widget.username, context),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Password: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _obscured ? '••••••••••••' : widget.password,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: theme.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _obscured ? Icons.visibility : Icons.visibility_off,
                            size: 20,
                            color: theme.iconColor,
                          ),
                          onPressed: () => setState(() => _obscured = !_obscured),
                        ),
                        IconButton(
                          icon: _isCopying
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.iconColor,
                                  ),
                                )
                              : Icon(Icons.copy, size: 20, color: theme.iconColor),
                          onPressed: _isCopying ? null : _copyToClipboard,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Encryption:', widget.encryptionType, context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Password strength section
            Card(
              elevation: 0,
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Health',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStrengthBar(strength, context),
                    const SizedBox(height: 24),
                    Text(
                      'Password Policies',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordCriteria(
                      'At least 12 characters long (current: ${widget.password.length})',
                      widget.password.length >= 12,
                      context,
                    ),
                    _buildPasswordCriteria(
                      'Contains uppercase and lowercase letters',
                      widget.password.contains(RegExp(r'[A-Z]')) &&
                          widget.password.contains(RegExp(r'[a-z]')),
                      context,
                    ),
                    _buildPasswordCriteria(
                      'Contains numbers (0-9)',
                      widget.password.contains(RegExp(r'[0-9]')),
                      context,
                    ),
                    _buildPasswordCriteria(
                      'Contains special characters (!@#...)',
                      widget.password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
                      context,
                    ),
                    _buildPasswordCriteria(
                      'No repeated characters (e.g., "aaa")',
                      !_hasRepeatedChars(widget.password),
                      context,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Security tips
            Card(
              elevation: 0,
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security Tips',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem('🔒 Never share your password with anyone', context),
                    _buildTipItem('🔄 Change your password every 3-6 months', context),
                    _buildTipItem('🚫 Avoid password reuse across sites', context),
                    _buildTipItem('🔑 Use a password manager for security', context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context, listen: false).currentTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: theme.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String text, BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context, listen: false).currentTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: theme.textColor.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasRepeatedChars(String password) {
    return RegExp(r'(.)\1{2,}').hasMatch(password);
  }
}
