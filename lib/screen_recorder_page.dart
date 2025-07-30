import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'screen_recorder_controller.dart';

class ScreenRecorderPage extends StatelessWidget {
  final controller = Get.put(ScreenRecorderController());
  static const platform = MethodChannel(
    'com.abir.third_eye/foreground_service',
  );

  ScreenRecorderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (controller.isRecording.value) {
          // Minimize app instead of closing when recording
          await _minimizeApp();
        }
        // Do not return anything, as the function must return Future<void>
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Third Eye - Screen Recorder"),
            backgroundColor: Colors.blue[400],
          ),
          body: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  controller.isRecording.value
                      ? Icons.videocam
                      : Icons.videocam_off,
                  size: 80,
                  color: controller.isRecording.value
                      ? Colors.red
                      : Colors.grey,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      controller.status.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: controller.isRecording.value
                          ? null
                          : controller.startRecording,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Start Recording"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: controller.isRecording.value
                          ? controller.stopRecording
                          : null,
                      icon: const Icon(Icons.stop),
                      label: const Text("Stop Recording"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (controller.isRecording.value)
                  ElevatedButton.icon(
                    onPressed: _minimizeApp,
                    icon: const Icon(Icons.minimize),
                    label: const Text("Minimize App"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(height: 8),
                        Text(
                          "Note: When you start recording, Android will ask for screen recording permission. This is required by the system for security.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "✓ This permission is only asked once per session",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _minimizeApp() async {
    try {
      await platform.invokeMethod('excludeFromRecents');
    } catch (e) {
      log('Error minimizing app: $e');
      // Fallback: use system navigation
      SystemNavigator.pop();
    }
  }
}
