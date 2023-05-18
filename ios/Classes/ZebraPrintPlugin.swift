import Flutter
import UIKit
import ExternalAccessory
import Foundation
import CoreBluetooth

public class ZebraPrintPlugin: NSObject, FlutterPlugin {
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "zebra_print_plugin", binaryMessenger: registrar.messenger())
    let instance = ZebraPrintPlugin()
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
             let arguments = call.arguments as! Dictionary<String, AnyObject>
             var serialNumber = arguments["macID"] as! String
             let data = arguments["printBytes"] as! String
             print(data)
             var connection = printNewEvidenceTransfer(zplString: data, serialNumber: serialNumber)
             if(connection == true) {
                 result("true")
             } else {
                 result("false")
             }
         }  else {
             result(FlutterMethodNotImplemented)
         }
     }
    
   
    
    func printNewEvidenceTransfer(zplString: String,serialNumber : String ) -> Bool {
       // Build ZPL string for evidences and contact information
       var zplAgencyString = ""
       zplAgencyString = zplString
       let connection = MfiBtPrinterConnection(serialNumber: serialNumber)
       let myGroup = DispatchGroup()
       myGroup.enter()
       DispatchQueue.global(qos: .background).async {
           if serialNumber != "" {
               do {
                   connection?.close()
                   if connection?.open() == true {
                       print("$$$$$$$$$$$$$$$$$$$$$$$$printNewEvidenceTransfer$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
                       print(zplString)
                       let printer = ZebraPrinterFactory.getInstance(connection, with: PRINTER_LANGUAGE_ZPL)
                       
                       let blockSize = 1024;
                       let totalSize = zplAgencyString.lengthOfBytes(using: String.Encoding.utf8);
                       var bytesRemaining = totalSize;
                       var fullLabelCopy = zplAgencyString
                       
                       while bytesRemaining > 0 {
                           let bytesToSend = min(blockSize, bytesRemaining)
                           let partialLabel = self.subString(originalString: fullLabelCopy, startIndex: 0, length: bytesToSend)
                           try printer?.getToolsUtil().sendCommand(partialLabel)
                           bytesRemaining -= bytesToSend
                           
                           if (bytesRemaining > 0) {
                               fullLabelCopy = self.subString(originalString: fullLabelCopy, startIndex: bytesToSend, length: bytesRemaining)
                           }
                       }
                   }
                   connection?.close()
                   myGroup.leave()
               } catch {
                   connection?.close()
                   DispatchQueue.main.sync {
                       // Display alert
                       let alert = UIAlertController(title: "Message", message: error.localizedDescription, preferredStyle: .alert)
                       alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
                       
                       if var currentViewController = UIApplication.shared.keyWindow?.rootViewController {
                           while let presentedViewController = currentViewController.presentedViewController {
                               currentViewController = presentedViewController
                           }
                           // Display message with current view controller
                           currentViewController.present(alert, animated: true, completion: nil)
                       }
                   }
               }
           } else {
               DispatchQueue.main.sync {
                   let alert = UIAlertController(title: "Message", message: "Please set up printer first.", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
                   
                   if var currentViewController = UIApplication.shared.keyWindow?.rootViewController {
                       while let presentedViewController = currentViewController.presentedViewController {
                           currentViewController = presentedViewController
                       }
                       currentViewController.present(alert, animated: true, completion: nil)
                   }
               }
           }
       }
       myGroup.notify(queue: DispatchQueue.main) {
           //?.close()
       }
       return true
   }
   
   func subString(originalString: String, startIndex: Int, length: Int) -> String {
       guard originalString.count >= startIndex + length else { return "" }
       let start = originalString.index(originalString.startIndex, offsetBy: startIndex)
       let end = originalString.index(originalString.startIndex, offsetBy: startIndex + length)
       return String(originalString[start..<end])
   }
    
}
