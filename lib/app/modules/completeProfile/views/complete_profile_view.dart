import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/complete_profile_controller.dart';

class CompleteProfileView extends GetView<CompleteProfileController> {
  const CompleteProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CompleteProfileView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CompleteProfileView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
