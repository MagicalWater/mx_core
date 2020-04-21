

import android.content.Context
import android.content.pm.ApplicationInfo
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/// flutter 調用本地的方法名稱
class FlutterCall {
    companion object {
        /// 取得渠道名
        const val getFlavor = "getFlavor"

        /// 取得應用名
        const val getAppName = "getAppName"
    }
}

class FlutterChannel private constructor() : MethodCallHandler {

    var context: Context? = null

    companion object {

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "project_channel")
            val ins = FlutterChannel()
            ins.context = registrar.context().applicationContext
            channel.setMethodCallHandler(ins)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            FlutterCall.getFlavor -> {
                result.success(BuildConfig.PLATFORM_CODE)
            }
            FlutterCall.getAppName -> {
                result.success(getAppName())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getAppName(): String {
        val appInfo: ApplicationInfo = context!!.applicationInfo
        val stringsId = appInfo.labelRes
        return if (stringsId == 0) appInfo.nonLocalizedLabel.toString()
        else context!!.getString(stringsId)
    }
}