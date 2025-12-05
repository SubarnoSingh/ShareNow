import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/p2p_providers.dart';

class ReceivePage extends ConsumerWidget {
  const ReceivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectionStatusProvider);
    final transfers = ref.watch(activeTransfersProvider);
    final p2p = ref.read(p2pControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              await p2p.startAsHost();
              // Begin accepting incoming files
              await p2p.acceptIncoming(ref);
            },
            icon: const Icon(Icons.wifi),
            label: const Text('Start receiving'),
          ),
          const SizedBox(height: 12),
          Text('Status: ${connection.statusText}', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final t = transfers[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.insert_drive_file)),
                  title: Text(t.fileName),
                  subtitle: Text('${t.progress.toStringAsFixed(0)}% • ${t.speedMbps.toStringAsFixed(2)} MB/s'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}