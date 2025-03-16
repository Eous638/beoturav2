import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';
import '../classes/loactions_class.dart';
import '../l10n/localization_helper.dart';
import '../widget/list_widget.dart'; // Import the card widget

class LocationsScreen extends ConsumerWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Location>> locations =
        ref.watch(locationProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper(ref).translate('Locations')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: locations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (locationsData) => locationsData.isEmpty
            ? const Center(
                child: Text(
                  'No Locations Found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: locationsData.length,
                  itemBuilder: (context, index) {
                    final location = locationsData[index];
                    return ListCard(
                      item: location,
                      isTour: false, // Set isTour to false for locations
                    );
                  },
                ),
              ),
      ),
    );
  }
}
