// File: android/app/src/main/java/com/abir/third_eye/MainActivity.java
package com.abir.third_eye;

import android.content.Intent;
import android.os.Build;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.thirdeye/foreground_service";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "startForegroundService":
                            startForegroundService();
                            result.success("Foreground service started");
                            break;
                        case "stopForegroundService":
                            stopForegroundService();
                            result.success("Foreground service stopped");
                            break;
                        case "excludeFromRecents":
                            excludeFromRecents();
                            result.success("Excluded from recents");
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

    private void startForegroundService() {
        Intent serviceIntent = new Intent(this, ForegroundService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent);
        } else {
            startService(serviceIntent);
        }
    }

    private void stopForegroundService() {
        Intent serviceIntent = new Intent(this, ForegroundService.class);
        stopService(serviceIntent);
    }

    private void excludeFromRecents() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            // Move task to back and exclude from recents
            moveTaskToBack(true);
            // Note: Complete exclusion from recents requires system-level permissions
            // This will minimize the app instead
        }
    }
}