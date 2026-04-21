package com.example.first_flutter_project

import io.flutter.embedding.android.FlutterFragmentActivity  // ✅ Change this import
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {  // ✅ Change to FlutterFragmentActivity
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
    }
}