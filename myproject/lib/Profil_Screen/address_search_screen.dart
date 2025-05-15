import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class AddressSearchScreen extends StatefulWidget {
  late Position? currentPosition ;
  AddressSearchScreen({Key? key, required this.currentPosition}) : super(key: key); 
  @override
  _AddressSearchScreenState createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  TextEditingController _departureController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  final List<String> predefinedSuggestions = const [
    "Université Frères Mentouri Constantine",
    "Pont Sidi M'Cid",
    "Casbah de Constantine",
    "Gare de Constantine",
    "Centre Commercial Zianides",
    "Place du 1er Mai",
    "Hôpital Ibn Zohd Constantine",
    "Hôtel El Mouradi Constantine",
    "Aéroport Mohamed Boudiaf - Constantine",
    "Cité Ali Mendjeli",
  ];

  List<String> _suggestions = [];
  bool _isLoading = false;
  late FocusNode _departureFocusNode;
  late FocusNode _destinationFocusNode;
  String? _activeField; // 'departure' or 'destination'
  final String googleApiKey = "AIzaSyBUWK0RG1UqNnnoVKQn8VDBq_bxjQC-92c";

  @override
  void initState() {
    super.initState();

    // Initialisation des FocusNode
    _departureFocusNode = FocusNode();
    _destinationFocusNode = FocusNode();

    // Toujours initialiser les contrôleurs dès le début
    _departureController = TextEditingController(text: "Votre position actuelle");
    _destinationController = TextEditingController();

    // Si on a une position, mettre à jour avec l'adresse réelle
    if (widget.currentPosition != null) {
      _getAddressFromLatLng(
        widget.currentPosition!.latitude,
        widget.currentPosition!.longitude,
      ).then((address) {
        if (mounted) {
          setState(() {
            _departureController.text = address ?? "Votre position actuelle";
          });
        }
      });
    }
    

    // Suivi du champ actif
    _departureFocusNode.addListener(() {
      if (_departureFocusNode.hasFocus) _activeField = 'departure';
    });

    _destinationFocusNode.addListener(() {
      if (_destinationFocusNode.hasFocus) _activeField = 'destination';
    });

    // Écouteurs pour les champs de saisie
    _departureController.addListener(() {
      final String text = _departureController.text;
      if (text.length > 1) {
        _searchAddress(text);
      } else {
        setState(() => _suggestions = predefinedSuggestions);
      }
    });

    _destinationController.addListener(() {
      final String text = _destinationController.text;
      if (text.length > 1) {
        _searchAddress(text);
      } else {
        setState(() => _suggestions = predefinedSuggestions);
      }
    });

    // Suggestions initiales
    _suggestions = predefinedSuggestions;
  }

  
  
  
  
  
    Future<String?> _getAddressFromLatLng(double lat, double lng) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng= $lat,$lng&key=$googleApiKey&language=fr";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        return data["results"][0]["formatted_address"];
      }
    }
    return null;
  }

  
  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = predefinedSuggestions);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Filtre des suggestions prédéfinies
      final List<String> filteredPredefined = predefinedSuggestions
          .where((s) => s.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Recherche via géocodage
      final List<geocoding.Location> locations = await geocoding.locationFromAddress(query);
      List<String> geocodingResults = [];

      if (locations.isNotEmpty) {
        final List<geocoding.Placemark> places = await geocoding.placemarkFromCoordinates(
          locations.first.latitude,
          locations.first.longitude,
        );

        geocodingResults = places.map((place) {
          final List<String?> parts = [
            place.name,
            place.thoroughfare,
            place.subThoroughfare,
            place.locality,
            place.administrativeArea,
            place.country,
          ];
          return parts.where((s) => s?.isNotEmpty ?? false).join(", ");
        }).toList();
      }

      setState(() {
        _suggestions = [...filteredPredefined, ...geocodingResults];
      });
    } catch (e) {
      print("Erreur de géocodage : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _departureFocusNode.dispose();
    _destinationFocusNode.dispose();
    _departureController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _submitSelection() {
    if (_departureController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez sélectionner un départ et une destination")),
      );
      return;
    }
    
    Navigator.of(context).pop({
      'departure': _departureController.text,
      'destination': _destinationController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF09183F),
        title: Text("Choisir votre destination", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Fermer sans sélection
          },
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            // Champ de départ
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: _departureController,
                focusNode: _departureFocusNode,
                decoration: InputDecoration(
                  hintText: "Rechercher votre depart...",
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF09183F)),
                  suffixIcon: Icon(Icons.location_on_outlined, color: Colors.green),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF09183F),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF09183F),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
              ),
            ),

            SizedBox(height: 12),

            // Champ de destination
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: TextField(
                controller: _destinationController,
                focusNode: _destinationFocusNode,
                decoration: InputDecoration(
                  hintText: "Rechercher votre destination...",
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF09183F)),
                  suffixIcon: Icon(Icons.location_on_outlined, color: Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF09183F),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF09183F),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
              ),
            ),

            if (_isLoading) LinearProgressIndicator(color: Color(0xFF09183F)),

            // Liste unique de suggestions
            Expanded(
              child: _suggestions.isNotEmpty
                  ? ListView.separated(
                    separatorBuilder: (_, __) => SizedBox(height: 8),
                      itemCount: _suggestions.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5,),
                            child: Text(
                              _activeField == 'departure' ? "Suggestions pour départ" : "Suggestions pour destination",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          );
                        }
                        final String suggestion = _suggestions[index - 1];
                        final bool isDeparture = _activeField == 'departure';
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal:2),
                          child: Material(
                            
                            color: const Color.fromARGB(236, 255, 255, 255),
                            borderRadius: BorderRadius.circular(12),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                              if (isDeparture) {
                                _departureController.text = suggestion;
                              } else {
                                _destinationController.text = suggestion;
                              }
                              setState(() => _suggestions = []); // Réinitialise les suggestions
                            },
                              borderRadius: BorderRadius.circular(70),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 0),
                                child:ListTile(
                            leading: Icon(Icons.location_on, color: isDeparture ? Colors.green : Colors.red),
                            title: Text(suggestion, style: TextStyle(fontSize: 14),),
                            onTap: () {
                              if (isDeparture) {
                                _departureController.text = suggestion;
                              } else {
                                _destinationController.text = suggestion;
                              }
                              setState(() => _suggestions = []); // Réinitialise les suggestions
                            },
                          )))),
                        );
                      },
                      
                    )
                  : Container(),
            ),

            ElevatedButton(
              onPressed: _submitSelection,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF09183F)),
              child: Text("Valider"),
            ),
          ],
        ),
      ),
    );
  }
}