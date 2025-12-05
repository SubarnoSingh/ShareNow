import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final h = history[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.check_circle)),
          title: Text(h.fileName),
          subtitle: Text('${h.sizeMB.toStringAsFixed(2)} MB • ${h.completedAt}'),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => ref.read(historyProvider.notifier).open(h),
          ),
        );
      },
    );
  }
}