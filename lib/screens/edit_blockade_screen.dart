// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../providers/blockades_provider.dart';

class EditBlockadeScreen extends ConsumerStatefulWidget {
  final Blockade blockade;

  const EditBlockadeScreen({super.key, required this.blockade});

  @override
  EditBlockadeScreenState createState() => EditBlockadeScreenState();
}

class EditBlockadeScreenState extends ConsumerState<EditBlockadeScreen> {
  late TextEditingController _universityNameController;
  late TextEditingController _generalInformationController;
  bool _isLoading = false;
  String? _errorMessage;
  late String _status;
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _universityNameController =
        TextEditingController(text: widget.blockade.universityName);
    _generalInformationController =
        TextEditingController(text: widget.blockade.generalInformation);
    _status = widget.blockade.status;
    _selectedLocation = LatLng(
        widget.blockade.coordinates.lat, widget.blockade.coordinates.lon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Blockade'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _universityNameController,
          decoration: const InputDecoration(labelText: 'University Name'),
        ),
        DropdownButtonFormField<String>(
          value: _status,
          items: ['active', 'on hold', 'inactive'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _status = newValue!;
            });
          },
          decoration: const InputDecoration(labelText: 'Status'),
        ),
        TextField(
          controller: _generalInformationController,
          decoration: const InputDecoration(labelText: 'General Information'),
        ),
        const SizedBox(height: 16),
        const Text('Select Location:'),
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: _selectedLocation,
                    child: const Icon(Icons.location_on, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading) const CircularProgressIndicator(),
        if (_errorMessage != null)
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
        ElevatedButton(
          onPressed: _isLoading ? null : _editBlockade,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Future<void> _editBlockade() async {
    final universityName = _universityNameController.text;
    final generalInformation = _generalInformationController.text;
    final user = ref.read(authProvider);

    if (user == null) {
      setState(() {
        _errorMessage = 'User not logged in';
      });
      return;
    }

    if (universityName.isNotEmpty &&
        _status.isNotEmpty &&
        generalInformation.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await http.put(
          Uri.parse(
              'https://api2.gladni.rs/api/beotura/blockades/${widget.blockade.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${user.token}',
          },
          body: jsonEncode({
            'university_name': universityName,
            'status': _status.toLowerCase(),
            'general_information': generalInformation,
            'coordinates': {
              'lat': _selectedLocation.latitude,
              'lon': _selectedLocation.longitude,
            },
          }),
        );

        if (response.statusCode == 200) {
          ref.refresh(blockadesProvider).value;
          Navigator.pop(context);
        } else {
          setState(() {
            _errorMessage = 'Failed to edit blockade';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


}
