import 'package:beotura/services/combined_communication_service.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class ProtestAlertService {
  final CombinedCommunicationService webSocketService;
  final BuildContext context;
  String? myActiveAlert;

  ProtestAlertService({
    required this.webSocketService,
    required this.context,
  });

  Future<void> sendAlert({
    required String alertType,
    required LatLng? currentLocation,
    required Future<LatLng?> Function() selectLocationOnMap,
  }) async {
    debugPrint('ProtestAlertService: Starting alert send process for type: $alertType');
    
    if (currentLocation == null) {
      _showMessage('Waiting for location...');
      debugPrint('ProtestAlertService: No current location available');
      return;
    }

    _showMessage('Tap on the map to select alert location.');
    final selectedLocation = await selectLocationOnMap();
    
    if (selectedLocation == null) {
      _showMessage('No location selected.');
      debugPrint('ProtestAlertService: No location selected by user');
      return;
    }

    debugPrint('ProtestAlertService: Location selected: $selectedLocation');
    final confirm = await _showConfirmationDialog();
    
    if (confirm == true) {
      debugPrint('ProtestAlertService: Alert confirmed, sending to communication service');
      try {
        webSocketService.sendAlert(
          type: alertType,
          location: selectedLocation,
        );
        _showMessage('Alert sent successfully');
      } catch (e) {
        debugPrint('ProtestAlertService: Error sending alert: $e');
        _showMessage('Failed to send alert: ${e.toString()}');
      }
    } else {
      debugPrint('ProtestAlertService: Alert cancelled by user');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Alert'),
        content: const Text(
            'Do you want to send the alert at the selected location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
