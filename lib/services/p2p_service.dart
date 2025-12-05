import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../providers/history_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class TransferProgress {
  final String fileName;
  final double progress;
  final double speedMbps;
  TransferProgress(this.fileName, this.progress, this.speedMbps);
}

class ConnectionStatus {
  final bool connected;
  final bool isHost;
  final String groupOwnerAddress;
  const ConnectionStatus({required this.connected, required this.isHost, required this.groupOwnerAddress});

  String get statusText => connected
      ? (isHost ? 'Hosting' : 'Connected to $groupOwnerAddress')
      : 'Waiting';
}

class P2pState {}

class PeerInfo {
  final String name;
  final String? address;
  final bool isHost;
  PeerInfo(this.name, this.address, this.isHost);
}

class P2pService {
  final List<StreamSubscription> _subs = [];
  List<PeerInfo> _peers = [];
  PeerInfo? _self;
  RawDatagramSocket? _udp;
  ServerSocket? _tcpServer;
  void Function(TransferProgress)? _onProgress;
  Directory? _saveDir;
  String? _selectedAddress;
  final int _discoveryPort = 40405;
  final int _transferPort = 8989;

  Future<void> initialize() async {
    await _ensurePermissions();
    _peers = [];
  }

  Future<void> _ensurePermissions() async {
    final permissions = [
      Permission.location,
      Permission.nearbyWifiDevices, // Android 13+
    ];
    for (final p in permissions) {
      if (!await p.isGranted) {
        await p.request();
      }
    }
  }

  Future<List<PeerInfo>> discoverPeers() async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    final data = utf8.encode('DISCOVER');
    socket.broadcastEnabled = true;
    socket.send(data, InternetAddress('255.255.255.255'), _discoveryPort);
    final found = <PeerInfo>[];
    final completer = Completer<List<PeerInfo>>();
    Timer(const Duration(milliseconds: 1500), () {
      socket.close();
      completer.complete(found);
    });
    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = socket.receive();
        if (dg == null) return;
        final msg = utf8.decode(dg.data);
        try {
          final m = jsonDecode(msg) as Map<String, dynamic>;
          final name = m['name'] as String? ?? 'Peer';
          final addr = dg.address.address;
          final peer = PeerInfo(name, addr, m['isHost'] as bool? ?? false);
          if (!found.any((p) => p.address == addr)) {
            found.add(peer);
          }
        } catch (_) {}
      }
    });
    _peers = await completer.future;
    return _peers;
  }

  Future<void> connect(PeerInfo device) async {
    _selectedAddress = device.address;
  }

  Future<void> startHost(int port) async {
    _self = PeerInfo('Host', null, true);
    _udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _discoveryPort);
    _udp!.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = _udp!.receive();
        if (dg == null) return;
        final msg = utf8.decode(dg.data);
        if (msg == 'DISCOVER') {
          final reply = jsonEncode({'name': 'ShareNow', 'isHost': true});
          _udp!.send(utf8.encode(reply), dg.address, dg.port);
        }
      }
    });
    _tcpServer = await ServerSocket.bind(InternetAddress.anyIPv4, _transferPort);
    _tcpServer!.listen(_handleIncomingClient);
  }

  Future<void> connectToHost(String address, int port) async {}

  ConnectionStatus get status {
    final connected = _self != null;
    final isHost = _self?.isHost ?? false;
    final addr = _self?.address ?? '';
    return ConnectionStatus(connected: connected, isHost: isHost, groupOwnerAddress: addr);
  }

  Future<void> sendFile(File file, {String? aesKey}) async {
    final addr = _selectedAddress;
    if (addr == null) return;
    final socket = await Socket.connect(addr, _transferPort);
    final name = file.uri.pathSegments.last;
    final size = await file.length();
    final header = '$name|$size\n';
    socket.add(utf8.encode(header));
    await for (final chunk in file.openRead()) {
      socket.add(chunk);
    }
    await socket.flush();
    await socket.close();
  }

  Future<void> acceptAndSaveTo(Directory dir, void Function(TransferProgress) onProgress) async {
    _saveDir = dir;
    _onProgress = onProgress;
  }

  void _handleIncomingClient(Socket client) async {
    final dir = _saveDir ?? await getApplicationDocumentsDirectory();
    final sinkCompleter = Completer<IOSink>();
    String? name;
    int expected = 0;
    int received = 0;
    DateTime start = DateTime.now();
    client.listen((data) async {
      if (name == null) {
        final idx = data.indexOf(10);
        if (idx != -1) {
          final meta = utf8.decode(data.sublist(0, idx));
          final parts = meta.split('|');
          name = parts[0];
          expected = int.parse(parts[1]);
          final file = File('${dir.path}/$name');
          final sink = file.openWrite();
          sinkCompleter.complete(sink);
          final rem = data.sublist(idx + 1);
          if (rem.isNotEmpty) {
            sink.add(rem);
            received += rem.length;
          }
        }
      } else {
        final sink = await sinkCompleter.future;
        sink.add(data);
        received += data.length;
      }
      final seconds = DateTime.now().difference(start).inMilliseconds / 1000.0;
      final speed = seconds > 0 ? (received.toDouble() / (1024 * 1024)) / seconds : 0.0;
      final progress = expected > 0 ? (received.toDouble() / expected.toDouble()) * 100.0 : 0.0;
      _onProgress?.call(TransferProgress(name ?? '', progress.clamp(0.0, 100.0), speed));
      if (expected > 0 && received >= expected) {
        final sink = await sinkCompleter.future;
        await sink.flush();
        await sink.close();
        await client.close();
      }
    });
  }

  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _udp?.close();
    _tcpServer?.close();
  }
}

class P2pController extends StateNotifier<P2pState> {
  final P2pService _service;
  P2pController(this._service) : super(P2pState()) {
    _service.initialize();
  }

  ConnectionStatus get connectionStatus => _service.status;
  final List<TransferProgress> activeTransfers = [];

  Future<void> startDiscovery() async {
    await _service.discoverPeers();
  }

  Future<List<PeerInfo>> getPeers() async {
    return _service.discoverPeers();
  }

  Future<void> connectToDevice(PeerInfo device) async {
    await _service.connect(device);
  }

  Future<void> startAsHost() async {
    await _service.startHost(8989);
  }

  Future<void> sendFiles(List<File> files) async {
    for (final f in files) {
      await _service.sendFile(f);
    }
  }

  Future<void> acceptIncoming(WidgetRef ref) async {
    final dir = await getApplicationDocumentsDirectory();
    await _service.acceptAndSaveTo(Directory(dir.path), (p) {
      final idx = activeTransfers.indexWhere((e) => e.fileName == p.fileName);
      if (idx == -1) {
        activeTransfers.insert(0, p);
      } else {
        activeTransfers[idx] = p;
      }
      if (p.progress >= 100) {
        ref.read(historyProvider.notifier).add(File('${dir.path}/${p.fileName}'));
      }
    });
  }
}
