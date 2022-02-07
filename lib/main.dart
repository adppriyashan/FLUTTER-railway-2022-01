import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:railway/Controllers/ticketcheck.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isScanning = false;
  int showError = 1;

  String stationId = '225';

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      result = scanData;
      checkProcess();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Visibility(
              visible: (showError == 1) ? true : false,
              child: SizedBox(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      height: MediaQuery.of(context).size.width * 0.8,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green,
                            width: 5.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: const Icon(
                        Icons.qr_code_2_outlined,
                        color: Colors.green,
                        size: 150.0,
                      ),
                    ),
                    Text(
                      'validate ticket with qr code'.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                  ],
                ),
              )),
          Visibility(
              visible: (showError == 2) ? true : false,
              child: SizedBox(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      height: MediaQuery.of(context).size.width * 0.8,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green,
                            width: 5.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 150.0,
                      ),
                    ),
                    Text(
                      'Passenger Approved'.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                  ],
                ),
              )),
          Visibility(
              visible: (showError == 3) ? true : false,
              child: SizedBox(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      height: MediaQuery.of(context).size.width * 0.8,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green,
                            width: 5.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: const Icon(
                        Icons.wrong_location,
                        color: Colors.red,
                        size: 150.0,
                      ),
                    ),
                    Text(
                      'Invalid Passenger'.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  void checkProcess() async {
    if (result != null && result!.code != null) {
      isScanning = false;
      controller!.pauseCamera();
      await TicketCheckController()
          .checkTicket(result!.code, stationId)
          .then((resp) {
        if (resp.statusCode == 200) {
          setState(() {
            showError = (resp.body == "1" || resp.body == '2') ? 2 : 3;
          });
        } else {
          setState(() {
            showError = 3;
          });
        }
      });
      controller!.resumeCamera();
    } else {
      isScanning = true;
    }
  }
}
