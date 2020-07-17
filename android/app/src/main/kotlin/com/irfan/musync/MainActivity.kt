package com.irfan.musync

import android.content.Context
import android.net.ConnectivityManager
import android.net.wifi.WifiManager
import android.widget.Toast
import androidx.annotation.NonNull

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "io.irfan.musync"
    private val multicastChannelName = "io.irfan.musync.service"
    private lateinit var wifiMulticastLock: WifiManager.MulticastLock

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "showToast") {
                Toast.makeText(this, call.argument<String>("message"), if (call.argument<String>("duration") == "long") Toast.LENGTH_LONG else Toast.LENGTH_SHORT).show()
            }
            else if (call.method == "isConnected"){
                result.success(isConnected())
            }
            else if (call.method == "acquireMulticastLock"){
                val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                wifiMulticastLock = wifi.createMulticastLock(multicastChannelName)
                wifiMulticastLock.acquire()
            }
            else if (call.method == "checkMulticast"){
                if (this::wifiMulticastLock.isInitialized) result.success(wifiMulticastLock.isHeld)
                else result.success(false)
            }
            else if (call.method == "releaseMulticastLock"){
                if (wifiMulticastLock.isHeld) wifiMulticastLock.release()
            }
            else {
                result.notImplemented()
            }
        }
    }

    private fun isConnected():Boolean {
        return (getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager).activeNetworkInfo?.isConnected ?: false
    }
}
