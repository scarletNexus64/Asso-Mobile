import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/shipment_controller.dart';

class ShipmentView extends GetView<ShipmentController> {
  const ShipmentView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShipmentView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ShipmentView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
