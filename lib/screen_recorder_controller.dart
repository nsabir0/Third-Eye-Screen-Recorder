import 'package:get/get.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

class ScreenRecorderController extends GetxController {
  final isRecording = false.obs;
  final status = "Idle".obs;

  static const platform = MethodChannel('com.thirdeye/foreground_service');

  late String _fileName;

  String _generateFileName() {
    final now = DateTime.now();
    final formatted = DateFormat('yyyyMMdd_HHmmss').format(now);
    return "third_eye_$formatted";
  }

  Future<void> startRecording() async {
    status.value = "Requesting permissions...";

    final permissions = await [
      Permission.microphone,
      Permission.storage,
    ].request();

    if (permissions.values.every((p) => p.isGranted)) {
      try {
        _fileName = _generateFileName(); // Unique file name
        status.value = "Starting recording service...";
        await platform.invokeMethod('startForegroundService');

        status.value =
            "Please allow screen recording permission when prompted...";

        final started = await FlutterScreenRecording.startRecordScreen(
          _fileName,
        );

        if (started) {
          isRecording.value = true;
          status.value =
              "Recording started!\nYou can minimize the app to continue recording.";
        } else {
          status.value = "Recording failed to start.";
          await platform.invokeMethod('stopForegroundService');
        }
      } catch (e) {
        status.value = "Error: $e";
        try {
          await platform.invokeMethod('stopForegroundService');
        } catch (_) {}
      }
    } else {
      status.value = "Required permissions not granted.";
    }
  }

  Future<void> stopRecording() async {
    try {
      final savedPath = await FlutterScreenRecording.stopRecordScreen;
      isRecording.value = false;

      final targetDir = Directory("/storage/emulated/0/Download/Recordings");

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final originalFile = File(savedPath);
      final newPath = p.join(targetDir.path, "$_fileName.mp4");

      await originalFile.copy(newPath);
      await originalFile.delete(); // Optional

      status.value = "Recording saved to:\n$newPath";

      await platform.invokeMethod('stopForegroundService');
    } catch (e) {
      status.value = "Error stopping recording: $e";
    }
  }

  @override
  void onClose() {
    if (isRecording.value) {
      stopRecording();
    }
    super.onClose();
  }
}
