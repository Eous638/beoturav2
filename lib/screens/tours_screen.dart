import 'package:flutter/material.dart';
import "package:beotura/widget/list_widget.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tour_provider.dart';
import '../classes/tours_class.dart';
import '../l10n/localization_helper.dart';

class ToursScreen extends ConsumerWidget {
  const ToursScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Tour>> tours = ref.watch(tourProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper(ref).translate('Tours')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: tours.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (toursData) => toursData.isEmpty
            ? const Center(
                child: Text('No Tours Found')) // Handle empty data case
            : ListView.builder(
                itemCount: toursData.length, // No need for '?' here
                itemBuilder: (context, index) {
                  final tour = toursData[index];
                  // Already have the data
                  return ListCard(
                    item: tour,
                    locations: tour.locations,
                    isTour: true, // Set isTour to true
                  ); // No '!' needed
                },
              ),
      ),
    );
  }
}
