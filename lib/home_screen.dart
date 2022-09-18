// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<BarcodeClass> _listBarcode = [];

  // ignore: prefer_final_fields, unnecessary_new
  TextEditingController? _barcodeText = new TextEditingController();
  final FocusNode _barcodeFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Barcode Scanner - ${_listBarcode.length.toString()}"),
        actions: [
          IconButton(
            onPressed: scanBarcodeNormal,
            icon: const Icon(
              Icons.qr_code_scanner_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    autofocus: true,
                    focusNode: _barcodeFocus,
                    controller: _barcodeText,
                    onFieldSubmitted: _getListString,
                  ),
                ),
                Container(
                  color: Colors.blue,
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _getListString(_barcodeText!.text);
                    },
                  ),
                )
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, i) {
                  BarcodeClass _barcode = _listBarcode[i];
                  return ListTile(
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (c) {
                            return AlertDialog(
                              content: ElevatedButton(
                                onPressed: () {
                                  _listBarcode.removeWhere(
                                      (e) => e.barcode == _barcode.barcode);
                                  setState(() {});
                                },
                                child: const Text("Hapus"),
                              ),
                            );
                          });
                    },
                    title: Text(_barcode.barcode ?? "--"),
                    trailing: Text(
                      _barcode.count.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
                itemCount: _listBarcode.length,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRer;
    try {
      barcodeScanRer = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
    } on PlatformException {
      barcodeScanRer = 'Failed to get platform version.';
    }
    _getListString(barcodeScanRer);
  }

  _getListString(String barcodeScanRer) {
    if (!mounted) return;
    if (_listBarcode.isEmpty) {
      _listBarcode.add(BarcodeClass(barcode: barcodeScanRer, count: 1));
      setState(() {});
    } else {
      var _barcode = _listBarcode.firstWhere((e) => e.barcode == barcodeScanRer,
          orElse: () => BarcodeClass());
      if (_barcode.barcode != null) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text("Nomor Barcode $barcodeScanRer sudah ada !!"),
              );
            });
      } else {
        _listBarcode.add(BarcodeClass(barcode: barcodeScanRer, count: 1));
        setState(() {});
      }
    }
    _barcodeText!.text = "";
    _barcodeFocus.requestFocus();
    setState(() {});
  }
}

class BarcodeClass {
  String? barcode;
  int count = 0;

  BarcodeClass({this.barcode, this.count = 0});
}
