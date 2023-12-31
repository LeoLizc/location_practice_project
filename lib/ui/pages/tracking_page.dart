import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../controllers/location_controller.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({Key? key}) : super(key: key);

  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  late GoogleMapController googleMapController;

  void _onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
  }

  LatLngBounds _bounds(Set<Marker> markers) {
    logInfo('Creating new bounds');
    return _createBounds(markers.map((m) => m.position).toList());
  }

  LatLngBounds _createBounds(List<LatLng> positions) {
    final southwestLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value < element ? value : element); // smallest
    final southwestLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value > element ? value : element); // biggest
    final northeastLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon));
  }

  @override
  Widget build(BuildContext context) {
    LocationController locationController = Get.find();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      key: const Key("clear"),
                      onPressed: () async {
                        locationController.clearLocation();
                      },
                      child: const Text("Clear")),
                  ElevatedButton(
                      key: const Key("getMarkers"),
                      onPressed: () async {
                        locationController.updatedMarker();
                      },
                      child: const Text("Markers")),
                  ElevatedButton(
                      key: const Key("currentLocation"),
                      onPressed: () async {
                        try {
                          locationController.getLocation();
                        } catch (e) {
                          Get.snackbar('Error.....', e.toString(),
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                        }
                      },
                      child: const Text("Current")),
                ],
              ),
              Obx(() => ElevatedButton(
                  key: const Key("changeLiveUpdate"),
                  onPressed: () async {
                    if (!locationController.liveUpdate) {
                      await locationController
                          .subscribeLocationUpdates()
                          .onError((error, stackTrace) {
                        Get.snackbar('Error.....', error.toString(),
                            backgroundColor: Colors.red,
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Colors.white);
                      });
                    } else {
                      await locationController
                          .unSubscribeLocationUpdates()
                          .onError((error, stackTrace) {
                        Get.snackbar('Error.....', error.toString(),
                            backgroundColor: Colors.red,
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Colors.white);
                      });
                    }
                  },
                  child: Text(locationController.liveUpdate
                      ? "Set live updates off"
                      : "Set live updates on"))),
              GetX<LocationController>(builder: (controller) {
                logInfo('Recreating map');
                return Expanded(
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    mapType: MapType.normal,
                    markers: Set<Marker>.of(controller.markers.values),
                    myLocationEnabled: true,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(11.0227767, -74.81611),
                      zoom: 17.0,
                    ),
                  ),
                );
              }),
              GetX<LocationController>(
                builder: (controller) {
                  if (locationController.markers.values.isNotEmpty) {
                    googleMapController.animateCamera(
                        CameraUpdate.newLatLngBounds(
                            _bounds(Set<Marker>.of(
                                locationController.markers.values)),
                            50));
                  } else {
                    if (controller.userLocation.value.latitude != 0) {
                      googleMapController.moveCamera(CameraUpdate.newLatLng(
                          LatLng(controller.userLocation.value.latitude,
                              controller.userLocation.value.longitude)));
                    }
                  }
                  logInfo(
                      "UI <${controller.userLocation.value.latitude} ${controller.userLocation.value.longitude}>");

                  return Text(
                    "${controller.userLocation.value.latitude} ${controller.userLocation.value.longitude}",
                    key: const Key("position"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
