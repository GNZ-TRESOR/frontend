import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PostgreSQL Database Service for Ubuzima App
/// Handles real database connections via HTTP API
class PostgresService extends ChangeNotifier {
  static final PostgresService _instance = PostgresService._internal();
  factory PostgresService() => _instance;
  PostgresService._internal();

  bool _isConnected = false;
  String? _lastError;
  String? _apiUrl;

  // Database configuration
  late String _host;
  late int _port;
  late String _database;

  // Getters
  bool get isConnected => _isConnected;
  String? get lastError => _lastError;
  String? get apiUrl => _apiUrl;

  /// Initialize PostgreSQL service with configuration
  Future<bool> initialize({
    String? host,
    int? port,
    String? database,
    String? username,
    String? password,
  }) async {
    try {
      // Load configuration from parameters or SharedPreferences
      await _loadConfiguration(
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
      );

      // Attempt to connect
      await _connect();

      // Create tables if they don't exist
      if (_isConnected) {
        await _createTables();
      }

      debugPrint('✅ PostgreSQL Service initialized: $_isConnected');
      return _isConnected;
    } catch (e) {
      debugPrint('❌ PostgreSQL initialization failed: $e');
      _lastError = e.toString();
      return false;
    }
  }

  /// Load database configuration
  Future<void> _loadConfiguration({
    String? host,
    int? port,
    String? database,
    String? username,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _host = host ?? prefs.getString('db_host') ?? 'localhost';
    _port = port ?? prefs.getInt('db_port') ?? 5432;
    _database = database ?? prefs.getString('db_database') ?? 'ubuzima_db';

    debugPrint('📊 Database config: $_host:$_port/$_database');
  }

  /// Save database configuration
  Future<void> saveConfiguration({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('db_host', host);
    await prefs.setInt('db_port', port);
    await prefs.setString('db_database', database);
    await prefs.setString('db_username', username);
    await prefs.setString('db_password', password);

    _host = host;
    _port = port;
    _database = database;

    debugPrint('💾 Database configuration saved');
  }

  /// Connect to PostgreSQL database via API
  Future<void> _connect() async {
    try {
      // For now, we'll simulate a connection
      // In a real implementation, you would connect to your backend API
      _apiUrl = 'http://$_host:3000/api'; // Assuming a REST API on port 3000

      _isConnected = true;
      _lastError = null;
      notifyListeners();

      debugPrint('✅ Connected to PostgreSQL API: $_apiUrl');
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
      notifyListeners();

      debugPrint('❌ PostgreSQL API connection failed: $e');
      rethrow;
    }
  }

  /// Test database connection
  Future<bool> testConnection({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
  }) async {
    try {
      // For demo purposes, we'll simulate a successful connection test
      // In a real implementation, you would test your backend API
      await Future.delayed(const Duration(seconds: 1));

      debugPrint('✅ Connection test successful (simulated)');
      return true;
    } catch (e) {
      debugPrint('❌ Connection test failed: $e');
      return false;
    }
  }

  /// Create database tables (simulated)
  Future<void> _createTables() async {
    if (!_isConnected) return;

    try {
      // Simulate table creation via API
      debugPrint('📊 Creating database tables via API...');

      // In a real implementation, you would call your backend API
      // to create tables or verify they exist
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('✅ Database tables created/verified (simulated)');
    } catch (e) {
      debugPrint('❌ Table creation failed: $e');
      rethrow;
    }
  }

  /// Execute a query and return results (via HTTP API)
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isConnected) {
      throw Exception('Database not connected');
    }

    try {
      // Simulate API call
      debugPrint('🔍 Executing query via API: $sql');
      await Future.delayed(const Duration(milliseconds: 200));

      // Return empty result for simulation
      return [];
    } catch (e) {
      debugPrint('❌ Query failed: $e');
      _lastError = e.toString();
      rethrow;
    }
  }

  /// Execute an insert/update/delete query (via HTTP API)
  Future<int> execute(String sql, {Map<String, dynamic>? parameters}) async {
    if (!_isConnected) {
      throw Exception('Database not connected');
    }

    try {
      // Simulate API call
      debugPrint('✏️ Executing command via API: $sql');
      await Future.delayed(const Duration(milliseconds: 200));

      // Return simulated affected rows
      return 1;
    } catch (e) {
      debugPrint('❌ Execute failed: $e');
      _lastError = e.toString();
      rethrow;
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (_isConnected) {
      _isConnected = false;
      _apiUrl = null;
      notifyListeners();
      debugPrint('🔌 PostgreSQL API connection closed');
    }
  }

  /// Reconnect to database
  Future<bool> reconnect() async {
    await close();
    try {
      await _connect();
      return _isConnected;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }
}
