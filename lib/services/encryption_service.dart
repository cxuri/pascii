import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  final encrypt.Encrypter _encrypter;
  final encrypt.Key _key;
  final encrypt.IV _iv;

  // Constructor that initializes the AES-256 bit encryption service with key and IV
  EncryptionService(String keyBase64, String ivBase64)
    : _key = _validateKey(keyBase64), // Validate key length
      _iv = _validateIV(ivBase64), // Validate IV length
      _encrypter = encrypt.Encrypter(
        encrypt.AES(_validateKey(keyBase64), mode: encrypt.AESMode.cbc),
      );

  // Encrypt data
  String encryptData(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64; // Return the encrypted data as base64 string
  }

  // Decrypt data
  String decryptData(String encryptedText) {
    final decrypted = _encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted; // Return the decrypted string
  }

  // Generate a random key and IV for AES-256 bit encryption
  static Map<String, String> generateRandomKeyAndIV() {
    final key = _generateRandomBytes(
      32,
    ); // AES-256 requires 32 bytes key (256 bits)
    final iv = _generateRandomBytes(16); // AES requires 16 bytes IV (128 bits)
    return {'key': base64.encode(key), 'iv': base64.encode(iv)};
  }

  // Helper function to generate random bytes
  static List<int> _generateRandomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (i) => random.nextInt(256));
  }

  // Helper function to validate the key length
  static encrypt.Key _validateKey(String keyBase64) {
    final key = encrypt.Key.fromBase64(keyBase64);
    if (key.bytes.length != 32) {
      throw ArgumentError("Key must be 32 bytes for AES-256.");
    }
    return key;
  }

  // Helper function to validate the IV length
  static encrypt.IV _validateIV(String ivBase64) {
    final iv = encrypt.IV.fromBase64(ivBase64);
    if (iv.bytes.length != 16) {
      throw ArgumentError("IV must be 16 bytes for AES CBC mode.");
    }
    return iv;
  }
}
