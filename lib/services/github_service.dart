// services/github_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GitHubService {
  static const String repoOwner = 'cxuri';
  static const String repoName = 'pascii';
  static const String lastShownReleaseKey = '1.0.0';

  Future<Map<String, dynamic>?> getLatestRelease() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching GitHub release: $e');
    }
    return null;
  }

  Future<bool> shouldShowUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final lastShownTag = prefs.getString(lastShownReleaseKey);

    final release = await getLatestRelease();
    if (release == null) return false;

    final latestTag = release['tag_name'];
    final isNewVersion = _compareVersions(latestTag, currentVersion) > 0;
    final isNewToUser = latestTag != lastShownTag;

    return isNewVersion && isNewToUser;
  }

  Future<void> markAsSeen() async {
    final release = await getLatestRelease();
    if (release != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(lastShownReleaseKey, release['tag_name']);
    }
  }

  int _compareVersions(String v1, String v2) {
    // Remove 'v' prefix if present
    v1 = v1.startsWith('v') ? v1.substring(1) : v1;
    v2 = v2.startsWith('v') ? v2.substring(1) : v2;

    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < v1Parts.length; i++) {
      if (i >= v2Parts.length) return 1;
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }
    return 0;
  }
}
