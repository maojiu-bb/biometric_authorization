import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:biometric_authorization/biometric_authorization.dart';
import 'package:biometric_authorization/biometric_type.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool _isBiometricAvailable = false;
  bool _isBiometricEnrolled = false;
  List<BiometricType> _availableBiometricTypes = [];
  bool _isAuthenticated = false;
  final _biometricAuthorizationPlugin = BiometricAuthorization();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    bool isBiometricAvailable;
    bool isBiometricEnrolled;
    List<BiometricType> availableBiometricTypes;

    try {
      platformVersion =
          await _biometricAuthorizationPlugin.getPlatformVersion() ??
          'Unknown platform version';
      isBiometricAvailable =
          await _biometricAuthorizationPlugin.isBiometricAvailable();
      isBiometricEnrolled =
          await _biometricAuthorizationPlugin.isBiometricEnrolled();
      availableBiometricTypes =
          await _biometricAuthorizationPlugin.getAvailableBiometricTypes();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
      isBiometricAvailable = false;
      isBiometricEnrolled = false;
      availableBiometricTypes = [];
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _isBiometricAvailable = isBiometricAvailable;
      _isBiometricEnrolled = isBiometricEnrolled;
      _availableBiometricTypes = availableBiometricTypes;
    });
  }

  Future<void> _authenticate({required bool useCustomUI}) async {
    if (_availableBiometricTypes.isEmpty ||
        _availableBiometricTypes.first == BiometricType.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No biometric authentication available')),
      );
      return;
    }

    try {
      final bool result = await _biometricAuthorizationPlugin.authenticate(
        biometricType: _availableBiometricTypes.first,
        reason: 'Please authenticate to continue',
        title: 'Biometric Authentication',
        confirmText: 'Authenticate',
        useCustomUI: useCustomUI,
      );

      setState(() {
        _isAuthenticated = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result ? 'Authentication successful' : 'Authentication failed',
          ),
          backgroundColor: result ? Colors.green : Colors.red,
        ),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Biometric Authorization Example'),
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Device Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InfoRow(label: 'Platform', value: _platformVersion),
                      InfoRow(
                        label: 'Biometric Available',
                        value: _isBiometricAvailable ? 'Yes' : 'No',
                      ),
                      InfoRow(
                        label: 'Biometric Enrolled',
                        value: _isBiometricEnrolled ? 'Yes' : 'No',
                      ),
                      InfoRow(
                        label: 'Available Biometrics',
                        value:
                            _availableBiometricTypes.isEmpty
                                ? 'None'
                                : _availableBiometricTypes
                                    .map((type) => type.name)
                                    .join(', '),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Authentication Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _isAuthenticated
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isAuthenticated
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  _isAuthenticated ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isAuthenticated
                                  ? 'Authenticated'
                                  : 'Not Authenticated',
                              style: TextStyle(
                                color:
                                    _isAuthenticated
                                        ? Colors.green.shade900
                                        : Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Test Authentication',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isBiometricAvailable && _isBiometricEnrolled
                              ? () => _authenticate(useCustomUI: false)
                              : null,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Standard UI'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isBiometricAvailable && _isBiometricEnrolled
                              ? () => _authenticate(useCustomUI: true)
                              : null,
                      icon: const Icon(Icons.face),
                      label: const Text('Custom UI'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: initPlatformState,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
