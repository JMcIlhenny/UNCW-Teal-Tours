import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class OnDemandScreen extends StatefulWidget {
  const OnDemandScreen({Key? key}) : super(key: key);

  @override
  State<OnDemandScreen> createState() => _OnDemandScreenState();
}

class _OnDemandScreenState extends State<OnDemandScreen> {
  List<Position> positions = [];
  String? error;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("On Demand Location")),
      body: Center(
        child: Column(
          children: [
            if (!isProcessing)
              ElevatedButton(
                onPressed: () => _determinePosition().then((position) {
                  if (position != null) {
                    setState(() {
                      positions.add(position);
                    });
                  } else {
                    setState(() {
                      error = 'Failed to retrieve position.';
                    });
                  }
                }),
                child: const Text("Get Location"),
              ),
            if (isProcessing) const CircularProgressIndicator(),
            if (error != null)
              Text(
                error!,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            if (positions.isEmpty)
              const Expanded(child: Text("No positions yet.")),
            if (positions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: positions.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "${positions[index].latitude} ${positions[index].longitude} ${positions[index].accuracy}",
                    ),
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () => setState(() => positions.clear()),
              child: const Text("Clear"),
            ),
          ],
        ),
      ),
    );
  }

  /// Determines the current position of the device.
  Future<Position?> _determinePosition() async {
    error = null;

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      error = 'Location services are disabled.';
      return null;
    }

    // Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        error = 'Location permissions are denied.';
        return null;
      }
    }

    // Check if location permissions are permanently denied
    if (permission == LocationPermission.deniedForever) {
      error =
          'Location permissions are permanently denied, we cannot request permissions.';
      return null;
    }

    // Retrieve the current position
    try {
      setState(() => isProcessing = true);
      Position position = await Geolocator.getCurrentPosition();
      setState(() => isProcessing = false);
      return position;
    } catch (e) {
      setState(() {
        error = 'Error retrieving position: $e';
        isProcessing = false;
      });
      return null;
    }
  }
}
