import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:zebra_print_plugin/zebra_print_plugin.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _zebraPlugin = ZebraPrintPlugin();

  List<dynamic>? _devices;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      setState(() {
        _working = true;
      });
      final devices = await _zebraPlugin.getAllPairedZQDevices();
      //final connect = await _zebraPlugin.connectPrinter("AC:3F:A4:0E:89:95");
      //final testLabel = await _zebraPlugin.sendTestLabel();
      setState(() {
        if (devices != null) {
          _devices = devices;
        } else {
          _devices = [];
        }
      });
      log("config label -  and  connect - $devices");
      setState(() {
        _working = false;
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: _working
            ? const CircularProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_devices != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 20,
                      ),
                      child: Column(
                        children: _devices
                                ?.map(
                                  (e) => ListTile(
                                    onTap: () async {
                                      String printByte =
                                          "~CC^~CT~^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR5,5~SD30^JUS^LRN^CI27^PA0,1,1,0^XZ^XA^MMT^PW810^LL810^LS0^FO0,0^GB810,810,4^FS^FO0,125^GB810,4,4^FS ^CF0,25^FO0,55^FB810,4,0,C,0^FDIso Number: 1M59S06-HYD-1M59003033-0001 \&^FS ^CF0,25^FO50,180^FB410,4,0,L,0^FDSpool No:SP023 ^FS ^FO355,130^GB4,250,4^FS ^CF0,25^FO425,180^FB410,4,0,L,0^FDRev: 1^FS ^FO0,250^GB821,4,4^FS ^CF0,25^FO50,300^FB410,4,0,L,0^FDMaterial : CS^FS ^CF0,25^FO425,300^FB410,4,0,L,0^FDPaint Sys:A1^FS ^FO0,380^GB821,4,4^FS ^FO305,520^BQ,2,9,^FDQA,FDLabel9^FS ^XZ";
                                      final connect =
                                          await _zebraPlugin.connectPrinter(
                                              e['deviceMacId'], printByte);
                                      if (connect ?? false) {
                                      } else {
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Failed to connect device, please make sure your device is ready connect"),
                                          ),
                                        );
                                      }
                                    },
                                    title: Text(
                                      e['deviceMacId'] + " " + e['deviceName'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            color: Colors.lightBlue,
                                            fontSize: 16,
                                          ),
                                    ),
                                    trailing:
                                        const Icon(Icons.bluetooth_connected),
                                    subtitle: const Text("Connect and print"),
                                  ),
                                )
                                .toList() ??
                            [],
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Future<bool> isBluetoothOn() async {
    Completer completer = Completer<bool>();
    _zebraPlugin.isBluetoothOn().then((isBluetoothOn) async {
      if (!isBluetoothOn) {
        await showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: const Text("Switch on Bluetooth"),
              content:
                  const Text("Switch on the bluetooth to scan RFID Devices"),
              actions: [
                CupertinoButton(
                  child: const Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        completer.complete(false);
      } else {
        completer.complete(true);
      }
    });
    return completer.isCompleted;
  }
}
