import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;

class CodeScanner extends StatefulWidget {
  CodeScanner({Key key}) : super(key: key);

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
        appBar: new AppBar(
          backgroundColor: prefix0.backgroundColor,
          elevation: 0,
          title: new Text('Scannage'),
        ),
        body: new Center(
          child: new Column(
            children: <Widget>[
              new Container(
                child: new MaterialButton(
                    onPressed: () {
                      print('OK');
                    },
                    child: new Text("Scan")),
                padding: const EdgeInsets.all(8.0),
              ),
              new Text(barcode),
            ],
          ),
        ));
  }
}
