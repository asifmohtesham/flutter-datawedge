package com.zebra.flutter_barcode

import android.content.*
import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SCAN_INTENT = "com.zebra.flutterbarcode.SCAN"
    private val SCAN_CHANNEL = "com.zebra.flutterbarcode/scan"
    private val SCAN_STREAM = "com.zebra.flutterbarcode/scan_stream"

    private var eventSink: EventChannel.EventSink? = null

    private val barcodeReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val data = intent?.extras ?: return

            val barcodes = mutableListOf<Map<String, String>>()
            val bundle = intent.extras
            bundle?.let {
                // Multi-barcode mode
                val barcodeBundles = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    it.getParcelableArrayList("com.symbol.datawedge.barcodes", Bundle::class.java)
                } else {
                    it.getParcelableArrayList("com.symbol.datawedge.barcodes")
                }
                if (barcodeBundles != null && barcodeBundles.isNotEmpty()) {
                    for (barcodeBundle in barcodeBundles) {
                        val dataString = barcodeBundle.getString("com.symbol.datawedge.data_string") ?: ""
                        val labelType = barcodeBundle.getString("com.symbol.datawedge.label_type") ?: "UNKNOWN"
                        barcodes.add(mapOf("data_string" to dataString, "label_type" to labelType))
                    }
                } else {
                    // Single barcode fallback
                    val dataString = it.getString("com.symbol.datawedge.data_string") ?: ""
                    val labelType = it.getString("com.symbol.datawedge.label_type") ?: "UNKNOWN"
                    barcodes.add(mapOf("data_string" to dataString, "label_type" to labelType))
                }
            }

            // Send list to Flutter
            eventSink?.success(barcodes)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Register MethodChannel to trigger software scan
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, SCAN_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startScan") {
                triggerScanner()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // Register EventChannel to receive scanned data
        EventChannel(flutterEngine!!.dartExecutor.binaryMessenger, SCAN_STREAM).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                eventSink = sink
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        // Register broadcast receiver for scan intent
        val filter = IntentFilter(SCAN_INTENT)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(barcodeReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(barcodeReceiver, filter)
        }
    }

    private fun triggerScanner() {
        val dwIntent = Intent()
        dwIntent.action = "com.symbol.datawedge.api.ACTION"
        dwIntent.putExtra("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING")
        sendBroadcast(dwIntent)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(barcodeReceiver)
    }
}
