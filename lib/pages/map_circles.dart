import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/map_style.dart';

class MapCircles extends StatefulWidget {
  const MapCircles({Key? key}) : super(key: key);

  @override
  _MapCirclesState createState() => _MapCirclesState();
}

class _MapCirclesState extends State<MapCircles> {
  GoogleMapController? _controller;
  final Set<Circle> _circles = <Circle>{};
  final Set<Marker> _markers = <Marker>{};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-16.525429484126306, -68.06266893632818),
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
            markers: _markers, // Añade los marcadores al mapa
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
          Positioned(
            bottom: 140,
            left: 20,
            child: FloatingActionButton(
              onPressed: _addMarker,
              child: Icon(Icons.add_location),
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

  void _addMarker() async {
    var result = await showDialog(
      context: context,
      builder: (BuildContext context) => AddMarkerDialog(),
    );
    if (result != null) {
      final marker = Marker(
        markerId: MarkerId(DateTime.now().toString()),
        position: _selectedPosition!,
        infoWindow:
            InfoWindow(title: result["title"], snippet: result["description"]),
      );
      setState(() {
        _markers.add(marker);
        _selectedPosition = null;
      });
    }
  }
}

class AddMarkerDialog extends StatefulWidget {
  const AddMarkerDialog({Key? key}) : super(key: key);

  @override
  _AddMarkerDialogState createState() => _AddMarkerDialogState();
}

class _AddMarkerDialogState extends State<AddMarkerDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Agregar punto de interés"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: "Título",
            ),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: "Descripción",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            var newMarker = {
              "title": _titleController.text,
              "description": _descriptionController.text,
            };
            Navigator.of(context).pop(newMarker);
          },
          child: Text("Agregar"),
        ),
      ],
    );
  }
}
