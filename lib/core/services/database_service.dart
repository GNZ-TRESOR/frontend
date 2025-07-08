import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/health_record_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ubuzima.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        role TEXT NOT NULL,
        facility_id TEXT,
        district TEXT,
        sector TEXT,
        cell TEXT,
        village TEXT,
        created_at TEXT NOT NULL,
        last_login_at TEXT,
        is_active INTEGER DEFAULT 1,
        profile_image_url TEXT,
        sync_status INTEGER DEFAULT 0
      )
    ''');

    // Health records table
    await db.execute('''
      CREATE TABLE health_records (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        health_worker_id TEXT NOT NULL,
        record_date TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        attachments TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_private INTEGER DEFAULT 0,
        status TEXT DEFAULT 'active',
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Menstrual cycles table
    await db.execute('''
      CREATE TABLE menstrual_cycles (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        cycle_length INTEGER NOT NULL,
        period_length INTEGER NOT NULL,
        flow_intensity TEXT NOT NULL,
        symptoms TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Medications table
    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        reminder_times TEXT,
        instructions TEXT,
        prescribed_by TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Appointments table
    await db.execute('''
      CREATE TABLE appointments (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        health_worker_id TEXT NOT NULL,
        facility_id TEXT NOT NULL,
        scheduled_date TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        type TEXT NOT NULL,
        status TEXT DEFAULT 'scheduled',
        reason TEXT,
        notes TEXT,
        diagnosis TEXT,
        prescriptions TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        cancel_reason TEXT,
        cancelled_at TEXT,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (client_id) REFERENCES users (id),
        FOREIGN KEY (health_worker_id) REFERENCES users (id)
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        sender_id TEXT NOT NULL,
        receiver_id TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT DEFAULT 'text',
        attachments TEXT,
        is_read INTEGER DEFAULT 0,
        sent_at TEXT NOT NULL,
        read_at TEXT,
        reply_to_id TEXT,
        is_encrypted INTEGER DEFAULT 0,
        priority TEXT DEFAULT 'normal',
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (sender_id) REFERENCES users (id),
        FOREIGN KEY (receiver_id) REFERENCES users (id)
      )
    ''');

    // Health facilities table
    await db.execute('''
      CREATE TABLE health_facilities (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        services TEXT,
        operating_hours TEXT,
        is_active INTEGER DEFAULT 1,
        rating REAL DEFAULT 0.0,
        review_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status INTEGER DEFAULT 0
      )
    ''');

    // Education progress table
    await db.execute('''
      CREATE TABLE education_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        lesson_id TEXT NOT NULL,
        progress_percentage INTEGER DEFAULT 0,
        time_spent_seconds INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0,
        completed_at TEXT,
        attempts INTEGER DEFAULT 0,
        quiz_results TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Sync queue table for offline operations
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_retry_at TEXT
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        read_at TEXT,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_health_records_user_id ON health_records (user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_health_records_date ON health_records (record_date)',
    );
    await db.execute(
      'CREATE INDEX idx_appointments_client_id ON appointments (client_id)',
    );
    await db.execute(
      'CREATE INDEX idx_appointments_health_worker_id ON appointments (health_worker_id)',
    );
    await db.execute(
      'CREATE INDEX idx_appointments_date ON appointments (scheduled_date)',
    );
    await db.execute(
      'CREATE INDEX idx_messages_sender_id ON messages (sender_id)',
    );
    await db.execute(
      'CREATE INDEX idx_messages_receiver_id ON messages (receiver_id)',
    );
    await db.execute('CREATE INDEX idx_messages_sent_at ON messages (sent_at)');
    await db.execute(
      'CREATE INDEX idx_sync_queue_table_record ON sync_queue (table_name, record_id)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    data['sync_status'] = 0; // Mark as needing sync
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    data['updated_at'] = DateTime.now().toIso8601String();
    data['sync_status'] = 0; // Mark as needing sync
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // User operations
  Future<void> saveUser(User user) async {
    final data = {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'role': user.role.name,
      'facility_id': user.facilityId,
      'district': user.district,
      'sector': user.sector,
      'cell': user.cell,
      'village': user.village,
      'created_at': user.createdAt.toIso8601String(),
      'last_login_at': user.lastLoginAt?.toIso8601String(),
      'is_active': user.isActive ? 1 : 0,
      'profile_image_url': user.profileImageUrl,
    };

    await insert('users', data);
  }

  Future<User?> getUser(String id) async {
    final results = await query('users', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;

    final data = results.first;
    return User(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      role: UserRole.values.firstWhere((e) => e.name == data['role']),
      facilityId: data['facility_id'],
      district: data['district'],
      sector: data['sector'],
      cell: data['cell'],
      village: data['village'],
      createdAt: DateTime.parse(data['created_at']),
      lastLoginAt:
          data['last_login_at'] != null
              ? DateTime.parse(data['last_login_at'])
              : null,
      isActive: data['is_active'] == 1,
      profileImageUrl: data['profile_image_url'],
    );
  }

  // Health record operations
  Future<void> saveHealthRecord(HealthRecord record) async {
    final data = {
      'id': record.id,
      'user_id': record.userId,
      'health_worker_id': record.healthWorkerId,
      'record_date': record.recordDate.toIso8601String(),
      'type': record.type.name,
      'data': jsonEncode(record.data),
      'attachments': jsonEncode(record.attachments),
      'notes': record.notes,
      'created_at': record.createdAt.toIso8601String(),
      'updated_at': record.updatedAt.toIso8601String(),
      'is_private': record.isConfidential ? 1 : 0,
      'status': 'active', // Default status
    };

    await insert('health_records', data);
  }

  Future<List<HealthRecord>> getHealthRecords(String userId) async {
    final results = await query(
      'health_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'record_date DESC',
    );

    return results
        .map(
          (data) => HealthRecord(
            id: data['id'],
            userId: data['user_id'],
            healthWorkerId: data['health_worker_id'],
            recordDate: DateTime.parse(data['record_date']),
            recordType: data['type'],
            type: HealthRecordType.values.firstWhere(
              (e) => e.name == data['type'],
            ),
            data: jsonDecode(data['data']),
            attachments: List<String>.from(
              jsonDecode(data['attachments'] ?? '[]'),
            ),
            notes: data['notes'],
            createdAt: DateTime.parse(data['created_at']),
            updatedAt: DateTime.parse(data['updated_at']),
            isConfidential: data['is_private'] == 1,
          ),
        )
        .toList();
  }

  // Sync operations
  Future<void> addToSyncQueue(
    String tableName,
    String recordId,
    String operation,
    Map<String, dynamic> data,
  ) async {
    final syncData = {
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': jsonEncode(data),
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    };

    await insert('sync_queue', syncData);
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    return await query('sync_queue', orderBy: 'created_at ASC');
  }

  Future<void> removeSyncItem(int id) async {
    await delete('sync_queue', 'id = ?', [id]);
  }

  Future<void> incrementSyncRetry(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE sync_queue SET retry_count = retry_count + 1, last_retry_at = ? WHERE id = ?',
      [DateTime.now().toIso8601String(), id],
    );
  }

  // Clear all data (for logout)
  Future<void> clearAllData() async {
    final db = await database;
    final tables = [
      'users',
      'health_records',
      'menstrual_cycles',
      'medications',
      'appointments',
      'messages',
      'health_facilities',
      'education_progress',
      'sync_queue',
      'notifications',
    ];

    for (final table in tables) {
      await db.delete(table);
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
