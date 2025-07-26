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

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    final assetImage = AssetLoader().getAssetPath(widget.socialMedia);
    final strength = calculatePasswordStrength(widget.password);
    final status = getStrengthStatus(strength);
    final color = getStrengthColor(strength, context);

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
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.error,
                    ),
                  )
                : Icon(Icons.delete, color: theme.colorScheme.error),
            tooltip: 'Delete Password',
            onPressed: _isDeleting ? null : _deletePassword,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header with logo and title
                Column(
                  children: [
                    if (assetImage != null)
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: theme.cardColor,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          assetImage,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.lock,
                            size: 32,
                            color: theme.iconColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      widget.socialMedia,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.username,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Password section
                _SectionHeader(
                  title: 'Password',
                  action: Row(
                    children: [
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
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _obscured ? '••••••••••••' : widget.password,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'monospace',
                            color: theme.textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Password strength
                _SectionHeader(title: 'Password Strength'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            status,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: color,
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
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: strength,
                        backgroundColor: theme.cardColor.withOpacity(0.3),
                        color: color,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Security tips
                _SectionHeader(title: 'Security Tips'),
                const SizedBox(height: 8),
                _SecurityTip(
                  icon: Icons.lock,
                  text: 'Never share your password with anyone',
                  color: theme.accentColor,
                ),
                _SecurityTip(
                  icon: Icons.update,
                  text: 'Change your password every 3-6 months',
                  color: Colors.blue,
                ),
                _SecurityTip(
                  icon: Icons.block,
                  text: 'Avoid password reuse across sites',
                  color: Colors.orange,
                ),
                _SecurityTip(
                  icon: Icons.security,
                  text: 'Consider using a password manager',
                  color: Colors.green,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _SecurityTip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _SecurityTip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.textColor.withOpacity(0.9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}