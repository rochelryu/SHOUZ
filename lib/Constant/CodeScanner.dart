import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;

class CodeScanner extends StatefulWidget {
  CodeScanner({Key? key}) : super(key: key);

  @override
  _CodeScannerState createState() => _CodeScannerState();
}

class _CodeScannerState extends State<CodeScanner> {
  String barcode = "";

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: prefix0.backgroundColor,
        appBar: AppBar(
          backgroundColor: prefix0.backgroundColor,
          elevation: 0,
          title: Text('Scannage'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              new Container(
                child: MaterialButton(
                    onPressed: () {
                      print('OK');
                    },
                    child: Text("Scan")),
                padding: const EdgeInsets.all(8.0),
              ),
              Text(barcode),
            ],
          ),
        ));
  }
}
