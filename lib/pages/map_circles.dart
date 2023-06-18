import 'package:flutter/material.dart';
import 'package:google_maps_example/models/map_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapCircles extends StatefulWidget {
  const MapCircles({Key? key}) : super(key: key);

  @override
  _MapCirclesState createState() => _MapCirclesState();
}

class _MapCirclesState extends State<MapCircles> {
  GoogleMapController? _controller;
  final Set<Circle> _circles = <Circle>{};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(0.347596, 32.582520),
    zoom: 14.4746,
  );

  LatLng? _selectedPosition; // Posición seleccionada para agregar círculos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            circles: _circles,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              _controller!.setMapStyle(MapStyle().dark);
            },
            onTap: (LatLng latLng) {
              setState(() {
                _selectedPosition = latLng;
              });
            },
          ),
          if (_selectedPosition != null)
            Positioned(
              bottom: 80,
              left: 20,
              child: FloatingActionButton(
                onPressed: () {
                  _addCircle();
                },
                child: Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }

  void _addCircle() {
    final circleId = CircleId(DateTime.now().toString());
    final circle = Circle(
      circleId: circleId,
      center: _selectedPosition!,
      radius: 300,
      fillColor: Colors.red.shade500.withOpacity(.5),
      strokeColor: Colors.red.shade300.withOpacity(.7),
      strokeWidth: 5,
    );

    setState(() {
      _circles.add(circle);
      _selectedPosition = null;
    });
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapCircles(),
    );
  }
}
