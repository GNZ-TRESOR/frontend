import 'package:flutter/foundation.dart';
import 'postgres_service.dart';
import '../models/user.dart';
import '../models/health_record.dart';
import '../models/appointment.dart';

/// Real Data Service for Ubuzima App
/// Handles CRUD operations with PostgreSQL database
class RealDataService extends ChangeNotifier {
  static final RealDataService _instance = RealDataService._internal();
  factory RealDataService() => _instance;
  RealDataService._internal();

  final PostgresService _postgresService = PostgresService();

  bool get isConnected => _postgresService.isConnected;
  String? get lastError => _postgresService.lastError;

  /// Initialize the service
  Future<bool> initialize() async {
    try {
      return await _postgresService.initialize();
    } catch (e) {
      debugPrint('❌ Real Data Service initialization failed: $e');
      return false;
    }
  }

  // ==================== USER OPERATIONS ====================

  /// Create a new user
  Future<User?> createUser(User user) async {
    try {
      final result = await _postgresService.query(
        '''
        INSERT INTO users (uuid, name, email, phone, role, date_of_birth, gender, location)
        VALUES (@uuid, @name, @email, @phone, @role, @dateOfBirth, @gender, @location)
        RETURNING *
        ''',
        parameters: {
          'uuid': user.uuid,
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'role': user.role.toString().split('.').last,
          'dateOfBirth': user.dateOfBirth?.toIso8601String(),
          'gender': user.gender,
          'location': user.location,
        },
      );

      if (result.isNotEmpty) {
        return User.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Create user failed: $e');
      return null;
    }
  }

  /// Get user by UUID
  Future<User?> getUserByUuid(String uuid) async {
    try {
      final result = await _postgresService.query(
        'SELECT * FROM users WHERE uuid = @uuid',
        parameters: {'uuid': uuid},
      );

      if (result.isNotEmpty) {
        return User.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get user failed: $e');
      return null;
    }
  }

  /// Update user
  Future<User?> updateUser(User user) async {
    try {
      final result = await _postgresService.query(
        '''
        UPDATE users 
        SET name = @name, email = @email, phone = @phone, 
            date_of_birth = @dateOfBirth, gender = @gender, 
            location = @location, updated_at = CURRENT_TIMESTAMP
        WHERE uuid = @uuid
        RETURNING *
        ''',
        parameters: {
          'uuid': user.uuid,
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'dateOfBirth': user.dateOfBirth?.toIso8601String(),
          'gender': user.gender,
          'location': user.location,
        },
      );

      if (result.isNotEmpty) {
        return User.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Update user failed: $e');
      return null;
    }
  }

  // ==================== HEALTH RECORD OPERATIONS ====================

  /// Create health record
  Future<HealthRecord?> createHealthRecord(HealthRecord record) async {
    try {
      final result = await _postgresService.query(
        '''
        INSERT INTO health_records (user_id, record_type, date, weight, 
                                   blood_pressure_systolic, blood_pressure_diastolic, 
                                   temperature, notes)
        VALUES ((SELECT id FROM users WHERE uuid = @userUuid), @recordType, @date, 
                @weight, @bloodPressureSystolic, @bloodPressureDiastolic, 
                @temperature, @notes)
        RETURNING *
        ''',
        parameters: {
          'userUuid': record.userId.toString(), // Assuming userId is actually UUID
          'recordType': record.recordType,
          'date': record.date.toIso8601String(),
          'weight': record.weight,
          'bloodPressureSystolic': record.bloodPressureSystolic,
          'bloodPressureDiastolic': record.bloodPressureDiastolic,
          'temperature': record.temperature,
          'notes': record.notes,
        },
      );

      if (result.isNotEmpty) {
        return HealthRecord.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Create health record failed: $e');
      return null;
    }
  }

  /// Get health records for user
  Future<List<HealthRecord>> getHealthRecords(String userUuid, {
    String? recordType,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      String query = '''
        SELECT hr.* FROM health_records hr
        JOIN users u ON hr.user_id = u.id
        WHERE u.uuid = @userUuid
      ''';
      
      Map<String, dynamic> parameters = {'userUuid': userUuid};

      if (recordType != null) {
        query += ' AND hr.record_type = @recordType';
        parameters['recordType'] = recordType;
      }

      if (startDate != null) {
        query += ' AND hr.date >= @startDate';
        parameters['startDate'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        query += ' AND hr.date <= @endDate';
        parameters['endDate'] = endDate.toIso8601String();
      }

      query += ' ORDER BY hr.date DESC';

      if (limit != null) {
        query += ' LIMIT @limit';
        parameters['limit'] = limit;
      }

      final result = await _postgresService.query(query, parameters: parameters);
      
      return result.map((json) => HealthRecord.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Get health records failed: $e');
      return [];
    }
  }

  /// Update health record
  Future<HealthRecord?> updateHealthRecord(HealthRecord record) async {
    try {
      final result = await _postgresService.query(
        '''
        UPDATE health_records 
        SET record_type = @recordType, date = @date, weight = @weight,
            blood_pressure_systolic = @bloodPressureSystolic,
            blood_pressure_diastolic = @bloodPressureDiastolic,
            temperature = @temperature, notes = @notes
        WHERE id = @id
        RETURNING *
        ''',
        parameters: {
          'id': record.id,
          'recordType': record.recordType,
          'date': record.date.toIso8601String(),
          'weight': record.weight,
          'bloodPressureSystolic': record.bloodPressureSystolic,
          'bloodPressureDiastolic': record.bloodPressureDiastolic,
          'temperature': record.temperature,
          'notes': record.notes,
        },
      );

      if (result.isNotEmpty) {
        return HealthRecord.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Update health record failed: $e');
      return null;
    }
  }

  /// Delete health record
  Future<bool> deleteHealthRecord(int recordId) async {
    try {
      final affectedRows = await _postgresService.execute(
        'DELETE FROM health_records WHERE id = @id',
        parameters: {'id': recordId},
      );
      return affectedRows > 0;
    } catch (e) {
      debugPrint('❌ Delete health record failed: $e');
      return false;
    }
  }

  // ==================== APPOINTMENT OPERATIONS ====================

  /// Create appointment
  Future<Appointment?> createAppointment(Appointment appointment) async {
    try {
      final result = await _postgresService.query(
        '''
        INSERT INTO appointments (client_id, health_worker_id, appointment_date, 
                                 type, status, notes)
        VALUES ((SELECT id FROM users WHERE uuid = @clientUuid),
                (SELECT id FROM users WHERE uuid = @healthWorkerUuid),
                @appointmentDate, @type, @status, @notes)
        RETURNING *
        ''',
        parameters: {
          'clientUuid': appointment.clientId.toString(),
          'healthWorkerUuid': appointment.healthWorkerId.toString(),
          'appointmentDate': appointment.appointmentDate.toIso8601String(),
          'type': appointment.type,
          'status': appointment.status,
          'notes': appointment.notes,
        },
      );

      if (result.isNotEmpty) {
        return Appointment.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Create appointment failed: $e');
      return null;
    }
  }

  /// Get appointments for user
  Future<List<Appointment>> getAppointments(String userUuid, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String query = '''
        SELECT a.* FROM appointments a
        JOIN users client ON a.client_id = client.id
        LEFT JOIN users hw ON a.health_worker_id = hw.id
        WHERE client.uuid = @userUuid OR hw.uuid = @userUuid
      ''';
      
      Map<String, dynamic> parameters = {'userUuid': userUuid};

      if (status != null) {
        query += ' AND a.status = @status';
        parameters['status'] = status;
      }

      if (startDate != null) {
        query += ' AND a.appointment_date >= @startDate';
        parameters['startDate'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        query += ' AND a.appointment_date <= @endDate';
        parameters['endDate'] = endDate.toIso8601String();
      }

      query += ' ORDER BY a.appointment_date ASC';

      final result = await _postgresService.query(query, parameters: parameters);
      
      return result.map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Get appointments failed: $e');
      return [];
    }
  }

  /// Update appointment
  Future<Appointment?> updateAppointment(Appointment appointment) async {
    try {
      final result = await _postgresService.query(
        '''
        UPDATE appointments 
        SET appointment_date = @appointmentDate, type = @type, 
            status = @status, notes = @notes
        WHERE id = @id
        RETURNING *
        ''',
        parameters: {
          'id': appointment.id,
          'appointmentDate': appointment.appointmentDate.toIso8601String(),
          'type': appointment.type,
          'status': appointment.status,
          'notes': appointment.notes,
        },
      );

      if (result.isNotEmpty) {
        return Appointment.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Update appointment failed: $e');
      return null;
    }
  }

  /// Delete appointment
  Future<bool> deleteAppointment(int appointmentId) async {
    try {
      final affectedRows = await _postgresService.execute(
        'DELETE FROM appointments WHERE id = @id',
        parameters: {'id': appointmentId},
      );
      return affectedRows > 0;
    } catch (e) {
      debugPrint('❌ Delete appointment failed: $e');
      return false;
    }
  }

  // ==================== ANALYTICS & REPORTS ====================

  /// Get health statistics for user
  Future<Map<String, dynamic>> getHealthStatistics(String userUuid) async {
    try {
      final result = await _postgresService.query(
        '''
        SELECT 
          COUNT(*) as total_records,
          COUNT(CASE WHEN record_type = 'weight' THEN 1 END) as weight_records,
          COUNT(CASE WHEN record_type = 'blood_pressure' THEN 1 END) as bp_records,
          COUNT(CASE WHEN record_type = 'temperature' THEN 1 END) as temp_records,
          AVG(CASE WHEN record_type = 'weight' THEN weight END) as avg_weight,
          MAX(date) as last_record_date
        FROM health_records hr
        JOIN users u ON hr.user_id = u.id
        WHERE u.uuid = @userUuid
        ''',
        parameters: {'userUuid': userUuid},
      );

      return result.isNotEmpty ? result.first : {};
    } catch (e) {
      debugPrint('❌ Get health statistics failed: $e');
      return {};
    }
  }

  /// Sync data with local database
  Future<void> syncWithLocal() async {
    // TODO: Implement sync with local SQLite database
    debugPrint('🔄 Syncing with local database...');
    notifyListeners();
  }
}
