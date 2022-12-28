import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SWA Task',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'SWA Task'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController? _controller;

  double x = 0, y = 0, z = 0;
  String direction = "none";
  double percentage = 0.0;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  BitmapDescriptor? markerIcon;
  Position? currentPostion;
  LocationPermission locationPermission = LocationPermission.denied;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // BitmapDescriptor.fromAssetImage(
    //         const ImageConfiguration(), 'assets/images/bike.png')
    //     .then((value) {
    //   markerIcon = value;
    // });

    // _determinePermission().then((value) {
    //   locationPermission = value;
    // });

    accelerometerEvents.listen((AccelerometerEvent event) {
      x = event.x;
      y = event.y;
      z = event.z;

      if (x > 1) {
        direction = "left";
      } else if (x < -1) {
        direction = "right";
      } else {
        direction = "straight";
      }

      double radians = atan(x);
      double degree = radians * (180.0 / pi);
      int degreeRound = direction == "left"
          ? (degree.round() - 50)
          : (degree.round() + 50).abs();
      percentage = degreeRound * (100 / 39);

      // final marker = Marker(
      //   markerId: const MarkerId('current'),
      //   position: currentPostion != null
      //       ? LatLng(currentPostion!.latitude, currentPostion!.longitude)
      //       : const LatLng(37.42796133580664, -122.085749655962),
      //   icon: markerIcon != null ? markerIcon! : BitmapDescriptor.defaultMarker,
      //   infoWindow: const InfoWindow(
      //     title: 'title',
      //     snippet: 'address',
      //   ),
      //   rotation: direction == "left"
      //       ? -percentage
      //       : direction == "right"
      //           ? percentage
      //           : 0,
      // );

      // markers[const MarkerId('current')] = marker;

      if (mounted) setState(() {});
    });
    super.initState();
  }

  // ignore: unused_element
  Future<LocationPermission> _determinePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showToast('Location services are disabled.');
      return LocationPermission.denied;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showToast('Location permissions are denied');
        return permission;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showToast(
          'Location permissions are permanently denied, we cannot request permissions.');
      return permission;
    }

    currentPostion = await Geolocator.getCurrentPosition();
    _controller?.moveCamera(CameraUpdate.newLatLng(
        LatLng(currentPostion!.latitude, currentPostion!.longitude)));
    return permission;
  }

  showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Text(
              "Bike Leaning Angle",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            Text(
              direction,
              style: const TextStyle(fontSize: 30),
            ),
            Visibility(
              visible: x < -1 || x > 1,
              maintainSize: true,
              maintainState: true,
              maintainAnimation: true,
              child: Text(
                "${(percentage.toStringAsFixed(0))}%",
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 30),
            Transform.rotate(
              angle: direction == "left"
                  ? -(percentage * pi / 360)
                  : direction == "right"
                      ? percentage * pi / 360
                      : 0,
              child: Image.asset('assets/images/bike.png'),
            ),
            // Expanded(
            //   child: GoogleMap(
            //     mapType: MapType.normal,
            //     initialCameraPosition: const CameraPosition(
            //       target: LatLng(37.42796133580664, -122.085749655962),
            //       zoom: 15,
            //     ),
            //     markers: markers.values.toSet(),
            //     onMapCreated: (GoogleMapController controller) {
            //       _controller = controller;
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
