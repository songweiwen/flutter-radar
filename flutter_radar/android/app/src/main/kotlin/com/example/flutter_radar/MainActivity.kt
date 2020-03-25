package com.example.flutter_radar

import android.os.Bundle

import io.flutter.plugin.common.MethodChannel
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

  //通讯名称,回到手机桌面
    private var channel = "android/back/desktop"
  //返回手机桌面事件
    companion object {
      var eventBackDesktop =  "backDesktop"
    }


  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)


    initBackTop();

  }

    private fun initBackTop() {
        MethodChannel(flutterView, channel).setMethodCallHandler { methodCall, result ->
            kotlin.run {
                if (methodCall.method.equals(eventBackDesktop)) {
                    moveTaskToBack(false)
                    result.success(true)
                }
            }
        }
    }

}
