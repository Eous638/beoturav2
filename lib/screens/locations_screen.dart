import 'package:flutter/material.dart';
import "package:beotura/widget/list_widget.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tour_provider.dart';
import '../classes/loactions_class.dart';
import '../l10n/localization_helper.dart';

class LocationScreen extends ConsumerWidget {
  const LocationScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Location>> locations =
        ref.watch(locationProviderProvider);
    final l10n = LocalizationHelper(ref);

    return Scaffold(
      appBar: AppBar(
          title: Text(
        l10n.translate('locations'),
      )),
      body: locations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        // ignore: avoid_types_as_parameter_names, non_constant_identifier_names
        data: (Location) => Location.isEmpty
            ? const Center(
                child: Text('No Tours Found')) // Handle empty data case
            : ListView.builder(
                itemCount: Location.length, // No need for '?' here
                itemBuilder: (context, index) {
                  final location = Location[index]; // Already have the data
                  return ListCard(
                    item: location,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    isTour: false, // Ensure isTour is false
                  ); // No '!' needed
                },
              ),
      ),
    );
  }
}
