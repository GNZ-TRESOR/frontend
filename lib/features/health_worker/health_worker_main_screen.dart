import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/loading_overlay.dart';
import '../messages/conversation_detail_screen.dart';
import 'health_worker_reports_screen.dart';
import 'time_slots_management_screen.dart';
import 'support_groups_management_screen.dart';
import 'sti_test_records_screen.dart';
import 'side_effect_reports_screen.dart';
import 'community_events_screen.dart';
import 'add_client_screen.dart';

/// Clean, unified Health Worker Main Screen
/// Uses only working backend APIs with real data integration
class HealthWorkerMainScreen extends ConsumerStatefulWidget {
  const HealthWorkerMainScreen({super.key});

  @override
  ConsumerState<HealthWorkerMainScreen> createState() =>
      _HealthWorkerMainScreenState();
}

class _HealthWorkerMainScreenState
    extends ConsumerState<HealthWorkerMainScreen> {
  int _selectedIndex = 0;
  bool _isLoading = false;

  // Data from working APIs
  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _assignedClients = [];
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _conversations = [];
  int _unreadMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHealthWorkerData();
  }

  /// Load data using only working backend APIs
  Future<void> _loadHealthWorkerData() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadDashboardStats(user!.id!),
        _loadAssignedClients(user.id!),
        _loadAppointments(user.id!),
        _loadConversations(user.id!),
        _loadUnreadMessagesCount(user.id!),
      ]);
    } catch (e) {
      debugPrint('Error loading health worker data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Load dashboard statistics with improved error handling
  Future<void> _loadDashboardStats(int healthWorkerId) async {
    try {
      final response = await ApiService.instance.getHealthWorkerDashboardStats(
        healthWorkerId,
      );
      if (response.success) {
        // Handle both direct data access and nested stats field
        if (response.data is Map) {
          final responseData = Map<String, dynamic>.from(response.data as Map);
          // Check if stats is present in the response
          if (responseData.containsKey('stats')) {
            setState(() {
              _dashboardStats = Map<String, dynamic>.from(
                responseData['stats'] ?? {},
              );
            });
          } else {
            // Use the data directly if no stats field
            setState(() {
              _dashboardStats = responseData;
            });
          }
        } else {
          debugPrint('Warning: Unexpected dashboard stats format');
          setState(() {
            _dashboardStats = {};
          });
        }
      } else {
        debugPrint('Error loading dashboard stats: ${response.message}');
        setState(() {
          _dashboardStats = {};
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
      setState(() {
        _dashboardStats = {};
      });
    }
  }

  /// Load assigned clients with improved error handling
  Future<void> _loadAssignedClients(int healthWorkerId) async {
    try {
      final response = await ApiService.instance.getHealthWorkerClients(
        healthWorkerId,
      );
      if (response.success) {
        // Handle both direct data access and nested clients field
        if (response.data is List) {
          setState(() {
            _assignedClients = List<Map<String, dynamic>>.from(
              response.data as List,
            );
          });
        } else if (response.data is Map &&
            (response.data as Map).containsKey('clients')) {
          final responseData = Map<String, dynamic>.from(response.data as Map);
          setState(() {
            _assignedClients = List<Map<String, dynamic>>.from(
              responseData['clients'] ?? [],
            );
          });
        } else {
          debugPrint('Warning: Unexpected clients response format');
          setState(() {
            _assignedClients = [];
          });
        }
      } else {
        debugPrint('Error loading clients: ${response.message}');
        setState(() {
          _assignedClients = [];
        });
      }
    } catch (e) {
      debugPrint('Error loading assigned clients: $e');
      setState(() {
        _assignedClients = [];
      });
    }
  }

  /// Load appointments with improved error handling
  Future<void> _loadAppointments(int healthWorkerId) async {
    try {
      final response = await ApiService.instance.getHealthWorkerAppointments(
        healthWorkerId,
      );
      if (response.success) {
        // Handle both direct data access and nested appointments field
        if (response.data is List) {
          setState(() {
            _appointments = List<Map<String, dynamic>>.from(
              response.data as List,
            );
          });
        } else if (response.data is Map &&
            (response.data as Map).containsKey('appointments')) {
          final responseData = Map<String, dynamic>.from(response.data as Map);
          setState(() {
            _appointments = List<Map<String, dynamic>>.from(
              responseData['appointments'] ?? [],
            );
          });
        } else {
          debugPrint('Warning: Unexpected appointments response format');
          setState(() {
            _appointments = [];
          });
        }
      } else {
        debugPrint('Error loading appointments: ${response.message}');
        setState(() {
          _appointments = [];
        });
      }
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      setState(() {
        _appointments = [];
      });
    }
  }

  /// Load conversations with improved error handling and use of APIService
  Future<void> _loadConversations(int userId) async {
    try {
      final response = await ApiService.instance.getConversationPartners(
        userId,
      );

      if (response.success) {
        if (response.data is Map &&
            (response.data as Map).containsKey('conversations')) {
          final Map<String, dynamic> data =
              response.data as Map<String, dynamic>;
          setState(() {
            _conversations = List<Map<String, dynamic>>.from(
              data['conversations'] ?? [],
            );
          });
        } else if (response.data is List) {
          setState(() {
            _conversations = List<Map<String, dynamic>>.from(
              response.data as List,
            );
          });
        } else {
          debugPrint('Warning: Unexpected conversations response format');
          setState(() {
            _conversations = [];
          });
        }
      } else {
        debugPrint('Error loading conversations: ${response.message}');
        setState(() {
          _conversations = [];
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      setState(() {
        _conversations = [];
      });
    }
  }

  /// Load unread messages count
  Future<void> _loadUnreadMessagesCount(int userId) async {
    try {
      final response = await ApiService.instance.getUnreadMessagesCount(userId);
      if (response.success && response.data != null) {
        final responseData = Map<String, dynamic>.from(response.data as Map);
        setState(() {
          _unreadMessagesCount = responseData['unreadCount'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading unread messages count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboardTab(),
            _buildClientsTab(),
            _buildAppointmentsTab(),
            _buildMessagesTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${_assignedClients.length}'),
              child: const Icon(Icons.people),
            ),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${_appointments.length}'),
              child: const Icon(Icons.calendar_today),
            ),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$_unreadMessagesCount'),
              child: const Icon(Icons.message),
            ),
            label: 'Messages',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    final user = ref.watch(currentUserProvider);
    final stats = Map<String, dynamic>.from(_dashboardStats);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadHealthWorkerData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(user),
              const SizedBox(height: 24),
              _buildStatsCards(stats),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              user?.firstName?.substring(0, 1).toUpperCase() ?? 'H',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  user?.firstName ?? 'Health Worker',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Health Worker',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Clients',
          '${stats['totalClients'] ?? 0}',
          Icons.people,
          AppColors.primary,
        ),
        _buildStatCard(
          'Total Appointments',
          '${stats['totalAppointments'] ?? 0}',
          Icons.calendar_today,
          AppColors.success,
        ),
        _buildStatCard(
          'Today\'s Appointments',
          '${stats['todayAppointments'] ?? 0}',
          Icons.today,
          AppColors.warning,
        ),
        _buildStatCard(
          'Completed',
          '${stats['completedAppointments'] ?? 0}',
          Icons.check_circle,
          AppColors.info,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _buildQuickActionButton(
                'Schedule Appointment',
                Icons.calendar_today,
                AppColors.primary,
                () => _navigateToScheduleAppointment(),
              ),
              _buildQuickActionButton(
                'Time Slots',
                Icons.schedule,
                AppColors.secondary,
                () => _navigateToTimeSlots(),
              ),
              _buildQuickActionButton(
                'Add Client',
                Icons.person_add,
                AppColors.success,
                () => _navigateToAddClient(),
              ),
              _buildQuickActionButton(
                'STI Tests',
                Icons.medical_services,
                Colors.red[600]!,
                () => _navigateToSTITests(),
              ),
              _buildQuickActionButton(
                'Side Effects',
                Icons.report_problem,
                Colors.orange,
                () => _navigateToSideEffects(),
              ),
              _buildQuickActionButton(
                'Community Events',
                Icons.event,
                Colors.green[600]!,
                () => _navigateToCommunityEvents(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Recent appointments
              if (_appointments.isNotEmpty) ...[
                _buildActivityItem(
                  'Recent Appointment',
                  'Appointment with ${_appointments.first['user']?['name'] ?? 'Client'}',
                  Icons.calendar_today,
                  AppColors.primary,
                  () => _viewAppointmentDetails(_appointments.first),
                ),
                const Divider(),
              ],
              // Recent messages
              if (_conversations.isNotEmpty) ...[
                _buildActivityItem(
                  'New Message',
                  'Message from ${_conversations.first['name'] ?? 'Client'}',
                  Icons.message,
                  AppColors.info,
                  () => _viewConversation(_conversations.first),
                ),
                const Divider(),
              ],
              // Recent clients
              if (_assignedClients.isNotEmpty) ...[
                _buildActivityItem(
                  'Client Update',
                  'Client ${_assignedClients.first['name'] ?? 'Unknown'} profile updated',
                  Icons.person,
                  AppColors.success,
                  () => _viewClientDetails(_assignedClients.first),
                ),
              ],
              // Empty state
              if (_appointments.isEmpty &&
                  _conversations.isEmpty &&
                  _assignedClients.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No recent activity',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildClientsTab() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'My Clients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_assignedClients.length} clients',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _assignedClients.isEmpty
                    ? _buildEmptyState(
                      'No Clients Assigned',
                      'Assigned clients will appear here',
                      Icons.people_outline,
                    )
                    : RefreshIndicator(
                      onRefresh: _loadHealthWorkerData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _assignedClients.length,
                        itemBuilder: (context, index) {
                          final client = _assignedClients[index];
                          return _buildClientCard(client);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Appointments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_appointments.length} appointments',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _appointments.isEmpty
                    ? _buildEmptyState(
                      'No Appointments',
                      'Scheduled appointments will appear here',
                      Icons.calendar_today_outlined,
                    )
                    : RefreshIndicator(
                      onRefresh: _loadHealthWorkerData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _appointments[index];
                          return _buildAppointmentCard(appointment);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_conversations.length} conversations',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _conversations.isEmpty
                    ? _buildEmptyState(
                      'No Messages Yet',
                      'Start conversations with your clients',
                      Icons.message_outlined,
                    )
                    : RefreshIndicator(
                      onRefresh: _loadHealthWorkerData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = _conversations[index];
                          return _buildConversationCard(conversation);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            (client['name'] ?? 'U').substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          client['name'] ?? 'Unknown Client',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(client['email'] ?? ''), Text(client['phone'] ?? '')],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _viewClientDetails(client),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          child: Icon(Icons.calendar_today, color: AppColors.success),
        ),
        title: Text(
          appointment['user']?['name'] ?? 'Unknown Client',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment['appointmentDate'] ?? ''),
            Text(appointment['status'] ?? ''),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _viewAppointmentDetails(appointment),
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conversation) {
    final name = conversation['name'] ?? 'Unknown User';
    final lastMessage = conversation['lastMessage'] ?? '';
    final unreadCount = conversation['unreadCount'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.info.withValues(alpha: 0.1),
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: AppColors.info,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          lastMessage.isEmpty ? 'No messages yet' : lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            unreadCount > 0
                ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _viewConversation(conversation),
      ),
    );
  }

  void _viewClientDetails(Map<String, dynamic> client) {
    // TODO: Navigate to client details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View details for ${client['name']}')),
    );
  }

  void _viewAppointmentDetails(Map<String, dynamic> appointment) {
    // TODO: Navigate to appointment details screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('View appointment details')));
  }

  void _viewConversation(Map<String, dynamic> conversation) {
    // Navigate to conversation detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationDetailScreen(otherUser: conversation),
      ),
    );
  }

  // Quick Action Navigation Methods
  void _navigateToScheduleAppointment() {
    setState(() => _selectedIndex = 1); // Switch to appointments tab
  }

  void _navigateToAddClient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddClientScreen()),
    );

    // If a client was successfully created, refresh the dashboard
    if (result == true) {
      _loadHealthWorkerData();
    }
  }

  void _navigateToTimeSlots() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TimeSlotsManagementScreen(),
      ),
    );
  }

  void _navigateToSTITests() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const STITestRecordsScreen()),
    );
  }

  void _navigateToSideEffects() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SideEffectReportsScreen()),
    );
  }

  void _navigateToCommunityEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CommunityEventsScreen()),
    );
  }
}
