#!/usr/bin/env dart

/// Comprehensive Integration Testing Script for Ubuzima App
/// This script helps test the frontend-backend integration

import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  print('🧪 Ubuzima Integration Testing Script');
  print('=====================================\n');

  // Check if backend is running
  await checkBackendStatus();
  
  // Run Flutter tests
  await runFlutterTests();
  
  // Test API endpoints
  await testApiEndpoints();
  
  // Generate test report
  generateTestReport();
}

/// Check if the Spring Boot backend is running
Future<void> checkBackendStatus() async {
  print('🔍 Checking Backend Status...');
  
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:8080/actuator/health'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      print('✅ Backend is running on http://localhost:8080');
    } else {
      print('❌ Backend returned status code: ${response.statusCode}');
    }
    
    client.close();
  } catch (e) {
    print('❌ Backend is not running or not accessible');
    print('   Please start your Spring Boot backend first:');
    print('   cd backend/ubuzima-backend && ./mvnw spring-boot:run');
    print('');
  }
}

/// Run Flutter tests
Future<void> runFlutterTests() async {
  print('🧪 Running Flutter Tests...');
  
  try {
    // Run widget tests
    final result = await Process.run('flutter', ['test']);
    
    if (result.exitCode == 0) {
      print('✅ All Flutter tests passed');
    } else {
      print('❌ Some Flutter tests failed');
      print(result.stdout);
      print(result.stderr);
    }
  } catch (e) {
    print('❌ Error running Flutter tests: $e');
  }
}

/// Test API endpoints
Future<void> testApiEndpoints() async {
  print('🌐 Testing API Endpoints...');
  
  final endpoints = [
    {'method': 'GET', 'url': '/actuator/health', 'description': 'Health Check'},
    {'method': 'POST', 'url': '/api/v1/auth/login', 'description': 'Login Endpoint'},
    {'method': 'GET', 'url': '/api/v1/health-records', 'description': 'Health Records'},
    {'method': 'GET', 'url': '/api/v1/menstrual-cycles', 'description': 'Menstrual Cycles'},
    {'method': 'GET', 'url': '/api/v1/medications', 'description': 'Medications'},
    {'method': 'GET', 'url': '/api/v1/appointments', 'description': 'Appointments'},
  ];
  
  final client = HttpClient();
  
  for (final endpoint in endpoints) {
    try {
      final uri = Uri.parse('http://localhost:8080${endpoint['url']}');
      
      HttpClientRequest request;
      if (endpoint['method'] == 'GET') {
        request = await client.getUrl(uri);
      } else {
        request = await client.postUrl(uri);
        request.headers.contentType = ContentType.json;
      }
      
      final response = await request.close();
      
      if (response.statusCode < 400) {
        print('✅ ${endpoint['description']}: ${response.statusCode}');
      } else {
        print('❌ ${endpoint['description']}: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ${endpoint['description']}: Error - $e');
    }
  }
  
  client.close();
}

/// Generate test report
void generateTestReport() {
  print('\n📊 Test Report Generated');
  print('========================');
  print('');
  print('✅ Integration Testing Complete!');
  print('');
  print('📋 Next Steps:');
  print('1. If backend is not running, start it first');
  print('2. Run the Flutter app: flutter run');
  print('3. Test with different user roles');
  print('4. Verify CRUD operations work');
  print('5. Check error handling');
  print('');
  print('🔗 Test User Accounts:');
  print('   Admin: admin@ubuzima.com / password123');
  print('   Health Worker: doctor@ubuzima.com / password123');
  print('   Client: user@ubuzima.com / password123');
  print('');
  print('📱 To run the app:');
  print('   flutter run');
  print('   # Or for Android emulator:');
  print('   flutter run -d android');
  print('');
}
