import Flutter
import UIKit
import ExternalAccessory

public class ZebraPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "zebra_plugin", binaryMessenger: registrar.messenger())
    let instance = ZebraPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

 public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
         if call.method == "get_all_paired_zq_devices" {
        var finalPrinters : Array<Any> = []
                let manager : EAAccessoryManager = EAAccessoryManager.shared()
                manager.connectedAccessories.forEach { element in
                    var dic = [:]
                    dic["deviceMacId"] = (element as EAAccessory).serialNumber
                    dic["deviceName"] = (element as EAAccessory).name
                    finalPrinters.append(dic)
                }
             result(finalPrinters)
         } else if call.method == "connected_device" {
             result(["Hello There"])
         } else if call.method == "connect_channel" {
             result(["Hello There"])
         }  else {
             result(FlutterMethodNotImplemented)
         }
     }
}
