import 'package:flutter/material.dart';
import 'package:pascii/apptheme.dart';
import 'package:pascii/pages/pass_view.dart';
import 'package:pascii/services/encryption_service.dart';
import 'package:pascii/services/local_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pascii/services/asset_loader.dart';
import 'package:pascii/services/biometrics.dart';
import 'package:pascii/pages/note_view.dart';
import 'package:pascii/services/github_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final Biometrics _biometrics = Biometrics();
  final _storage = LocalStorage();
  late final EncryptionService _aes;

  String searchQuery = '';
  int _selectedIndex = 0;
  late AppTheme _currentTheme;

  List<Map<String, dynamic>> passwords = [];
  List<Map<String, dynamic>> notes = [];

  bool _showUpdateBanner = false;
  String _changelog = '';
  String _releaseUrl = '';
  String _releaseName = '';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _aes = _storage.encryptionService;
    _currentTheme = await ThemeManager.getCurrentTheme();
    _loadData();
    _checkForUpdates();
    if (mounted) setState(() {});
  }

  Future<void> _loadTheme() async {
    _currentTheme = await ThemeManager.getCurrentTheme();
    if (mounted) setState(() {});
  }

  Future<void> _checkForUpdates() async {
    final shouldShow = await GitHubService().shouldShowUpdate();
    if (shouldShow) {
      final release = await GitHubService().getLatestRelease();
      if (release != null && mounted) {
        setState(() {
          _showUpdateBanner = true;
          _changelog = release['body'] ?? 'No changelog provided';
          _releaseName = release['name'] ?? release['tag_name'];
          _releaseUrl = release['html_url'];
        });
      }
    }
  }

  void _dismissUpdateBanner() {
    GitHubService().markAsSeen();
    setState(() => _showUpdateBanner = false);
  }

  Future<void> _openReleasePage() async {
    if (_releaseUrl.isNotEmpty && !await launchUrl(Uri.parse(_releaseUrl))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Couldn't open browser")));
      }
    }
  }

  Future<void> _loadData() async {
    await _loadPasswords();
    await _loadNotes();
  }

  Future<void> _loadPasswords() async {
    try {
      final loadedPasswords = await _storage.getPasswords();
      if (mounted) {
        setState(() {
          passwords = List<Map<String, dynamic>>.from(loadedPasswords);
          debugPrint('Loaded passwords: ${passwords.length}');
          debugPrint('First password: ${passwords.isNotEmpty ? passwords.first : "none"}');
        });
      }
    } catch (e) {
      debugPrint('Error loading passwords: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading passwords')),
        );
      }
    }
  }

  Future<void> _loadNotes() async {
    final loadedNotes = await _storage.getNotes();
    if (mounted) setState(() => notes = List<Map<String, dynamic>>.from(loadedNotes));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: buildAppBar(colorScheme, textTheme),
      body: Column(
        children: [
          if (_showUpdateBanner)
            UpdateBanner(
              releaseName: _releaseName,
              changelog: _changelog,
              releaseUrl: _releaseUrl,
              onDismiss: _dismissUpdateBanner,
              onViewRelease: _openReleasePage,
              bannerColor: colorScheme.primaryContainer,
            ),
          Expanded(
            child: _selectedIndex == 0
                ? buildBody(colorScheme, textTheme)
                : buildNotesScreen(colorScheme, textTheme),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(colorScheme),
      floatingActionButton: buildFloatingActionButton(colorScheme),
    );
  }

  AppBar buildAppBar(ColorScheme colorScheme, TextTheme textTheme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'P A S C ',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
            TextSpan(
              text: 'I I',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: Icon(Icons.settings, size: 24, color: colorScheme.primary),
          ),
        ),
      ],
      leading: const SizedBox(width: 56),
    );
  }

  Widget buildBody(ColorScheme colorScheme, TextTheme textTheme) {
    return WillPopScope(
      onWillPop: () async {
        await _loadData();
        return true;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSearchBar(colorScheme, textTheme),
          Expanded(
            child: passwords.isEmpty
                ? Center(
                    child: Text(
                      'No passwords saved yet',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onBackground,
                      ),
                    ),
                  )
                : ListView(
                    children: _buildPasswordSections(colorScheme, textTheme),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 20,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (query) =>
                    setState(() => searchQuery = query.trim().toLowerCase()),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for saved passwords...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPasswordSections(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final filteredPasswords = passwords.where((p) {
      return p['username'].toString().toLowerCase().contains(searchQuery) ||
          p['type'].toString().toLowerCase().contains(searchQuery);
    }).toList();

    final categorized = _categorizePasswords(filteredPasswords);
    return categorized.entries
        .map(
          (entry) => buildCategorySection(
            entry.key,
            entry.value,
            colorScheme,
            textTheme,
          ),
        )
        .toList();
  }

  Map<String, List<Map<String, dynamic>>> _categorizePasswords(
    List<Map<String, dynamic>> passwords,
  ) {
    Map<String, List<Map<String, dynamic>>> result = {};
    for (var p in passwords) {
      String category = (p['category'] as String?) ?? 'Other';
      result.putIfAbsent(category, () => []).add(p);
    }
    return result;
  }

  Widget buildCategorySection(
    String category,
    List<Map<String, dynamic>> passwords,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25, top: 15, bottom: 15),
          child: Text(
            category[0].toUpperCase() + category.substring(1),
            style: GoogleFonts.exo(
              textStyle: textTheme.titleMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
          ),
        ),
        ...passwords
            .map((p) => buildPasswordListItem(p, colorScheme, textTheme))
            .toList(),
      ],
    );
  }

  Widget buildPasswordListItem(
    Map<String, dynamic> password,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, top: 8, bottom: 8, right: 25),
      child: ListTile(
        leading: Image(
          image: AssetImage(
            AssetLoader().getAssetPath((password['type'] as String).toLowerCase()),
          ),
        ),
        title: Text(
          password['username'] as String,
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onBackground),
        ),
        subtitle: Text(
          password['type'] as String,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.copy, size: 20, color: colorScheme.primary),
          onPressed: () => _handleCopyPassword(password),
        ),
        onTap: () => _handlePasswordView(password),
      ),
    );
  }

  Widget buildNotesScreen(ColorScheme colorScheme, TextTheme textTheme) {
    final filteredNotes = searchQuery.isEmpty
        ? notes
        : notes.where((note) {
            return note['name'].toString().toLowerCase().contains(
                  searchQuery,
                ) ||
                note['type'].toString().toLowerCase().contains(searchQuery);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (searchQuery.isNotEmpty || filteredNotes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
              vertical: 16.0,
            ),
            child: Text(
              'Your Notes',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
          ),
        if (filteredNotes.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 48,
                    color: colorScheme.onBackground.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    searchQuery.isEmpty
                        ? 'No notes yet'
                        : 'No notes matching your search',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) =>
                  buildNoteItem(filteredNotes[index], colorScheme, textTheme),
            ),
          ),
      ],
    );
  }

  Widget buildNoteItem(
    Map<String, dynamic> note,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.note_outlined, color: colorScheme.primary),
          ),
          title: Text(
            note['title'] ?? 'Untitled Note',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            _getNotePreview(note['note']),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          onTap: () => _handleNoteView(note),
        ),
      ),
    );
  }

  String _getNotePreview(dynamic note) {
    final content = (note as String?) ?? 'note';
    if (content.isEmpty) return '';
    const previewLength = 50;
    return content.length > previewLength
        ? '${content.substring(0, previewLength)}...'
        : content;
  }


  Widget buildFloatingActionButton(ColorScheme colorScheme) {
    return FloatingActionButton(
      onPressed: () async {
        final shouldRefresh = await Navigator.pushNamed(context, '/operations');
        if (shouldRefresh == true && mounted) {
          await _loadData();
        }
      },
      child: Icon(Icons.add, color: colorScheme.onPrimary),
      backgroundColor: colorScheme.primary,
    );
  }

  BottomNavigationBar buildBottomNavigationBar(ColorScheme colorScheme) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Passwords'),
        BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
      ],
    );
  }

  Future<void> _handlePasswordView(Map<String, dynamic> password) async {
    try {
      if (!await _biometrics.canAuthenticate() ||
          !await _biometrics.authenticate()) {
        throw Exception('Authentication failed');
      }

      final decrypted = await _storage.decryptPassword(password['password'] as String);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PassView(
            docId: password['id'] as String,
            encryptionType: 'AES-256 bit',
            username: password['username'] as String,
            password: decrypted,
            socialMedia: password['type'] as String,
            onUpdate: _loadPasswords,
          ),
        ),
      );

      if (mounted) await _loadPasswords();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleNoteView(Map<String, dynamic> note) async {
    try {
      if (!await _biometrics.canAuthenticate() ||
          !await _biometrics.authenticate()) {
        throw Exception('Authentication failed');
      }

      final keys = await _storage.getEncryptionKeys();
      if (keys['key'] == null || keys['iv'] == null) {
        throw Exception('Encryption keys not found');
      }

      final noteData = Map<String, dynamic>.from(note);

      if (!mounted) return;

      final shouldRefresh = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NoteViewPage(
            noteId: note['id'] as String,
            existingNote: noteData,
          ),
        ),
      );

      if (shouldRefresh == true && mounted) {
        await _loadNotes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      debugPrint('Note view error: $e');
    }
  }

  Future<void> _handleCopyPassword(Map<String, dynamic> password) async {
    try {
      if (!await _biometrics.canAuthenticate() ||
          !await _biometrics.authenticate()) {
        throw 'Authentication failed or cancelled';
      }

      final decrypted = await _storage.decryptPassword(password['password'] as String);

      await Clipboard.setData(ClipboardData(text: decrypted));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Password copied to clipboard'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Password copy error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class UpdateBanner extends StatelessWidget {
  final String releaseName;
  final String changelog;
  final String releaseUrl;
  final VoidCallback onDismiss;
  final VoidCallback onViewRelease;
  final Color bannerColor;

  const UpdateBanner({
    super.key,
    required this.releaseName,
    required this.changelog,
    required this.releaseUrl,
    required this.onDismiss,
    required this.onViewRelease,
    required this.bannerColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: bannerColor,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Update: $releaseName',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  changelog,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.onPrimaryContainer),
            onPressed: onDismiss,
          ),
          IconButton(
            icon: Icon(
              Icons.open_in_new,
              color: colorScheme.onPrimaryContainer,
            ),
            onPressed: onViewRelease,
          ),
        ],
      ),
    );
  }
}
