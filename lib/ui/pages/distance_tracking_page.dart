import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location_project/ui/controllers/location_controller.dart';

class DistanceTrackingPage extends StatelessWidget {
  const DistanceTrackingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocationController locationController = Get.find();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Distance Tracking Page'),
          actions: [
            TextButton(
              onPressed: () {
                Get.toNamed('/tracking');
              },
              child: const Text('Tracking Page'),
            ),
            const TextButton(
              onPressed: null,
              child: Text('This page'),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      try {
                        await locationController.subscribeLocationUpdates();
                      } catch (e) {
                        Get.snackbar('Error.....', e.toString(),
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                      }
                    },
                    child: const Text('Start Tracking')),
                ElevatedButton(
                    onPressed: () async {
                      try {
                        await locationController.unSubscribeLocationUpdates();
                      } catch (e) {
                        Get.snackbar('Error.....', e.toString(),
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                      }
                    },
                    child: const Text('Stop Tracking')),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(() => Text(
                'Distance covered: ${locationController.distance.toStringAsFixed(2)} meters')),
            const SizedBox(
              height: 20,
            ),
            const Text('Current Location:'),
            Obx(() => Text(locationController.userLocation.toString())),
          ],
        ));
  }
}
