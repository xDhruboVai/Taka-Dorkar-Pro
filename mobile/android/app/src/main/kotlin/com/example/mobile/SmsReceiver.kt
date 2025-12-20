package com.example.mobile

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

class SmsReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "SmsReceiver"
        private const val CHANNEL = "com.example.mobile/sms"
        var methodChannel: MethodChannel? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            
            for (smsMessage in messages) {
                val sender = smsMessage.displayOriginatingAddress
                val messageBody = smsMessage.messageBody
                
                Log.d(TAG, "✅ SMS intercepted by Native Receiver")
                Log.d(TAG, "From: $sender")
                Log.d(TAG, "Message Length: ${messageBody?.length ?: 0}")
                
                if (methodChannel == null) {
                    Log.e(TAG, "❌ MethodChannel is NULL! Flutter might not be ready or channel was never set.")
                } else {
                    Log.d(TAG, "📡 Sending to Flutter via MethodChannel...")
                    // Send to Flutter
                    methodChannel?.invokeMethod("onSmsReceived", mapOf(
                        "sender" to sender,
                        "message" to messageBody,
                        "timestamp" to System.currentTimeMillis()
                    ))
                }
            }
        }
    }
}
