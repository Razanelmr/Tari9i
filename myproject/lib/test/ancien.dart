import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  Position? _currentPosition;
  LatLng? _selectedDestination;
  Set<Polyline> _polylines = {};
  bool _waitingForDriver = false;
  double _tripPrice = 0.0;
  String _selectedAddress = "";

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDisabledDialog(context);
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog(context);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showPermissionPermanentlyDeniedDialog(context);
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: currentLatLng, zoom: 15),
    ));
  }

  void startSearch() {
    showSearch(
      context: context,
      delegate: AddressSearchDelegate(this),
    );
  }

  Future<void> _getDestinationCoordinates(String address) async {
    if (address.isEmpty) return;
    try {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(address);
      if (locations.isEmpty) {
        _showNoResultDialog(context);
        return;
      }
      if (locations.length == 1) {
        _centerMapAndDrawRoute(locations.first);
        return;
      }
      _showLocationOptionsDialog(context, locations);
    } catch (e) {
      print("Erreur lors de la recherche d'adresse : $e");
      _showErrorDialog(context);
    }
  }

void _centerMapAndDrawRoute(geocoding.Location location) async {
  LatLng latLng = LatLng(location.latitude, location.longitude);

  setState(() {
    _selectedDestination = latLng;
  });

  mapController.animateCamera(CameraUpdate.newCameraPosition(
    CameraPosition(target: latLng, zoom: 15),
  ));

  _drawRoute(latLng);

  if (_currentPosition != null) {
    final double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latLng.latitude,
      latLng.longitude,
    );
    final double distanceInKm = distanceInMeters / 1000;
    final double price = distanceInKm * 2;

    geocoding.Placemark place = await _getAddressFromLatLng(location.latitude, location.longitude);

    String displayString = [
      place.name,
      place.thoroughfare,
      place.subThoroughfare,
      place.locality,
      place.administrativeArea,
      place.country,
    ].where((s) => s != null && s.trim().isNotEmpty).join(", ");

    setState(() {
      _controller.text = "Votre destination est $displayString";
      _selectedAddress = displayString;
      _tripPrice = price;
      _waitingForDriver = true;
    });
  }
}
  
Future<geocoding.Placemark> _getAddressFromLatLng(double lat, double lng) async {
  List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
  return placemarks.isNotEmpty ? placemarks.first : geocoding.Placemark();
}


  void _drawRoute(LatLng destination) async {
    if (_currentPosition == null) return;

    final String apiKey = "AIzaSyBUWK0RG1UqNnnoVKQn8VDBq_bxjQC-92c"; // 🔐 Remplace par ta clé API
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin= ${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey";

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      if (decodedData["routes"].isNotEmpty) {
        var points = decodedData["routes"][0]["overview_polyline"]["points"];
        final List<LatLng> coordinates = decodePolyline(points);

        setState(() {
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: PolylineId("route"),
            points: coordinates,
            color: Colors.blueAccent,
            width: 6,
          ));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Aucun itinéraire trouvé")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la récupération de l’itinéraire")),
      );
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<int> bytes = utf8.encode(encoded);
    const int mask = 0xff;
    List<int> result = [];
    int index = 0, lat = 0, lng = 0;
    while (index < bytes.length) {
      int shift = 0, resultCurrent = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        resultCurrent |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((resultCurrent & 1) != 0 ? ~(resultCurrent >> 1) : (resultCurrent >> 1));
      lat += dlat;
      shift = 0;
      resultCurrent = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        resultCurrent |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((resultCurrent & 1) != 0 ? ~(resultCurrent >> 1) : (resultCurrent >> 1));
      lng += dlng;
      result.add(lat);
      result.add(lng);
    }
    List<LatLng> ret = [];
    for (int i = 0; i < result.length; i += 2) {
      ret.add(LatLng((result[i + 1] / 1e5).toDouble(), (result[i] / 1e5).toDouble()));
    }
    return ret;
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _suggestions = [];
    });
    try {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(query);
      if (locations.isNotEmpty) {
        geocoding.Location firstLocation = locations.first;
        List<geocoding.Placemark> places = await geocoding.placemarkFromCoordinates(
          firstLocation.latitude,
          firstLocation.longitude,
        );
        setState(() {
          _suggestions = places.take(5).map((place) => {
                "placemark": place,
                "latitude": firstLocation.latitude,
                "longitude": firstLocation.longitude,
              }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur lors de la recherche : $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
    _controller.addListener(() {
      final String text = _controller.text;
      if (text.length > 3) {
        _searchAddress(text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Carte Google Maps")),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : LatLng(0, 0),
                zoom: _currentPosition != null ? 15 : 2,
              ),
              markers: {
                if (_selectedDestination != null)
                  Marker(
                    markerId: MarkerId("dest"),
                    position: _selectedDestination!,
                    infoWindow: InfoWindow(title: "Destination"),
                  ),
              },
              myLocationEnabled: true,
              polylines: _polylines,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.my_location),
              label: Text('Ma position'),
              onPressed: _getCurrentLocation,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Entrez une adresse...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _getDestinationCoordinates(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
          if (_isLoading)
            LinearProgressIndicator(),
          if (_suggestions.isNotEmpty)
            Container(
              height: 120,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final place = _suggestions[index]["placemark"] as geocoding.Placemark;
                    final double latitude = _suggestions[index]["latitude"] as double;
                    final double longitude = _suggestions[index]["longitude"] as double;

                    String displayString = [
                      place.name,
                      place.thoroughfare,
                      place.subThoroughfare,
                      place.locality,
                      place.administrativeArea,
                      place.country,
                    ].where((s) => s != null && s.trim().isNotEmpty).join(", ");

                    return ListTile(
                      leading: Icon(Icons.location_on_outlined),
                      title: Text(displayString),
                      subtitle: Text("${place.locality}, ${place.country}"),
                      onTap: () {
                        _centerMapAndDrawRoute(geocoding.Location(
                            latitude: latitude,
                            longitude: longitude,
                            timestamp: DateTime.now()));
                        setState(() {
                          _controller.text = displayString;
                          _suggestions.clear(); // 👈 Ferme la liste des suggestions
                        });
                      },
                      
                    );
                    
                  },
                  
                ),
              ),
            ),
          if (_waitingForDriver)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "En attente du chauffeur...",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            if (_tripPrice > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "Prix du trajet : ${_tripPrice.toStringAsFixed(2)} €",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
                  ],
      ),
    );
  }

  void _showNoResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Aucun résultat"),
        content: Text("Adresse introuvable. Vérifiez votre saisie."),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: Text("OK"))
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Erreur"),
        content: Text("Impossible de trouver cette adresse."),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: Text("Réessayer"))
        ],
      ),
    );
  }

  void _showLocationOptionsDialog(BuildContext context, List<geocoding.Location> locations) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final loc = locations[index];
            return ListTile(
              title: Text("Coordonnées : ${loc.latitude}, ${loc.longitude}"),
              subtitle: Text("Lieu $index+1"),
              onTap: () {
                Navigator.of(context).pop();
                _centerMapAndDrawRoute(loc);
              },
            );
          },
        );
      },
    );
  }






  void _showLocationDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Localisation désactivée"),
        content: Text("Veuillez activer votre localisation pour utiliser cette fonctionnalité."),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _getCurrentLocation(); // Réessayer
            },
            child: Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission refusée"),
        content: Text("La permission de localisation a été refusée."),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _getCurrentLocation(); // Réessayer
            },
            child: Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  void _showPermissionPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission bloquée"),
        content: Text("La permission est bloquée. Veuillez l'activer dans les paramètres de l'application."),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings(); // Nécessite package:app_settings ou device_info_plus
            },
            child: Text("Paramètres"),
          ),
        ],
      ),
    );
  }
}

class AddressSearchDelegate extends SearchDelegate<String> {
  final _MapScreenState parent;
  AddressSearchDelegate(this.parent);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        parent._getDestinationCoordinates(query);
      });
    }
    close(context, query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}