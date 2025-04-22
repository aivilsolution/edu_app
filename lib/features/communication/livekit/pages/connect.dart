import 'dart:convert';
import 'package:edu_app/features/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../pages/prejoin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import '../exts.dart';

class ConnectPage extends StatefulWidget {
  final String recipientId;

  final bool videoCall;

  const ConnectPage({
    super.key,
    required this.recipientId,
    required this.videoCall,
  });

  @override
  State<StatefulWidget> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  static const _storeKeyUri = 'uri';
  static const _storeKeyTokenServer = 'token-server';
  static const _storeKeySimulcast = 'simulcast';
  static const _storeKeyAdaptiveStream = 'adaptive-stream';
  static const _storeKeyDynacast = 'dynacast';
  static const _storeKeyE2EE = 'e2ee';
  static const _storeKeySharedKey = 'shared-key';
  static const _storeKeyMultiCodec = 'multi-codec';

  static const String defaultUrl = 'wss:
  static const _defaultTokenServer =
      'https:

  String _uri = defaultUrl;
  String _tokenServer = _defaultTokenServer;
  String _sharedKey = '';
  bool _simulcast = true;
  bool _adaptiveStream = true;
  bool _dynacast = true;
  bool _e2ee = false;
  bool _multiCodec = false;
  String _preferredCodec = 'VP8';
  bool _connecting = false;

  @override
  void initState() {
    super.initState();

    if (lkPlatformIs(PlatformType.android)) {
      _checkPermissions().then((_) => _loadPrefsAndConnect());
    } else {
      _loadPrefsAndConnect();
    }
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.bluetooth.request();
    if (status.isPermanentlyDenied) {
      print('Bluetooth Permission disabled');
    }

    status = await Permission.bluetoothConnect.request();
    if (status.isPermanentlyDenied) {
      print('Bluetooth Connect Permission disabled');
    }

    status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      print('Camera Permission disabled');
    }

    status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      print('Microphone Permission disabled');
    }
  }

  Future<void> _loadPrefsAndConnect() async {
    await _readPrefs();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _autoConnect();
      }
    });
  }

  Future<void> _readPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _uri =
        const bool.hasEnvironment('URL')
            ? const String.fromEnvironment('URL')
            : prefs.getString(_storeKeyUri) ?? defaultUrl;

    _tokenServer = prefs.getString(_storeKeyTokenServer) ?? _defaultTokenServer;

    _sharedKey =
        const bool.hasEnvironment('E2EEKEY')
            ? const String.fromEnvironment('E2EEKEY')
            : prefs.getString(_storeKeySharedKey) ?? '';

    _simulcast = prefs.getBool(_storeKeySimulcast) ?? true;
    _adaptiveStream = prefs.getBool(_storeKeyAdaptiveStream) ?? true;
    _dynacast = prefs.getBool(_storeKeyDynacast) ?? true;
    _e2ee = prefs.getBool(_storeKeyE2EE) ?? false;
    _multiCodec = prefs.getBool(_storeKeyMultiCodec) ?? false;
  }

  Future<void> _autoConnect() async {
    if (_connecting) return;
    _connecting = true;

    try {
      final authState = context.read<AuthBloc>().state;

      if (!authState.isAuthenticated || authState.user == null) {
        throw Exception('You must be logged in to start a call');
      }

      final String currentUserId = authState.user!.uid;
      final String identity = authState.user!.displayName ?? currentUserId;

      String recipientId;
      if (widget.recipientId != null &&
          widget.recipientId.toString().isNotEmpty) {
        recipientId = widget.recipientId.toString();
      } else {
        throw Exception('Recipient ID not provided');
      }

      final roomName = _generateRoomName(currentUserId, recipientId);

      final token = await _fetchToken(roomName, identity);

      print('Auto-connecting with url: $_uri');
      print('Room name: $roomName');
      print('Token length: ${token.length}');

      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => PreJoinPage(
                  videoCall: widget.videoCall,
                  args: JoinArgs(
                    url: _uri,
                    token: token,
                    e2ee: _e2ee,
                    e2eeKey: _sharedKey,
                    simulcast: _simulcast,
                    adaptiveStream: _adaptiveStream,
                    dynacast: _dynacast,
                    preferredCodec: _preferredCodec,
                    enableBackupVideoCodec: [
                      'VP9',
                      'AV1',
                    ].contains(_preferredCodec),
                  ),
                ),
          ),
        );
      }
    } catch (error) {
      print('Could not auto-connect: $error');
      if (mounted) {
        await context.showErrorDialog(error);
      }
      _connecting = false;
    }
  }

  String _generateRoomName(String currentUserId, String recipientId) {
    final sortedIds = [currentUserId, recipientId]..sort();

    final combinedIds = '${sortedIds[0]}_${sortedIds[1]}';

    final bytes = utf8.encode(combinedIds);
    final digest = sha256.convert(bytes);

    return 'room_${digest.toString().substring(0, 10)}';
  }

  Future<String> _fetchToken(String roomName, String identity) async {
    try {
      print('Fetching token from: $_tokenServer');
      print('Room: $roomName, Identity: $identity');

      final response = await http.post(
        Uri.parse(_tokenServer),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'roomName': roomName, 'identity': identity}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          return data['token'];
        } else {
          throw Exception('Token not found in response');
        }
      } else {
        throw Exception(
          'Failed to fetch token: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching token: $e');
      throw Exception('Error fetching token: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return const Center(child: CircularProgressIndicator());
      },
    ),
  );
}
