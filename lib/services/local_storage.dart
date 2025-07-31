import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pascii/services/encryption_service.dart';
import 'package:uuid/uuid.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;

  late final Box _passwordsBox;
  late final Box _notesBox;
  late final Box _configBox;
  final Uuid _uuid = const Uuid();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final EncryptionService _aes;

  static const String _encryptionKeyName = 'encryption_key';
  static const String _encryptionIvName = 'encryption_iv';
  bool _isInitialized = false;

  LocalStorage._internal();

  EncryptionService get encryptionService => _aes;

  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize Hive boxes
    _passwordsBox = await Hive.openBox('passwords');
    _notesBox = await Hive.openBox('notes');
    _configBox = await Hive.openBox('config');

    // Initialize encryption
    await _initializeEncryption();
    _isInitialized = true;
  }

  Future<void> _initializeEncryption() async {
    final key = await _secureStorage.read(key: _encryptionKeyName);
    final iv = await _secureStorage.read(key: _encryptionIvName);

    if (key == null || iv == null) {
      final newKeys = EncryptionService.generateRandomKeyAndIV();
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: newKeys['key'],
      );
      await _secureStorage.write(
        key: _encryptionIvName,
        value: newKeys['iv']
      );
      _aes = EncryptionService(newKeys['key']!, newKeys['iv']!);
    } else {
      _aes = EncryptionService(key, iv);
    }
  }

  Future<Map<String, String?>> getEncryptionKeys() async {
    final key = await _secureStorage.read(key: _encryptionKeyName);
    final iv = await _secureStorage.read(key: _encryptionIvName);
    return {'key': key, 'iv': iv};
  }

  // Password CRUD Operations
  Future<String> savePassword({
    String? id,
    required String username,
    required String password,
    required String type,
    required String category,
  }) async {
    try {
      final itemId = id ?? _uuid.v4();
      final encryptedPassword = _aes.encryptData(password);

      await _passwordsBox.put(itemId, {
        'id': itemId,
        'username': username,
        'password': encryptedPassword,
        'type': type,
        'category': category,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return itemId;
    } catch (e) {
      throw Exception('Failed to save password: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPasswords() async {
    try {
      return _passwordsBox.values.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (e) {
      throw Exception('Failed to get passwords: $e');
    }
  }

  Future<String> decryptPassword(String encryptedPassword) async {
    return _aes.decryptData(encryptedPassword);
  }
  
  Future<void> updatePassword(String id, Map<String, dynamic> updates) async {
    try {
      // Validate input
      if (id.isEmpty) {
        throw ArgumentError('Password ID cannot be empty');
      }

      // Get existing password data
      final existing = _passwordsBox.get(id);
      if (existing == null) {
        throw Exception('Password with ID $id not found');
      }

      // Create a copy of updates to modify
      final updatesCopy = Map<String, dynamic>.from(updates);

      // Handle password encryption if password is being updated
      if (updatesCopy.containsKey('password') && updatesCopy['password'] != null) {
        final encryptedPassword = _aes.encryptData(updatesCopy['password']);
        updatesCopy['password'] = encryptedPassword;
      }

      // Prepare the updated data
      final updatedData = Map<String, dynamic>.from(existing);
      updatedData.addAll(updatesCopy);
      updatedData['updatedAt'] = DateTime.now().toIso8601String();

      // Save the updated data
      await _passwordsBox.put(id, updatedData);

    } on ArgumentError catch (e) {
      throw Exception('Validation error: ${e.message}');
    } on HiveError catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getPassword(String id) async {
    try {
      final passwordData = _passwordsBox.get(id);
      if (passwordData == null) throw Exception('Password not found');
      return Map<String, dynamic>.from(passwordData as Map);
    } catch (e) {
      throw Exception('Failed to retrieve password: $e');
    }
  }

  Future<void> deletePassword(String id) async {
    try {
      await _passwordsBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete password: $e');
    }
  }

  // Note CRUD Operations
  Future<String> saveNote({
    String? id,
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    try {
      final itemId = id ?? _uuid.v4();
      final encryptedContent = _aes.encryptData(content);

      await _notesBox.put(itemId, {
        'id': itemId,
        'title': title,
        'content': encryptedContent,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return itemId;
    } catch (e) {
      throw Exception('Failed to save note: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    try {
      return _notesBox.values.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (e) {
      throw Exception('Failed to get notes: $e');
    }
  }

  Future<void> updateNote(String id, Map<String, dynamic> updates) async {
    try {
      final existing = _notesBox.get(id);
      if (existing != null) {
        if (updates.containsKey('content')) {
          updates['content'] = _aes.encryptData(updates['content']);
        }
        await _notesBox.put(id, {
          ...Map<String, dynamic>.from(existing),
          ...updates,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _notesBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      await _passwordsBox.clear();
      await _notesBox.clear();
      await _configBox.clear();
      await _secureStorage.delete(key: _encryptionKeyName);
      await _secureStorage.delete(key: _encryptionIvName);
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }
}
