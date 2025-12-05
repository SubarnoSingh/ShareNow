import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class HistoryItem {
  final String fileName;
  final double sizeMB;
  final DateTime completedAt;
  final File file;
  HistoryItem(this.fileName, this.sizeMB, this.completedAt, this.file);
}

class HistoryNotifier extends StateNotifier<List<HistoryItem>> {
  HistoryNotifier() : super(const []) {
    _load();
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/history.json');
  }

  Future<void> _load() async {
    try {
      final f = await _file();
      if (await f.exists()) {
        final jsonList = jsonDecode(await f.readAsString()) as List<dynamic>;
        state = jsonList.map((e) {
          final m = e as Map<String, dynamic>;
          return HistoryItem(
            m['fileName'] as String,
            (m['sizeMB'] as num).toDouble(),
            DateTime.parse(m['completedAt'] as String),
            File(m['path'] as String),
          );
        }).toList();
      }
    } catch (_) {}
  }

  void add(File file) {
    final sizeMB = file.lengthSync() / (1024 * 1024);
    state = [
      HistoryItem(file.uri.pathSegments.last, sizeMB, DateTime.now(), file),
      ...state,
    ];
    _persist();
  }

  void open(HistoryItem item) {
    OpenFilex.open(item.file.path);
  }

  Future<void> _persist() async {
    final f = await _file();
    final jsonList = state
        .map((e) => {
              'fileName': e.fileName,
              'sizeMB': e.sizeMB,
              'completedAt': e.completedAt.toIso8601String(),
              'path': e.file.path,
            })
        .toList();
    await f.writeAsString(jsonEncode(jsonList));
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<HistoryItem>>(
  (ref) => HistoryNotifier(),
);