import 'dart:io';
import 'package:flutter/foundation.dart';

/// Network utilities for dynamic IP detection and configuration
class NetworkUtils {
  static String? _cachedHostIP;
  static DateTime? _lastIPCheck;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Get the host machine's IP address dynamically
  static Future<String?> getHostIP() async {
    try {
      // Return cached IP if still valid
      if (_cachedHostIP != null && 
          _lastIPCheck != null && 
          DateTime.now().difference(_lastIPCheck!) < _cacheExpiry) {
        return _cachedHostIP;
      }

      // Get all network interfaces
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      String? bestIP;
      
      // Prioritize WiFi interfaces
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          final ip = addr.address;
          
          // Skip loopback and invalid addresses
          if (ip.startsWith('127.') || ip.startsWith('169.254.')) {
            continue;
          }
          
          // Prefer common home network ranges
          if (ip.startsWith('192.168.') || 
              ip.startsWith('10.') || 
              ip.startsWith('172.')) {
            
            // Prioritize WiFi interfaces (usually contain 'Wi-Fi' or 'wlan')
            if (interface.name.toLowerCase().contains('wi-fi') ||
                interface.name.toLowerCase().contains('wlan') ||
                interface.name.toLowerCase().contains('wireless')) {
              bestIP = ip;
              break;
            } else if (bestIP == null) {
              bestIP = ip;
            }
          }
        }
        if (bestIP != null && interface.name.toLowerCase().contains('wi-fi')) {
          break; // Found WiFi interface, use it
        }
      }

      _cachedHostIP = bestIP;
      _lastIPCheck = DateTime.now();
      
      if (bestIP != null) {
        debugPrint('🌐 Detected host IP: $bestIP');
      } else {
        debugPrint('⚠️ Could not detect host IP, using fallback');
      }
      
      return bestIP;
    } catch (e) {
      debugPrint('❌ Error detecting host IP: $e');
      return null;
    }
  }

  /// Get dynamic API base URL with automatic IP detection
  static Future<String> getDynamicApiUrl({
    int port = 8080,
    String path = '/api/v1',
    String? fallbackIP,
  }) async {
    try {
      final hostIP = await getHostIP();
      
      if (hostIP != null) {
        return 'http://$hostIP:$port$path';
      } else if (fallbackIP != null) {
        debugPrint('🔄 Using fallback IP: $fallbackIP');
        return 'http://$fallbackIP:$port$path';
      } else {
        // Last resort - use Android emulator default
        debugPrint('🔄 Using Android emulator default: 10.0.2.2');
        return 'http://10.0.2.2:$port$path';
      }
    } catch (e) {
      debugPrint('❌ Error getting dynamic API URL: $e');
      return 'http://10.0.2.2:$port$path';
    }
  }

  /// Test connectivity to a given URL
  static Future<bool> testConnectivity(String url) async {
    try {
      final uri = Uri.parse(url);
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      
      final request = await client.getUrl(uri);
      final response = await request.close();
      
      client.close();
      return response.statusCode < 500; // Accept any non-server error
    } catch (e) {
      debugPrint('❌ Connectivity test failed for $url: $e');
      return false;
    }
  }

  /// Find the best working API URL from multiple options
  static Future<String> findBestApiUrl({
    int port = 8080,
    String path = '/api/v1',
    List<String>? fallbackIPs,
  }) async {
    final candidates = <String>[];
    
    // Add dynamic IP
    final dynamicUrl = await getDynamicApiUrl(port: port, path: path);
    candidates.add(dynamicUrl);
    
    // Add fallback IPs
    if (fallbackIPs != null) {
      for (final ip in fallbackIPs) {
        candidates.add('http://$ip:$port$path');
      }
    }
    
    // Add common defaults
    candidates.addAll([
      'http://10.0.2.2:$port$path', // Android emulator
      'http://localhost:$port$path', // Local development
    ]);
    
    // Test each candidate
    for (final url in candidates) {
      debugPrint('🔍 Testing connectivity to: $url');
      if (await testConnectivity(url)) {
        debugPrint('✅ Found working API URL: $url');
        return url;
      }
    }
    
    // Return first candidate as fallback
    debugPrint('⚠️ No working API URL found, using first candidate');
    return candidates.first;
  }

  /// Clear cached IP (force refresh on next call)
  static void clearCache() {
    _cachedHostIP = null;
    _lastIPCheck = null;
  }

  /// Get network interface information for debugging
  static Future<Map<String, dynamic>> getNetworkInfo() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: true,
        type: InternetAddressType.IPv4,
      );
      
      final info = <String, dynamic>{
        'interfaces': [],
        'hostIP': await getHostIP(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      for (final interface in interfaces) {
        final interfaceInfo = {
          'name': interface.name,
          'addresses': interface.addresses.map((addr) => addr.address).toList(),
        };
        info['interfaces'].add(interfaceInfo);
      }
      
      return info;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
