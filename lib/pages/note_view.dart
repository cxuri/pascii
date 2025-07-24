import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pascii/services/local_storage.dart';
import 'package:pascii/services/encryption_service.dart';

class NoteViewPage extends StatefulWidget {
  final String? noteId; // Null for new notes
  final Map<String, dynamic>? existingNote; // Null for new notes

  const NoteViewPage({Key? key, this.noteId, this.existingNote})
    : super(key: key);

  static Future<bool?> push(
    BuildContext context, {
    String? noteId,
    Map<String, dynamic>? existingNote,
  }) async {
    return await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            NoteViewPage(noteId: noteId, existingNote: existingNote),
      ),
    );
  }

  @override
  _NoteViewPageState createState() => _NoteViewPageState();
}

class _NoteViewPageState extends State<NoteViewPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  final _storage = LocalStorage();
  late EncryptionService _encryptionService;

  bool _isSaving = false;
  bool _isDeleting = false;
  bool _hasChanges = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices(); // Initialize after first frame
    });
  }

  Future<void> _initializeServices() async {
    try {
      final keys = await _storage.getEncryptionKeys();
      _encryptionService = EncryptionService(keys['key']!, keys['iv']!);

      if (widget.existingNote != null) {
        _titleController.text = widget.existingNote!['title'] ?? '';
        _bodyController.text = widget.existingNote!['content'] != null
            ? _encryptionService.decryptData(widget.existingNote!['content']) // Changed from 'note' to 'content'
            : '';
      }

      _titleController.addListener(_checkForChanges);
      _bodyController.addListener(_checkForChanges);

      setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing: $e')));
        Navigator.of(context).pop();
      }
    }
  }

  void _checkForChanges() {
    final currentTitle = _titleController.text;
    final currentBody = _bodyController.text;

    final originalTitle = widget.existingNote?['title'] ?? ''; // Changed from 'name' to 'title'
    final originalBody = widget.existingNote?['content'] != null
        ? _encryptionService.decryptData(widget.existingNote!['content']) // Changed from 'note' to 'content'
        : '';

    setState(() {
      _hasChanges =
          currentTitle != originalTitle || currentBody != originalBody;
    });
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasChanges) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
              'You have unsaved changes. Do you want to discard them?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _saveNote() async {
    if (_isSaving || !_hasChanges) return;

    setState(() => _isSaving = true);

    try {
      final title = _titleController.text.trim();
      final body = _bodyController.text.trim();

      if (title.isEmpty) {
        throw 'Title cannot be empty';
      }

      await _storage.saveNote(id: widget.noteId, title: title, content: body);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note saved successfully')));

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving note: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteNote() async {
    if (_isDeleting || widget.noteId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await _storage.deleteNote(widget.noteId!);
      if (mounted) Navigator.of(context).pop(true); // Refresh parent
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting note: $e')));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSaving || _isDeleting) return false;
        return await _confirmDiscardChanges();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.noteId == null ? 'New Note' : 'Edit Note'),
          actions: [
            if (widget.noteId != null)
              IconButton(
                icon: _isDeleting
                    ? const CircularProgressIndicator(color: Colors.red)
                    : const Icon(Icons.delete, color: Colors.red),
                onPressed: _isDeleting ? null : _deleteNote,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton.icon(
                onPressed: _isSaving || !_hasChanges ? null : _saveNote,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isSaving ? "Saving..." : "Save",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        body: _isInitialized
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.roboto(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      style: GoogleFonts.roboto(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TextField(
                        controller: _bodyController,
                        decoration: InputDecoration(
                          hintText: 'Start writing...',
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        maxLines: null,
                        expands: true,
                        style: GoogleFonts.roboto(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
