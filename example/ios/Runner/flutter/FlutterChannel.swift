import Foundation
import Flutter

class FlutterCall {
    static let getFlavor = "getFlavor"
    static let getAppName = "getAppName"
}

class FlutterChannel {
    
    public var infos: [String : Any] {
        return Bundle.main.infoDictionary!
    }
    
    ///多國語言名稱, 若沒有設置, 則使用 bundleName
    public var name: String {
        return infos["CFBundleDisplayName"] as? String ?? bundleName
    }
    
    ///bundle名稱
    public var bundleName: String {
        return infos["CFBundleName"] as? String ?? ""
    }
    
    private init() {}
    
    static func register(with controller: FlutterViewController) {
        let channel = FlutterMethodChannel(name: "project_channel", binaryMessenger: controller.binaryMessenger)
        let ins = FlutterChannel()
        channel.setMethodCallHandler(ins.onMethodCall)
    }
    
    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {
        case FlutterCall.getFlavor:
            /// ios 沒有渠道, 直接回傳空字串
            result("")
        case FlutterCall.getAppName:
            result(name)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
}
