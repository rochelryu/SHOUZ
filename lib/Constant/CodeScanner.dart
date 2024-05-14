import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:shouz/Pages/Login.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';


class CodeScanner extends StatefulWidget {
  final int type;
  CodeScanner({required Key key, required this.type }) : super(key: key);

  @override
  _CodeScannerState createState() => _CodeScannerState();
}

class _CodeScannerState extends State<CodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  bool scanned = false;
  bool flashOn = false;
  QRViewController? controller;
  ConsumeAPI consumeAPI = new ConsumeAPI();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();

  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
              top: 0,
              left: 0,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: _buildQrView(context),
          ),
          Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              height: 80,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black54
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              final infoFlash = await controller?.getFlashStatus();
                              setState(() {
                                flashOn = infoFlash!;
                              });
                            },
                            icon: flashOn ? Icon(Icons.flash_off, color: Colors.white, size: 35): Icon(Icons.flash_off, color: Colors.white, size: 35)),
                        SizedBox(width: 60),
                        IconButton(
                            onPressed: () async {
                              await controller?.flipCamera();

                            },
                            icon: Icon(Icons.switch_camera, color: Colors.white, size: 40)),
                      ],
                    ),

                  ],
                ),
              )),
          Positioned(
              top: 36,
              left: 16,
              child: Container(
            margin: EdgeInsets.only(left: 10.0),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                  colors: [Color(0x00000000), tint],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: IconButton(
              icon: Icon(Icons.close,
                  color: Colors.white, size: 22.0),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 - 30,
              left: MediaQuery.of(context).size.width * 0.5 - 30,
              child: result != null ? Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                ),
                child: LoadingIndicator(indicatorType: Indicator.ballRotateChase,colors: [colorText], strokeWidth: 2),
              ): SizedBox(width: 2,))
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: colorText,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      if(!scanned) {
        setState(() {
          scanned = true;
        });
        if(result!.code?.split('-').length == 1 && widget.type == 1) {
          showDialog(
              context: context,
              builder: (BuildContext context) => dialogCustomForValidateAction(
                  "Erreur",
                  "Ce ticket n'est pas un ticket d'évènement",
                  "Ok",
                      () {

                  }, context, false),
              barrierDismissible: false);
        }
        else if(result!.code?.split('_').length != 4 && widget.type != 1) {
          showDialog(
              context: context,
              builder: (BuildContext context) => dialogCustomForValidateAction(
                  "Erreur",
                  "Ce ticket n'est pas un ticket de voyage",
                  "Ok",
                      () {

                  }, context, false),
              barrierDismissible: false);
        }
        else if((result!.code?.split('-').length == 5 && widget.type == 1) || (result!.code?.split('_').length == 4 && widget.type != 1)) {
          final infoTicketSplit = result!.code?.split('-');
          final inforDecode = widget.type == 1 ? await consumeAPI.decodeTicketByScan(infoTicketSplit![0], infoTicketSplit[1], infoTicketSplit[2], infoTicketSplit[3], infoTicketSplit[4]): await consumeAPI.decodeTicketTravelByScan(result!.code ?? '');

          if(inforDecode['etat'] == 'found') {
            showDialog(
                context: context,
                builder: (BuildContext context) => dialogCustomForValidateAction(
                    "Ticket Verifié",
                    inforDecode['result'],
                    "Continuer",
                        () {
                    },
                    context),
                barrierDismissible: false);

          }
          else if(inforDecode['etat'] =='notFound' && inforDecode['etat'] == "Vous n'êtes pas authorisé") {
            showDialog(
                context: context,
                builder: (BuildContext context) =>
                    dialogCustomError('Plusieurs connexions à ce compte', "Pour une question de sécurité nous allons devoir vous déconnecter.", context),
                barrierDismissible: false);

            //Navigator.pushAndRemoveUntil(context, newRoute, (route) => false)
            Navigator.of(context).push(MaterialPageRoute(
                builder: (builder) => Login()));
          }
          else {
            showDialog(
                context: context,
                builder: (BuildContext context) => dialogCustomForValidateAction(
                    "Erreur",
                    inforDecode['error'],
                    "Ok",
                        () {

                    }, context),
                barrierDismissible: false);


          }
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) => dialogCustomForValidateAction(
                  "Erreur",
                  "Ce code n'est pas pris en charge par SHOUZ ",
                  "Ok",
                      () {

                  }, context, false),
              barrierDismissible: false);
        }
        setState(() {
          scanned = false;
          result = null;
        });

      }

    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous n\'aviez pas encore donné la permission de votre camera à shouz')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
