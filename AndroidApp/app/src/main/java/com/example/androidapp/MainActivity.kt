package com.example.androidapp

import android.content.Intent
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.Button
import com.google.firebase.FirebaseApp
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

private const val FLUTTER_ENGINE_ID = "module_flutter_engine"
private const val NOTIFICATION_CHANNEL = "com.example.flutter_module"

class MainActivity : AppCompatActivity() {
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var methodChannel: MethodChannel

    companion object {
        private const val TAG = "MainActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Initialize Firebase
        FirebaseApp.initializeApp(this)

        // Instantiate a FlutterEngine
        flutterEngine = FlutterEngine(this)

        // Start executing Dart code to pre-warm the FlutterEngine
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        // Cache the FlutterEngine to be used by FlutterActivity
        FlutterEngineCache
            .getInstance()
            .put(FLUTTER_ENGINE_ID, flutterEngine)

        // Setup method channel for notification handling
        setupNotificationMethodChannel()

        val myButton = findViewById<Button>(R.id.myButton)
        myButton.setOnClickListener {
            startFlutterActivity()
        }

        // Check if the app was launched from a notification
        handleNotificationLaunch(intent)
    }

    private fun setupNotificationMethodChannel() {
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NOTIFICATION_CHANNEL
        )

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "launchApp" -> {
                    val action = call.argument<String>("action")
                    val callId = call.argument<String>("callId")

                    Log.d(TAG, "Launching app with action: $action, callId: $callId")

                    // Create an intent to launch Flutter activity with specific parameters
                    val flutterIntent = FlutterActivity
                        .withCachedEngine(FLUTTER_ENGINE_ID)
                        .build(this)
                        .apply {
                            putExtra("LAUNCH_ACTION", action)
                            putExtra("CALL_ID", callId)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        }

                    startActivity(flutterIntent)
                    result.success(true)
                }
                else -> {
                    Log.w(TAG, "Unhandled method: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }

    private fun startFlutterActivity() {
        startActivity(
            FlutterActivity
                .withCachedEngine(FLUTTER_ENGINE_ID)
                .build(this)
        )
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        Log.d(TAG, "onNewIntent called")
        handleNotificationLaunch(intent)
    }

    private fun handleNotificationLaunch(intent: Intent?) {
        intent?.let {
            val action = it.getStringExtra("LAUNCH_ACTION")
            val callId = it.getStringExtra("CALL_ID")

            Log.d(TAG, "Handling notification launch - Action: $action, CallId: $callId")

            if (action == "OPEN_FLUTTER_CALL_SCREEN") {
                // Launch Flutter activity with specific screen parameters
                val flutterIntent = FlutterActivity
                    .withCachedEngine(FLUTTER_ENGINE_ID)
                    .build(this)
                    .apply {
                        putExtra("LAUNCH_ACTION", action)
                        putExtra("CALL_ID", callId)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    }

                startActivity(flutterIntent)
            }
        }
    }
}