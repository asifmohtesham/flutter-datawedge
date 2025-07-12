import 'package:flutter/material.dart';
import 'package:flutter_barcode/controller/zebra_scanner_controller.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ZebraScannerController scannerController = Get.put(ZebraScannerController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Zebra Scanner',
      debugShowCheckedModeBanner: false,
      home: ScannerScreen(),
    );
  }
}

class ScannerScreen extends StatelessWidget {
  final ZebraScannerController scannerController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zebra Scanner Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan'),
                  onPressed: scannerController.startScan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Clear'),
                  onPressed: scannerController.clearBarcodes,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() => Text(
              '📦 Last scanned: ${scannerController.lastScanned.value}',
              style: const TextStyle(fontSize: 18),
            )),
            const SizedBox(height: 20),
            Obx(() {
              return Expanded(
                child: ListView.builder(
                  itemCount: scannerController.barcodes.length,
                  itemBuilder: (_, index) {
                    final barcode = scannerController.barcodes[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📦 ${barcode.dataString}', style: TextStyle(fontSize: 18)),
                            SizedBox(height: 4),
                            Text('🔖 ${barcode.labelType}', style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
