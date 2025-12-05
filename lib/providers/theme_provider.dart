import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _load();
  }

  void set(ThemeMode mode) {
    state = mode;
    _persist();
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/theme.json');
  }

  Future<void> _persist() async {
    final f = await _file();
    await f.writeAsString(jsonEncode({'mode': state.index}));
  }

  Future<void> _load() async {
    try {
      final f = await _file();
      if (await f.exists()) {
        final data = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
        final idx = (data['mode'] as num).toInt();
        state = ThemeMode.values[idx];
      }
    } catch (_) {}
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier());