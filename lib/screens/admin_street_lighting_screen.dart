import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class StreetLightingScreen extends StatefulWidget {
  @override
  _StreetLightingScreenState createState() => _StreetLightingScreenState();
}

class _StreetLightingScreenState extends State<StreetLightingScreen> {
  bool isAutoMode = false;
  bool manualLightsOn = false;
  bool autoEnabled = false;
  BluetoothDevice? device;
  BluetoothCharacteristic? characteristic;
  BluetoothState? bluetoothState;
  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  void initState() {
    super.initState();
    // Start scanning for Bluetooth devices on app launch
    flutterBlue.state.listen((state) {
      setState(() {
        bluetoothState = state;
      });
    });
  }

  // Method to connect to a Bluetooth device and set up communication
  Future<void> connectToBluetooth() async {
    // Start scanning for available Bluetooth devices
    flutterBlue.startScan(timeout: Duration(seconds: 5));

    // Listen to scan results
    flutterBlue.scanResults.listen((scanResults) async {
      BluetoothDevice? foundDevice;

      // Iterate over the results to find the device you want (HC-05 or HC-06)
      for (ScanResult result in scanResults) {
        if (result.device.name == 'HC-05' || result.device.name == 'HC-06') {
          foundDevice = result.device;
          break;
        }
      }

      if (foundDevice != null) {
        setState(() {
          device = foundDevice;
        });

        try {
          await device!.connect();
          print('Device connected: ${device!.name}');

          // Discover services of the connected device
          List<BluetoothService> services = await device!.discoverServices();
          services.forEach((service) async {
            for (BluetoothCharacteristic c in service.characteristics) {
              if (c.properties.write) {
                setState(() {
                  characteristic = c;
                });
                print("Found writable characteristic: ${c.uuid}");
              }
            }
          });
        } catch (e) {
          print('Error while connecting to the device: $e');
        }
      } else {
        print('No device found');
      }
    });

    // Stop scanning after the timeout
    await Future.delayed(Duration(seconds: 5));
    flutterBlue.stopScan();
  }

  // Method to send a command to the Bluetooth module (Arduino)
  Future<void> sendBluetoothCommand(String command) async {
    if (characteristic != null) {
      await characteristic!.write([command.codeUnitAt(0)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Street Lighting"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  "Auto Mode",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Switch(
                  value: isAutoMode,
                  onChanged: (val) {
                    setState(() {
                      isAutoMode = val;
                      autoEnabled = val;
                    });
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isAutoMode
                    ? 'Auto mode is enabled. LDR sensor is controlling lights.'
                    : 'Auto mode is disabled.',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            if (!isAutoMode) ...[
              Row(
                children: [
                  const Text(
                    "Manual Lights",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Switch(
                    value: manualLightsOn,
                    onChanged: (val) async {
                      setState(() {
                        manualLightsOn = val;
                      });
                      // Send the appropriate command to the Bluetooth module
                      if (manualLightsOn) {
                        await sendBluetoothCommand('1');  // Turn ON LED
                      } else {
                        await sendBluetoothCommand('0');  // Turn OFF LED
                      }
                    },
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  manualLightsOn
                      ? 'Lights are currently ON.'
                      : 'Lights are currently OFF.',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
            // Connect to Bluetooth
            ElevatedButton(
              onPressed: () async {
                await connectToBluetooth();
                if (bluetoothState == BluetoothState.on) {
                  // You can now control the LED using Bluetooth
                  print('Bluetooth device connected');
                }
              },
              child: Text('Connect to Bluetooth'),
            ),
          ],
        ),
      ),
    );
  }
}
