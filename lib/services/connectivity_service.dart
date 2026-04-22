import 'dart:io';
import 'dart:async';

class ConnectivityService {
  // Check if device is connected to internet using multiple strategies
  Future<bool> hasInternetConnection() async {
    try {
      // Try DNS lookup with timeout
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on TimeoutException {
      // If google.com times out, try cloudflare DNS
      try {
        final result = await InternetAddress.lookup(
          '1.1.1.1',
        ).timeout(const Duration(seconds: 5));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException {
        return false;
      }
    } on SocketException {
      return false;
    }
  }

  // Check internet and return a user-friendly error message
  Future<(bool, String?)> checkConnectivityWithMessage() async {
    try {
      final hasConnection = await hasInternetConnection();
      if (!hasConnection) {
        return (false, 'No internet connection. Please check your network.');
      }
      return (true, null);
    } catch (e) {
      return (false, 'Network error. Please try again.');
    }
  }
}
