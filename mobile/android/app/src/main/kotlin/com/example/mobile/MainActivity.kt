package com.example.mobile

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.mobile/sms"
    private val SMS_PERMISSION_CODE = 101

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        SmsReceiver.methodChannel = channel
        
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermissions" -> {
                    val hasPermission = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.RECEIVE_SMS
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(hasPermission)
                }
                "requestPermissions" -> {
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(
                            Manifest.permission.RECEIVE_SMS,
                            Manifest.permission.READ_SMS
                        ),
                        SMS_PERMISSION_CODE
                    )
                    result.success(null)
                }
                "getInboxMessages" -> {
                    val limit = call.argument<Int>("limit") ?: 20
                    val messages = mutableListOf<Map<String, Any>>()
                    
                    val cursor = contentResolver.query(
                        android.net.Uri.parse("content://sms/inbox"),
                        arrayOf("address", "body", "date"),
                        null,
                        null,
                        "date DESC LIMIT $limit"
                    )
                    
                    cursor?.use {
                        val addressIndex = it.getColumnIndex("address")
                        val bodyIndex = it.getColumnIndex("body")
                        val dateIndex = it.getColumnIndex("date")
                        
                        while (it.moveToNext()) {
                            messages.add(mapOf(
                                "sender" to (it.getString(addressIndex) ?: "Unknown"),
                                "message" to (it.getString(bodyIndex) ?: ""),
                                "timestamp" to it.getLong(dateIndex)
                            ))
                        }
                    }
                    result.success(messages)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SMS_PERMISSION_CODE) {
            val granted = grantResults.isNotEmpty() && 
                         grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            
            flutterEngine?.dartExecutor?.binaryMessenger?.let {
                MethodChannel(it, CHANNEL).invokeMethod("onPermissionResult", granted)
            }
        }
    }
}
