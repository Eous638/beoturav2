import 'package:flutter/material.dart';
import "package:beotura/widget/list_widget.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tour_provider.dart';
import '../classes/tours_class.dart';
import '../l10n/localization_helper.dart';

class ToursScreen extends ConsumerWidget {
  const ToursScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Tour>> tours = ref.watch(tourProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper(ref).translate('Tours')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: tours.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (toursData) => toursData.isEmpty
            ? const Center(
                child: Text(
                  'No Tours Found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: toursData.length,
                  itemBuilder: (context, index) {
                    final tour = toursData[index];
                    return ListCard(
                      item: tour,
                      isTour: true, // Set isTour to true
                    );
                  },
                ),
              ),
      ),
    );
  }
}
