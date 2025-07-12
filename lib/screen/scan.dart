import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_barcode/controller/zebra_scanner_controller.dart';

class ScanScreen extends StatelessWidget {
  final controller = Get.put(ZebraScannerController());

  ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Zebra Scanner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(
              'Scanned: ${controller.lastScanned.value}',
              style: TextStyle(fontSize: 18),
            )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.startScan,
              child: const Text('🔍 Start Scan'),
            ),
          ],
        ),
      ),
    );
  }
}
