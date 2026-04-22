import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

/// Service for sharing the app via APK or QR code
class AppShareService {
  static const String appName = 'EduVerse';
  static const String packageName = 'com.example.edu_verse';
  static const String downloadUrl = 'https://eduverse.app/download';
  static const String fallbackMessage =
      'Check out EduVerse - the AI-powered learning platform! Download it now: $downloadUrl';

  /// Share the app's APK file (Android only)
  static Future<ShareResult> shareAppApk() async {
    if (!Platform.isAndroid) {
      return _shareTextFallback();
    }

    try {
      final apkPath = await _getApkPath();

      if (apkPath == null || !await File(apkPath).exists()) {
        return _shareTextFallback();
      }

      final cacheDir = await getTemporaryDirectory();
      final shareApkPath = '${cacheDir.path}/$appName.apk';
      final shareApkFile = File(shareApkPath);

      await File(apkPath).copy(shareApkPath);

      final result = await Share.shareXFiles(
        [XFile(shareApkFile.path)],
        text: 'Check out $appName app!',
        subject: appName,
      );

      // Clean up after 5 minutes
      Future.delayed(const Duration(minutes: 5), () {
        if (shareApkFile.existsSync()) {
          try {
            shareApkFile.deleteSync();
          } catch (_) {}
        }
      });

      return result;
    } catch (e) {
      debugPrint('Error sharing APK: $e');
      return _shareTextFallback();
    }
  }

  /// Share the download link as text
  static Future<ShareResult> shareDownloadLink() async {
    return Share.share(fallbackMessage);
  }

  /// Share a QR code image
  static Future<ShareResult> shareQrCode(GlobalKey qrKey) async {
    try {
      final imageBytes = await _captureWidget(qrKey);
      if (imageBytes == null) {
        return _shareTextFallback();
      }

      final cacheDir = await getTemporaryDirectory();
      final qrImagePath = '${cacheDir.path}/eduverse_qr_code.png';
      final qrImageFile = File(qrImagePath);

      await qrImageFile.writeAsBytes(imageBytes);

      final result = await Share.shareXFiles(
        [XFile(qrImageFile.path)],
        text: 'Scan this QR code to download $appName!',
        subject: 'Download $appName',
      );

      // Clean up after 5 minutes
      Future.delayed(const Duration(minutes: 5), () {
        if (qrImageFile.existsSync()) {
          try {
            qrImageFile.deleteSync();
          } catch (_) {}
        }
      });

      return result;
    } catch (e) {
      debugPrint('Error sharing QR code: $e');
      return _shareTextFallback();
    }
  }

  /// Save QR code to gallery
  static Future<String?> saveQrCode(GlobalKey qrKey) async {
    try {
      final imageBytes = await _captureWidget(qrKey);
      if (imageBytes == null) return null;

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/eduverse_qr_$timestamp.png';
      final file = File(filePath);

      await file.writeAsBytes(imageBytes);
      return filePath;
    } catch (e) {
      debugPrint('Error saving QR code: $e');
      return null;
    }
  }

  /// Check if APK sharing is available
  static bool get isApkSharingAvailable => Platform.isAndroid;

  /// Get estimated APK size
  static Future<String> getApkSize() async {
    if (!Platform.isAndroid) return 'N/A';

    try {
      final apkPath = await _getApkPath();
      if (apkPath == null) return '~50 MB';

      final file = File(apkPath);
      if (await file.exists()) {
        final bytes = await file.length();
        final mb = bytes / (1024 * 1024);
        return '${mb.toStringAsFixed(1)} MB';
      }
    } catch (_) {}
    return '~50 MB';
  }

  static Future<ShareResult> _shareTextFallback() async {
    return Share.share(fallbackMessage);
  }

  static Future<String?> _getApkPath() async {
    try {
      final possiblePaths = [
        '/data/app/$packageName/base.apk',
        '/data/app/$packageName-1/base.apk',
        '/data/app/$packageName-2/base.apk',
      ];

      final dataAppDir = Directory('/data/app');
      if (await dataAppDir.exists()) {
        try {
          await for (final entity in dataAppDir.list()) {
            if (entity is Directory) {
              final subDir = Directory(entity.path);
              await for (final subEntity in subDir.list()) {
                if (subEntity is Directory &&
                    subEntity.path.contains(packageName)) {
                  final apkFile = File('${subEntity.path}/base.apk');
                  if (await apkFile.exists()) {
                    return apkFile.path;
                  }
                }
              }
            }
          }
        } catch (_) {}
      }

      for (final path in possiblePaths) {
        final file = File(path);
        if (await file.exists()) {
          return path;
        }
      }

      final result = await Process.run('pm', ['path', packageName]);
      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        if (output.startsWith('package:')) {
          return output.substring(8);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error getting APK path: $e');
      return null;
    }
  }

  static Future<Uint8List?> _captureWidget(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }
}
