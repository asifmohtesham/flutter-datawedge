import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BarcodeData {
  final String dataString;
  final String labelType;

  BarcodeData({required this.dataString, required this.labelType});

  factory BarcodeData.fromMap(Map<String, dynamic> map) {
    return BarcodeData(
      dataString: map['data_string'] ?? '',
      labelType: map['label_type'] ?? 'UNKNOWN',
    );
  }
}

class ZebraScannerController extends GetxController {
  static const MethodChannel _scanChannel = MethodChannel('com.zebra.flutterbarcode/scan');
  static const EventChannel _scanStream = EventChannel('com.zebra.flutterbarcode/scan_stream');

  final lastScanned = ''.obs;
  RxList<BarcodeData> barcodes = <BarcodeData>[].obs;

  @override
  void onInit() {
    super.onInit();
    _scanStream.receiveBroadcastStream().listen((event) {
      if (event is List) {
        updateBarcodes(event);
      }
    }, onError: (err) {
      Get.snackbar("Stream Error", err.toString());
    });
  }

  void updateBarcodes(List<dynamic> scanned) {
    print(scanned.runtimeType);
    barcodes.value = scanned
        .whereType<Map<Object?, Object?>>()
        .map((e) => BarcodeData.fromMap(
          e.map((key, value) => MapEntry(key.toString(), value)),
        ))
        .toList();
  }

  void clearBarcodes() {
    barcodes.clear();
  }

  Future<void> startScan() async {
    try {
      await _scanChannel.invokeMethod('startScan');
    } on PlatformException catch (e) {
      Get.snackbar("Scan Error", e.message ?? "Unknown error");
    }
  }
}
