import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pascii/services/local_storage.dart';
import 'package:pascii/services/biometrics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String githubUrl = 'https://github.com/cxuri/pascii';
  static const String releasesUrl =
      'https://github.com/cxuri/pascii/releases/latest';

  late String _appVersion = 'Loading...';
  bool _notifyUpdates = true;
  bool _biometricsEnabled = false;
  bool _biometricsSupported = false;
  bool _isLoading = true;
  final _storage = LocalStorage();
  final Biometrics _biometrics = Biometrics();

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final isSupported = await _biometrics.canAuthenticate();

    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      _notifyUpdates = prefs.getBool('notifyUpdates') ?? true;
      _biometricsEnabled = prefs.getBool('biometricsEnabled') ?? false;
      _biometricsSupported = isSupported;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      if (key == 'notifyUpdates') _notifyUpdates = value;
      if (key == 'biometricsEnabled') _biometricsEnabled = value;
    });
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (!_biometricsSupported) return;

    setState(() => _isLoading = true);
    try {
      if (value) {
        final authenticated = await _biometrics.authenticate();
        if (!authenticated) return;
      }
      await _saveSetting('biometricsEnabled', value);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to toggle biometrics: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _shareApp() async {
    final message =
        '''
🔒 Pascii - Secure Password Manager 🔒

Version: $_appVersion

Features:
✓ AES-256 Encryption
✓ Cross-Platform Sync
✓ Open Source

Download now: $releasesUrl

#PasswordManager #Security''';

    try {
      await Share.share(message, subject: 'Check out Pascii Password Manager');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: enabled ? theme.colorScheme.onSurface : theme.disabledColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: enabled
                    ? theme.colorScheme.onSurface.withOpacity(0.7)
                    : theme.disabledColor,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
      onTap: enabled ? onTap : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: colorScheme.primary),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : ListView(
              children: [
                _buildSectionHeader('Appearance'),
                _buildSettingTile(
                  icon: Icons.palette,
                  title: 'App Theme',
                  subtitle: 'Change color theme',
                  iconColor: colorScheme.secondary,
                  onTap: () {
                    Navigator.pushNamed(context, '/theme');
                  },
                ),

                _buildSectionHeader('General'),
                _buildSettingTile(
                  icon: Icons.notifications,
                  title: 'Update Notifications',
                  subtitle: 'Get notified about new versions',
                  trailing: Switch(
                    value: _notifyUpdates,
                    onChanged: (value) => _saveSetting('notifyUpdates', value),
                    activeColor: colorScheme.primary,
                  ),
                  iconColor: colorScheme.primary,
                ),
                _buildSettingTile(
                  icon: Icons.cloud_upload,
                  title: 'Cloud Sync',
                  subtitle: 'Coming soon',
                  enabled: false,
                  iconColor: Colors.blue,
                ),

                _buildSectionHeader('About'),
                _buildSettingTile(
                  icon: Icons.code,
                  title: 'Source Code',
                  subtitle: 'View on GitHub',
                  onTap: () => _launchUrl(githubUrl),
                  iconColor: colorScheme.secondary,
                ),
                _buildSettingTile(
                  icon: Icons.share,
                  title: 'Share App',
                  subtitle: 'Tell your friends',
                  onTap: _shareApp,
                  iconColor: colorScheme.tertiary,
                ),
                _buildSettingTile(
                  icon: Icons.star,
                  title: 'Rate App',
                  subtitle: 'Leave a review',
                  onTap: () => _launchUrl('$githubUrl/stargazers'),
                  iconColor: Colors.amber,
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Pascii v$_appVersion',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      barrierColor: colors.scrim.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.outline.withOpacity(0.2), width: 1),
        ),
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo with subtle shadow
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: colors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: colors.onSurface.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/ic_launcher.jpeg'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // App Name with subtle gradient
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [colors.primary, colors.primaryContainer],
                  ).createShader(bounds),
                  child: Text(
                    'PASCII',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Version
                Text(
                  'v$_appVersion',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 28),

                // Description
                Text(
                  'Secure, open-source password manager\nfor modern users',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.8),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Buttons with modern spacing
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _launchUrl(githubUrl),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: colors.outline.withOpacity(0.3),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.code, size: 18, color: colors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Source',
                              style: textTheme.labelLarge?.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _launchUrl(githubUrl),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: colors.primary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, size: 18, color: colors.onPrimary),
                            const SizedBox(width: 8),
                            Text(
                              'Rate',
                              style: textTheme.labelLarge?.copyWith(
                                color: colors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Footer with subtle divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.outline.withOpacity(0.1),
                ),
                const SizedBox(height: 16),
                Text(
                  '© ${DateTime.now().year} PASCII ',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
