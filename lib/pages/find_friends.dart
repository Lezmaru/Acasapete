import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_example/models/map_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FindFriends extends StatefulWidget {
  const FindFriends({Key? key}) : super(key: key);

  @override
  _FindFriendsState createState() => _FindFriendsState();
}

class _FindFriendsState extends State<FindFriends> {
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-16.525429484126306, -68.06266893632818),
    zoom: 14.4746,
  );

  final Set<Marker> _markers = {};
  late GoogleMapController _controller;

  final List<dynamic> _contacts = [
    {
      "name": "Yo",
      "position": const LatLng(-16.52861868568564, -68.05497049597385),
      "marker": 'assets/markers/marker-1.png',
      "image": 'assets/images/avatar-1.png',
    },
    {
      "name": "Natalia",
      "position": const LatLng(-16.53122524701329, -68.08683079169936),
      "marker": 'assets/markers/marker-2.png',
      "image": 'assets/images/avatar-2.png',
    },
    {
      "name": "Papá",
      "position": const LatLng(-16.511909123529342, -68.12099172257197),
      "marker": 'assets/markers/marker-3.png',
      "image": 'assets/images/avatar-3.png',
    },
    {
      "name": "Mamá",
      "position": const LatLng(-16.5301972598357, -68.07352681763473),
      "marker": 'assets/markers/marker-4.png',
      "image": 'assets/images/avatar-4.png',
    },
    {
      "name": "Sergio",
      "position": const LatLng(-16.521747096198894, -68.11206983078684),
      "marker": 'assets/markers/marker-5.png',
      "image": 'assets/images/avatar-5.png',
    },
    {
      "name": "Sara",
      "position": const LatLng(-16.531150554298044, -68.11257421214425),
      "marker": 'assets/markers/marker-6.png',
      "image": 'assets/images/avatar-6.png',
    },
    {
      "name": "Cristhian",
      "position": const LatLng(-16.520873537943217, -68.10645221742132),
      "marker": 'assets/markers/marker-7.png',
      "image": 'assets/images/avatar-7.png',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    createMarkers(context);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            markers: _markers,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              controller.setMapStyle(MapStyle().aubergine);
            },
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 120,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _controller.moveCamera(CameraUpdate.newLatLng(
                            _contacts[index]["position"]));
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              _contacts[index]['image'],
                              width: 60,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              _contacts[index]["name"],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await showDialog(
              context: context,
              builder: (BuildContext context) => AddContactDialog());
          if (result != null) {
            setState(() {
              _contacts.add(result);
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  createMarkers(BuildContext context) {
    Marker marker;

    _contacts.forEach((contact) async {
      marker = Marker(
        markerId: MarkerId(contact['name']),
        position: contact['position'],
        icon: await _getAssetIcon(context, contact['marker'])
            .then((value) => value),
        infoWindow: InfoWindow(
          title: contact['name'],
          snippet: 'Street 6 . 2min ago',
        ),
      );

      setState(() {
        _markers.add(marker);
      });
    });
  }

  Future<BitmapDescriptor> _getAssetIcon(
      BuildContext context, String icon) async {
    final Completer<BitmapDescriptor> bitmapIcon =
        Completer<BitmapDescriptor>();
    final ImageConfiguration config =
        createLocalImageConfiguration(context, size: const Size(5, 5));

    AssetImage(icon)
        .resolve(config)
        .addListener(ImageStreamListener((ImageInfo image, bool sync) async {
      final ByteData? bytes =
          await image.image.toByteData(format: ImageByteFormat.png);
      final BitmapDescriptor bitmap =
          BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
      bitmapIcon.complete(bitmap);
    }));

    return await bitmapIcon.future;
  }
}

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({Key? key}) : super(key: key);

  @override
  _AddContactDialogState createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Agregar contacto"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Nombre",
            ),
          ),
          TextField(
            controller: _latController,
            decoration: InputDecoration(
              labelText: "Latitud",
            ),
          ),
          TextField(
            controller: _lngController,
            decoration: InputDecoration(
              labelText: "Longitud",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            var newContact = {
              "name": _nameController.text,
              "position": LatLng(double.parse(_latController.text),
                  double.parse(_lngController.text)),
              "marker":
                  'assets/markers/marker-1.png', // Actualiza esto si quieres usar diferentes marcadores
              "image":
                  'assets/images/avatar-1.png', // Actualiza esto si quieres usar diferentes avatares
            };

            Navigator.of(context).pop(newContact);
          },
          child: Text("Agregar"),
        ),
      ],
    );
  }
}
