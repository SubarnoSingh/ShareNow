import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/p2p_service.dart';

final p2pServiceProvider = Provider<P2pService>((ref) {
  final service = P2pService();
  ref.onDispose(service.dispose);
  return service;
});

final p2pControllerProvider = StateNotifierProvider<P2pController, P2pState>((ref) {
  final service = ref.read(p2pServiceProvider);
  return P2pController(service);
});

class PeersNotifier extends StateNotifier<List<PeerInfo>> {
  PeersNotifier() : super(const []);
  void setPeers(List<PeerInfo> peers) => state = peers;
  void clear() => state = const [];
}

final peersListProvider = StateNotifierProvider<PeersNotifier, List<PeerInfo>>(
  (ref) => PeersNotifier(),
);

final selectedFilesProvider = StateProvider<List<File>?>(
  (ref) => null,
);

final connectionStatusProvider = Provider<ConnectionStatus>((ref) {
  return ref.read(p2pControllerProvider.notifier).connectionStatus;
});

final activeTransfersProvider = Provider<List<TransferProgress>>((ref) {
  return ref.read(p2pControllerProvider.notifier).activeTransfers;
});
