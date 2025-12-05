import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/p2p_providers.dart';

class SendPage extends ConsumerWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peersList = ref.watch(peersListProvider);
    final p2p = ref.read(p2pControllerProvider.notifier);
    final selected = ref.watch(selectedFilesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await p2p.startDiscovery();
                  final devices = await p2p.getPeers();
                  ref.read(peersListProvider.notifier).setPeers(devices);
                  if (context.mounted && devices.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No devices found')),
                    );
                  }
                },
                icon: const Icon(Icons.wifi_tethering),
                label: const Text('Discover devices'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(allowMultiple: true);
                  if (result == null || result.files.isEmpty) return;
                  final files = result.files
                      .map((f) => f.path)
                      .whereType<String>()
                      .map((p) => File(p))
                      .toList();
                  ref.read(selectedFilesProvider.notifier).state = files;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${files.length} file(s) selected')),
                    );
                  }
                },
                icon: const Icon(Icons.file_present),
                label: const Text('Select files'),
              ),
            ],
          ),
        ),
        if (selected != null && selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: selected.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final f = selected[index];
                  return Chip(label: Text(f.uri.pathSegments.last));
                },
              ),
            ),
          ),
        Expanded(
          child: peersList.isEmpty
              ? const Center(child: Text('No devices found'))
              : ListView.builder(
                  itemCount: peersList.length,
                  itemBuilder: (context, index) {
                    final d = peersList[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.smartphone)),
                      title: Text(d.name),
                      subtitle: Text(d.address ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await p2p.connectToDevice(d);
                          final files = ref.read(selectedFilesProvider);
                          if (files == null || files.isEmpty) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Select files first')),
                            );
                            return;
                          }
                          await p2p.sendFiles(files);
                        },
                        child: const Text('Send'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
