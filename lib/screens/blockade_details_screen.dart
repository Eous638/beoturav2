// ignore_for_file: use_build_context_synchronously

import 'package:beotura/screens/edit_blockade_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../providers/blockades_provider.dart';

class BlockadeDetailsScreen extends ConsumerStatefulWidget {
  final Blockade blockade;

  const BlockadeDetailsScreen({super.key, required this.blockade});

  @override
  _BlockadeDetailsScreenState createState() => _BlockadeDetailsScreenState();
}

class _BlockadeDetailsScreenState extends ConsumerState<BlockadeDetailsScreen> {
  late ScaffoldMessengerState scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  void _showNotification(String message) {
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blockadesAsyncValue = ref.watch(blockadesProvider);
    final isLoggedIn = ref.watch(authProvider.notifier).isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blockade.universityName),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditBlockadeScreen(blockade: widget.blockade),
                  ),
                );
                ref.refresh(blockadesProvider).value;
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(blockadesProvider).value;
        },
        child: blockadesAsyncValue.when(
          data: (blockades) {
            final updatedBlockade = blockades.firstWhere(
                (b) => b.id == widget.blockade.id,
                orElse: () => widget.blockade);

            final updates = updatedBlockade.updates;
            final supplies = updatedBlockade.supplies;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      updatedBlockade.universityName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: Colors.blueAccent),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          updatedBlockade.status == 'active'
                              ? Icons.check_circle
                              : Icons.error,
                          color: updatedBlockade.status == 'active'
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          updatedBlockade.status,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: updatedBlockade.status == 'active'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'This page provides information about the current status of the student protests. Please check the updates and supplies needed to support the cause.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.info),
                      label: const Text('General Information'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('General Information'),
                            content: SingleChildScrollView(
                              child: Text(updatedBlockade.generalInformation,
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.update),
                      label: const Text('Updates'),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.6,
                            minChildSize: 0.4,
                            maxChildSize: 0.9,
                            expand: false,
                            builder: (context, scrollController) =>
                                SingleChildScrollView(
                              controller: scrollController,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isLoggedIn)
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add Update'),
                                        onPressed: () async {
                                          await _addUpdate(context, ref);
                                          Navigator.pop(
                                              context); // Close the modal
                                        },
                                      ),
                                    const SizedBox(height: 16.0),
                                    updates.isEmpty
                                        ? const Text('No updates')
                                        : Column(
                                            children: updates.map((update) {
                                              return Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                elevation: 4.0,
                                                child: ListTile(
                                                  title: Text(update.title,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(update.text,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium),
                                                      const SizedBox(
                                                          height: 8.0),
                                                      Text(
                                                          update.date
                                                              .toString(),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall),
                                                    ],
                                                  ),
                                                  trailing: isLoggedIn
                                                      ? IconButton(
                                                          icon: const Icon(
                                                              Icons.delete),
                                                          onPressed: () async {
                                                            _deleteUpdate(
                                                                context,
                                                                ref,
                                                                update);
                                                            Navigator.pop(
                                                                context); // Close the modal
                                                          },
                                                        )
                                                      : null,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.local_shipping),
                      label: const Text('Supplies Needed'),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.6,
                            minChildSize: 0.4,
                            maxChildSize: 0.9,
                            expand: false,
                            builder: (context, scrollController) =>
                                SingleChildScrollView(
                              controller: scrollController,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isLoggedIn)
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add Supply'),
                                        onPressed: () async {
                                          await _addSupply(context, ref);
                                          Navigator.pop(
                                              context); // Close the modal
                                        },
                                      ),
                                    const SizedBox(height: 16.0),
                                    supplies.isEmpty
                                        ? const Text('No supplies needed')
                                        : Column(
                                            children: supplies.map((supply) {
                                              return Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                elevation: 4.0,
                                                child: ListTile(
                                                  title: Text(supply.name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium),
                                                  trailing: isLoggedIn
                                                      ? IconButton(
                                                          icon: const Icon(
                                                              Icons.delete),
                                                          onPressed: () async {
                                                            _deleteSupply(
                                                                context,
                                                                ref,
                                                                supply);
                                                            Navigator.pop(
                                                                context); // Close the modal
                                                          },
                                                        )
                                                      : null,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  void _deleteUpdate(BuildContext context, WidgetRef ref, Update update) async {
    final user = ref.read(authProvider);

    if (user == null) {
      _showNotification('User not logged in');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(
            'https://api2.gladni.rs/api/beotura/delete_blockade_update/${widget.blockade.id}/${update.id}'),
        headers: {
          'Authorization': 'Bearer ${user.token}',
        },
      );
      ref.refresh(blockadesProvider).value;
      if (response.statusCode == 200) {
        ref.refresh(blockadesProvider).value;
        _showNotification('Update deleted');
      } else {
        ref.refresh(blockadesProvider).value;
        _showNotification('Failed to delete update');
      }
    } catch (e) {
      _showNotification('An error occurred. Please try again.');
    }
  }

  void _deleteSupply(BuildContext context, WidgetRef ref, Supply supply) async {
    final user = ref.read(authProvider);

    if (user == null) {
      _showNotification('User not logged in');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(
            'https://api2.gladni.rs/api/beotura/delete_blockade_supply/${widget.blockade.id}/${supply.id}'),
        headers: {
          'Authorization': 'Bearer ${user.token}',
        },
      );

      if (response.statusCode == 200) {
        ref.refresh(blockadesProvider).value;
      } else {
        _showNotification('Failed to delete supply');
      }
    } catch (e) {
      _showNotification('An error occurred. Please try again.');
    }
  }

  Future<void> _addUpdate(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final textController = TextEditingController();
    final user = ref.read(authProvider);

    if (user == null) {
      _showNotification('User not logged in');
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: textController,
              decoration: const InputDecoration(labelText: 'Text'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final title = titleController.text;
              final text = textController.text;

              if (title.isNotEmpty && text.isNotEmpty) {
                try {
                  final response = await http.post(
                    Uri.parse(
                        'https://api2.gladni.rs/api/beotura/add_blockade_update/${widget.blockade.id}'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer ${user.token}',
                    },
                    body: jsonEncode({
                      'title': title,
                      'text': text,
                      'date': DateTime.now().toIso8601String(),
                    }),
                  );

                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    _showNotification('Update added');
                    ref.refresh(blockadesProvider).value;
                  } else {
                    _showNotification('Failed to add update');
                  }
                } catch (e) {
                  _showNotification('An error occurred. Please try again.');
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSupply(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final user = ref.read(authProvider);

    if (user == null) {
      _showNotification('User not logged in');
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Supply'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text;
              final quantity = int.tryParse(quantityController.text) ?? 0;

              if (name.isNotEmpty && quantity > 0) {
                try {
                  final response = await http.post(
                    Uri.parse(
                        'https://api2.gladni.rs/api/beotura/add_blockade_supply/${widget.blockade.id}'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer ${user.token}',
                    },
                    body: jsonEncode({
                      'name': name,
                      'quantity': quantity,
                    }),
                  );

                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    _showNotification('Supply added');
                    ref.refresh(blockadesProvider).value;
                  } else {
                    _showNotification('Failed to add supply');
                  }
                } catch (e) {
                  _showNotification('An error occurred. Please try again.');
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
