import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zebra_plugin/zebra_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _zebraPlugin = ZebraPlugin();

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
      if (await _zebraPlugin.hasAllBluetoothPermission()) {
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
      }
      setState(() {
        _working = false;
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                                        final connect = await _zebraPlugin
                                            .connectPrinter(e['deviceMacId']);
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
                                        e['deviceMacId'] +
                                            " " +
                                            e['deviceName'],
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
