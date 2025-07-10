import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../core/models/health_record_model.dart';
import '../../core/models/appointment_model.dart';
import '../../widgets/voice_button.dart';
import '../messaging/enhanced_chat_screen.dart';

class ClientDetailsScreen extends StatefulWidget {
  final User client;
  final User healthWorker;

  const ClientDetailsScreen({
    super.key,
    required this.client,
    required this.healthWorker,
  });

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HealthRecord> _healthRecords = [];
  List<Appointment> _appointments = [];
  List<Medication> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadClientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClientData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));

      _healthRecords = [
        HealthRecord(
          id: '1',
          userId: widget.client.id,
          healthWorkerId: widget.healthWorker.id,
          recordDate: DateTime.now().subtract(const Duration(days: 7)),
          recordType: 'consultation',
          type: HealthRecordType.consultation,
          data: {
            'symptoms': ['Kurwara umutwe', 'Kuraguza'],
            'diagnosis': 'Indwara y\'amafunguro',
            'treatment': 'Imiti y\'amafunguro',
          },
          notes: 'Umukiriya yaje afite ibibazo by\'amafunguro. Yahawe imiti.',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        HealthRecord(
          id: '2',
          userId: widget.client.id,
          healthWorkerId: widget.healthWorker.id,
          recordDate: DateTime.now().subtract(const Duration(days: 30)),
          recordType: 'family_planning',
          type: HealthRecordType.familyPlanning,
          data: {
            'method': 'Pills',
            'startDate':
                DateTime.now()
                    .subtract(const Duration(days: 30))
                    .toIso8601String(),
            'nextVisit':
                DateTime.now().add(const Duration(days: 60)).toIso8601String(),
          },
          notes: 'Gahunda y\'umuryango - Imiti y\'kurinda inda.',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ];

      _appointments = [
        Appointment(
          id: '1',
          client: widget.client,
          healthWorker: widget.healthWorker,
          appointmentDate: DateTime.now().add(const Duration(days: 7)),
          durationMinutes: 30,
          appointmentType: AppointmentType.followUp,
          status: AppointmentStatus.scheduled,
          reason: 'Gukurikirana ubuvuzi',
          isFollowUp: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      _medications = [
        Medication(
          id: '1',
          userId: widget.client.id,
          name: 'Paracetamol',
          dosage: '500mg',
          frequency: '2x per day',
          startDate: DateTime.now().subtract(const Duration(days: 7)),
          endDate: DateTime.now().add(const Duration(days: 3)),
          prescribedBy: widget.healthWorker.name,
          purpose: 'Kuraguza no kurwara umutwe',
          instructions: 'Nyuma y\'ifunguro',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ];
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka amakuru');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('ubutumwa') || lowerCommand.contains('message')) {
      _startChat();
    } else if (lowerCommand.contains('gahunda') ||
        lowerCommand.contains('appointment')) {
      _tabController.animateTo(1);
    } else if (lowerCommand.contains('imiti') ||
        lowerCommand.contains('medication')) {
      _tabController.animateTo(2);
    } else if (lowerCommand.contains('amateka') ||
        lowerCommand.contains('history')) {
      _tabController.animateTo(3);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(isTablet),
            _buildClientInfo(isTablet),
            _buildTabBar(isTablet),
          ];
        },
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(isTablet),
                    _buildAppointmentsTab(isTablet),
                    _buildMedicationsTab(isTablet),
                    _buildHistoryTab(isTablet),
                  ],
                ),
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Ubutumwa" kugira ngo wohereze ubutumwa, "Gahunda" kugira ngo ugere ku gahunda, cyangwa "Imiti" kugira ngo ugere ku miti',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gukora',
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      title: Text(widget.client.name),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat_rounded),
          onPressed: _startChat,
          tooltip: 'Tanga ubutumwa',
        ),
        IconButton(
          icon: const Icon(Icons.call_rounded),
          onPressed: _callClient,
          tooltip: 'Hamagara',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editClient();
                break;
              case 'add_record':
                _addHealthRecord();
                break;
              case 'schedule':
                _scheduleAppointment();
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Hindura amakuru'),
                ),
                const PopupMenuItem(
                  value: 'add_record',
                  child: Text('Ongeraho inyandiko'),
                ),
                const PopupMenuItem(
                  value: 'schedule',
                  child: Text('Shyiraho gahunda'),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildClientInfo(bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: isTablet ? 40 : 32,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: isTablet ? 40 : 32,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.client.name,
                          style: AppTheme.headingLarge.copyWith(
                            color: Colors.white,
                            fontSize: isTablet ? 28 : 24,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing4),
                        Text(
                          widget.client.phone,
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing4),
                        Text(
                          '${widget.client.cell}, ${widget.client.sector}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Amateka',
                      '${_healthRecords.length}',
                      Icons.history_rounded,
                      isTablet,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: _buildInfoCard(
                      'Gahunda',
                      '${_appointments.length}',
                      Icons.event_rounded,
                      isTablet,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: _buildInfoCard(
                      'Imiti',
                      '${_medications.where((m) => m.isActive).length}',
                      Icons.medication_rounded,
                      isTablet,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: isTablet ? 24 : 20),
          SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(
              color: Colors.white,
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(height: AppTheme.spacing4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: isTablet ? 12 : 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isTablet) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          labelStyle: AppTheme.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 14 : 12,
          ),
          unselectedLabelStyle: AppTheme.labelMedium.copyWith(
            fontSize: isTablet ? 14 : 12,
          ),
          tabs: const [
            Tab(text: 'Incamake'),
            Tab(text: 'Gahunda'),
            Tab(text: 'Imiti'),
            Tab(text: 'Amateka'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Amakuru rusange', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildOverviewCard(isTablet),

          SizedBox(height: AppTheme.spacing24),

          _buildSectionTitle('Ibikorwa bya vuba', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildRecentActivities(isTablet),

          SizedBox(height: AppTheme.spacing24),

          _buildSectionTitle('Ibikorwa byihuse', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildQuickActions(isTablet),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      itemCount: _appointments.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Gahunda z\'inama', isTablet),
                  ElevatedButton.icon(
                    onPressed: _scheduleAppointment,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Shyiraho'),
                    style: AppTheme.primaryButtonStyle,
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing16),
            ],
          );
        }

        final appointment = _appointments[index - 1];
        return _buildAppointmentCard(appointment, isTablet);
      },
    );
  }

  Widget _buildMedicationsTab(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      itemCount: _medications.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Imiti', isTablet),
                  ElevatedButton.icon(
                    onPressed: _addMedication,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Ongeraho'),
                    style: AppTheme.primaryButtonStyle,
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing16),
            ],
          );
        }

        final medication = _medications[index - 1];
        return _buildMedicationCard(medication, isTablet);
      },
    );
  }

  Widget _buildHistoryTab(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      itemCount: _healthRecords.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Amateka y\'ubuzima', isTablet),
                  ElevatedButton.icon(
                    onPressed: _addHealthRecord,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Ongeraho'),
                    style: AppTheme.primaryButtonStyle,
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing16),
            ],
          );
        }

        final record = _healthRecords[index - 1];
        return _buildHealthRecordCard(record, isTablet);
      },
    );
  }

  Widget _buildSectionTitle(String title, bool isTablet) {
    return Text(
      title,
      style: AppTheme.headingMedium.copyWith(
        fontSize: isTablet ? 20 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOverviewCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            'Email:',
            widget.client.email,
            Icons.email_rounded,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildInfoRow(
            'Telefoni:',
            widget.client.phone,
            Icons.phone_rounded,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildInfoRow(
            'Akarere:',
            widget.client.district ?? 'N/A',
            Icons.location_on_rounded,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildInfoRow(
            'Umurenge:',
            widget.client.sector ?? 'N/A',
            Icons.place_rounded,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildInfoRow(
            'Akagari:',
            widget.client.cell ?? 'N/A',
            Icons.home_rounded,
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    bool isTablet,
  ) {
    return Row(
      children: [
        Icon(icon, size: isTablet ? 20 : 16, color: AppTheme.primaryColor),
        SizedBox(width: AppTheme.spacing12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.textSecondary,
              fontSize: isTablet ? 14 : 12,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontSize: isTablet ? 16 : 14),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(bool isTablet) {
    final activities = [
      'Inama yarangiye - ${DateFormat('MMM d').format(DateTime.now().subtract(const Duration(days: 7)))}',
      'Imiti yatanzwe - ${DateFormat('MMM d').format(DateTime.now().subtract(const Duration(days: 30)))}',
      'Gahunda yashyizweho - ${DateFormat('MMM d').format(DateTime.now().subtract(const Duration(days: 45)))}',
    ];

    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children:
            activities
                .map(
                  (activity) => Padding(
                    padding: EdgeInsets.only(bottom: AppTheme.spacing8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: Text(
                            activity,
                            style: AppTheme.bodyMedium.copyWith(
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildQuickActions(bool isTablet) {
    final actions = [
      {
        'title': 'Tanga inama',
        'icon': Icons.medical_services_rounded,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Shyiraho gahunda',
        'icon': Icons.event_rounded,
        'color': AppTheme.secondaryColor,
      },
      {
        'title': 'Ongeraho imiti',
        'icon': Icons.medication_rounded,
        'color': AppTheme.accentColor,
      },
      {
        'title': 'Tanga ubutumwa',
        'icon': Icons.chat_rounded,
        'color': AppTheme.successColor,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: AppTheme.spacing12,
        mainAxisSpacing: AppTheme.spacing12,
        childAspectRatio: isTablet ? 1.2 : 1.0,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.softShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleQuickAction(index),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Padding(
                padding: EdgeInsets.all(
                  isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: isTablet ? 32 : 24,
                    ),
                    SizedBox(height: AppTheme.spacing8),
                    Text(
                      action['title'] as String,
                      style: AppTheme.labelMedium.copyWith(
                        fontSize: isTablet ? 12 : 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_rounded,
                color: AppTheme.primaryColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  appointment.typeDisplayNameKinyarwanda,
                  style: AppTheme.labelLarge.copyWith(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing8,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    appointment.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.spacing4),
                ),
                child: Text(
                  _getStatusLabel(appointment.status),
                  style: AppTheme.bodySmall.copyWith(
                    color: _getStatusColor(appointment.status),
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 10 : 8,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          Text(
            DateFormat(
              'EEEE, MMMM d, y - HH:mm',
            ).format(appointment.appointmentDate),
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontSize: isTablet ? 14 : 12,
            ),
          ),
          if (appointment.reason != null) ...[
            SizedBox(height: AppTheme.spacing8),
            Text(
              appointment.reason!,
              style: AppTheme.bodyMedium.copyWith(fontSize: isTablet ? 14 : 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medication medication, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medication_rounded,
                color: AppTheme.accentColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  medication.name,
                  style: AppTheme.labelLarge.copyWith(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing8,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color:
                      medication.isActive
                          ? AppTheme.successColor.withValues(alpha: 0.1)
                          : AppTheme.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.spacing4),
                ),
                child: Text(
                  medication.isActive ? 'Akora' : 'Ntakora',
                  style: AppTheme.bodySmall.copyWith(
                    color:
                        medication.isActive
                            ? AppTheme.successColor
                            : AppTheme.textTertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 10 : 8,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          Text(
            '${medication.dosage} - ${medication.frequency}',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontSize: isTablet ? 14 : 12,
            ),
          ),
          if (medication.instructions != null) ...[
            SizedBox(height: AppTheme.spacing8),
            Text(
              medication.instructions!,
              style: AppTheme.bodyMedium.copyWith(fontSize: isTablet ? 14 : 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthRecordCard(HealthRecord record, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getRecordTypeIcon(record.type),
                color: _getRecordTypeColor(record.type),
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  _getRecordTypeLabel(record.type),
                  style: AppTheme.labelLarge.copyWith(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                DateFormat('MMM d, y').format(record.recordDate),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: isTablet ? 12 : 10,
                ),
              ),
            ],
          ),
          if (record.notes != null) ...[
            SizedBox(height: AppTheme.spacing12),
            Text(
              record.notes!,
              style: AppTheme.bodyMedium.copyWith(fontSize: isTablet ? 14 : 12),
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods
  void _startChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => EnhancedChatScreen(
              contact: HealthWorker(
                id: 'client_${widget.client.id}',
                name: widget.client.name,
                specialization: 'Client',
                facilityId: 'facility_1',
                phone: widget.client.phone,
                email: widget.client.email,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ),
      ),
    );
  }

  void _callClient() {
    _showErrorSnackBar('Guhamagara - Izaza vuba');
  }

  void _editClient() {
    _showErrorSnackBar('Guhindura amakuru - Izaza vuba');
  }

  void _addHealthRecord() {
    _showErrorSnackBar('Kongeramo inyandiko - Izaza vuba');
  }

  void _scheduleAppointment() {
    _showErrorSnackBar('Gushyiraho gahunda - Izaza vuba');
  }

  void _addMedication() {
    _showErrorSnackBar('Kongeramo imiti - Izaza vuba');
  }

  void _handleQuickAction(int index) {
    switch (index) {
      case 0:
        _addHealthRecord();
        break;
      case 1:
        _scheduleAppointment();
        break;
      case 2:
        _addMedication();
        break;
      case 3:
        _startChat();
        break;
    }
  }

  String _getStatusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Yateguwe';
      case AppointmentStatus.confirmed:
        return 'Yemejwe';
      case AppointmentStatus.checkedIn:
        return 'Yinjiye';
      case AppointmentStatus.inProgress:
        return 'Iragenda';
      case AppointmentStatus.completed:
        return 'Yarangiye';
      case AppointmentStatus.cancelled:
        return 'Yahagaritswe';
      case AppointmentStatus.noShow:
        return 'Ntiyaje';
      case AppointmentStatus.rescheduled:
        return 'Yahinduwe';
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return AppTheme.primaryColor;
      case AppointmentStatus.confirmed:
        return AppTheme.successColor;
      case AppointmentStatus.checkedIn:
        return AppTheme.accentColor;
      case AppointmentStatus.inProgress:
        return AppTheme.warningColor;
      case AppointmentStatus.completed:
        return AppTheme.successColor;
      case AppointmentStatus.cancelled:
        return AppTheme.errorColor;
      case AppointmentStatus.noShow:
        return AppTheme.errorColor;
      case AppointmentStatus.rescheduled:
        return AppTheme.accentColor;
    }
  }

  IconData _getRecordTypeIcon(HealthRecordType type) {
    switch (type) {
      case HealthRecordType.consultation:
        return Icons.medical_services_rounded;
      case HealthRecordType.vaccination:
        return Icons.vaccines_rounded;
      case HealthRecordType.labResult:
        return Icons.science_rounded;
      case HealthRecordType.prescription:
        return Icons.medication_rounded;
      case HealthRecordType.vitalSigns:
        return Icons.monitor_heart_rounded;
      case HealthRecordType.familyPlanning:
        return Icons.family_restroom_rounded;
      case HealthRecordType.pregnancy:
        return Icons.pregnant_woman_rounded;
      case HealthRecordType.prenatalCare:
        return Icons.baby_changing_station_rounded;
      case HealthRecordType.menstrualCycle:
        return Icons.calendar_month_rounded;
      case HealthRecordType.contraception:
        return Icons.health_and_safety_rounded;
    }
  }

  Color _getRecordTypeColor(HealthRecordType type) {
    switch (type) {
      case HealthRecordType.consultation:
        return AppTheme.primaryColor;
      case HealthRecordType.vaccination:
        return AppTheme.successColor;
      case HealthRecordType.labResult:
        return AppTheme.accentColor;
      case HealthRecordType.prescription:
        return AppTheme.warningColor;
      case HealthRecordType.vitalSigns:
        return AppTheme.errorColor;
      case HealthRecordType.familyPlanning:
        return AppTheme.secondaryColor;
      case HealthRecordType.pregnancy:
        return AppTheme.accentColor;
      case HealthRecordType.prenatalCare:
        return AppTheme.primaryColor.withValues(alpha: 0.8);
      case HealthRecordType.menstrualCycle:
        return AppTheme.primaryColor;
      case HealthRecordType.contraception:
        return AppTheme.successColor;
    }
  }

  String _getRecordTypeLabel(HealthRecordType type) {
    switch (type) {
      case HealthRecordType.consultation:
        return 'Inama';
      case HealthRecordType.vaccination:
        return 'Urukingo';
      case HealthRecordType.labResult:
        return 'Ibizamini';
      case HealthRecordType.prescription:
        return 'Imiti';
      case HealthRecordType.vitalSigns:
        return 'Ibipimo';
      case HealthRecordType.familyPlanning:
        return 'Gahunda y\'umuryango';
      case HealthRecordType.pregnancy:
        return 'Inda';
      case HealthRecordType.prenatalCare:
        return 'Kwita ku nda';
      case HealthRecordType.menstrualCycle:
        return 'Imihango';
      case HealthRecordType.contraception:
        return 'Kurinda inda';
    }
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppTheme.backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
