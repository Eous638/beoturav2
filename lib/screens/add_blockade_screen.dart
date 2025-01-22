import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';

class AddBlockadeScreen extends ConsumerStatefulWidget {
  const AddBlockadeScreen({Key? key}) : super(key: key);

  @override
  _AddBlockadeScreenState createState() => _AddBlockadeScreenState();
}

class _AddBlockadeScreenState extends ConsumerState<AddBlockadeScreen> {
  final _universityNameController = TextEditingController();
  final _generalInformationController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String _status = 'Active';
  LatLng _selectedLocation = LatLng(44.8176, 20.4633); // Default to Belgrade

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blockade'),
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
          items: ['Active', 'on Hold', 'inactive'].map((String value) {
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
                subdomains: ['a', 'b', 'c'],
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
          onPressed: _isLoading ? null : _addBlockade,
          child: const Text('Add Blockade'),
        ),
      ],
    );
  }

  Future<void> _addBlockade() async {
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
        final response = await http.post(
          Uri.parse('https://api2.gladni.rs/api/beotura/add_blockade'),
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
            'updates': [],
            'supplies': [],
          }),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context);
        } else {
          setState(() {
            _errorMessage = 'Failed to add blockade';
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
