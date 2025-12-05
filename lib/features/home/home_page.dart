import 'package:flutter/material.dart';
import '../../providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../send/send_page.dart';
import '../receive/receive_page.dart';
import '../history/history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [SendPage(), ReceivePage(), HistoryPage()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShareNow'),
        actions: const [
          _ThemeToggleButton(),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.send), label: 'Send'),
          NavigationDestination(icon: Icon(Icons.download), label: 'Receive'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _ThemeToggleButton extends ConsumerWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeProvider);
    return IconButton(
      tooltip: 'Toggle theme',
      icon: Icon(mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
      onPressed: () {
        final notifier = ref.read(themeProvider.notifier);
        switch (mode) {
          case ThemeMode.light:
            notifier.set(ThemeMode.dark);
            break;
          case ThemeMode.dark:
            notifier.set(ThemeMode.system);
            break;
          case ThemeMode.system:
            notifier.set(ThemeMode.light);
            break;
        }
      },
    );
  }
}