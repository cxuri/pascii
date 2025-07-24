import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class Biometrics {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if the device supports biometrics
  Future<bool> canAuthenticate() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  // Check what types of biometrics are available
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting biometrics: $e');
      return [];
    }
  }

  // Authenticate using biometrics
  Future<bool> authenticate() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate To Access Password.',
        options: AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } on PlatformException catch (e) {
      print('Error authenticating: $e');
      return false;
    }
  }
}
