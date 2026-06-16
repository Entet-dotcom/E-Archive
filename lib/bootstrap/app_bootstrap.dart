import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../core/constants/app_theme.dart';
import '../core/database/api_unavailable_exception.dart';
import '../core/database/app_database.dart';
import '../core/server/api_server_launcher.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  var _ready = false;
  var _connecting = true;
  var _statusMessage = 'Starting API server…';
  String? _error;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _error = null;
      _statusMessage = 'Starting API server…';
    });

    try {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        if (!mounted) return;
        setState(() => _statusMessage = 'Starting API server…');
        await ApiServerLauncher.ensureRunning(
          onStatus: (message) {
            if (!mounted) return;
            setState(() => _statusMessage = message);
          },
        );
      }
      if (!mounted) return;
      setState(() => _statusMessage = 'Connecting to database API…');
      await AppDatabase.instance.ensureInitialized();
      if (!mounted) return;
      setState(() {
        _ready = true;
        _connecting = false;
      });
    } on ApiUnavailableException catch (e) {
      if (!mounted) return;
      setState(() {
        _ready = false;
        _connecting = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ready = false;
        _connecting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return const EArchiveApp();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Archive',
      theme: AppTheme.darkTheme,
      builder: AppTheme.poppinsBuilder,
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _connecting
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 56,
                          color: Color(0xFFF87171),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'API server not running',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error ?? 'Unknown error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            height: 1.5,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 28),
                        FilledButton.icon(
                          onPressed: _connect,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
