import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/contraception_model.dart';
import '../../widgets/voice_button.dart';

class EmergencyContraceptionScreen extends StatefulWidget {
  const EmergencyContraceptionScreen({super.key});

  @override
  State<EmergencyContraceptionScreen> createState() =>
      _EmergencyContraceptionScreenState();
}

class _EmergencyContraceptionScreenState
    extends State<EmergencyContraceptionScreen> {
  DateTime? _incidentDate;
  EmergencyContraceptiveType? _selectedType;
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  final List<EmergencyContraceptiveInfo> _emergencyOptions = [
    EmergencyContraceptiveInfo(
      type: EmergencyContraceptiveType.planB,
      name: 'Plan B (Levonorgestrel)',
      timeWindow: '72 masaha',
      effectiveness: 89,
      description: 'Ikora neza mu masaha 72 nyuma y\'imibonano',
      sideEffects: ['Kuraguza', 'Kurwara umutwe', 'Guhinduka kw\'imihango'],
      availability: 'Iboneka mu mafarumasi',
    ),
    EmergencyContraceptiveInfo(
      type: EmergencyContraceptiveType.ella,
      name: 'ella (Ulipristal)',
      timeWindow: '120 masaha',
      effectiveness: 95,
      description: 'Ikora neza mu masaha 120 nyuma y\'imibonano',
      sideEffects: ['Kuraguza', 'Kurwara umutwe', 'Ubunaniro'],
      availability: 'Ikenewe icyemezo cy\'umuganga',
    ),
    EmergencyContraceptiveInfo(
      type: EmergencyContraceptiveType.copperIUD,
      name: 'Copper IUD',
      timeWindow: '5 iminsi',
      effectiveness: 99,
      description: 'Ikora neza mu minsi 5 nyuma y\'imibonano',
      sideEffects: ['Kubabara', 'Amaraso menshi'],
      availability: 'Ikenewe umuganga',
    ),
  ];

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('plan b')) {
      _selectType(EmergencyContraceptiveType.planB);
    } else if (lowerCommand.contains('ella')) {
      _selectType(EmergencyContraceptiveType.ella);
    } else if (lowerCommand.contains('iud')) {
      _selectType(EmergencyContraceptiveType.copperIUD);
    } else if (lowerCommand.contains('emeza') ||
        lowerCommand.contains('confirm')) {
      _confirmSelection();
    }
  }

  void _selectType(EmergencyContraceptiveType type) {
    setState(() {
      _selectedType = type;
    });
  }

  Future<void> _confirmSelection() async {
    if (_selectedType == null || _incidentDate == null) {
      _showErrorSnackBar('Hitamo ubwoko n\'itariki');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Save to API
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu kubika amakuru');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Amakuru yabitswe'),
            content: const Text(
              'Amakuru yawe yabitswe neza. Reba umuganga niba ufite ibibazo.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Sawa'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Kurinda inda mu ihutirwa'),
        backgroundColor: AppTheme.errorColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning card
            _buildWarningCard(isTablet),

            SizedBox(height: AppTheme.spacing24),

            // Time sensitivity
            _buildTimeSensitivityCard(isTablet),

            SizedBox(height: AppTheme.spacing24),

            // Incident date
            _buildIncidentDateSelector(isTablet),

            SizedBox(height: AppTheme.spacing24),

            // Emergency options
            _buildEmergencyOptions(isTablet),

            SizedBox(height: AppTheme.spacing24),

            // Reason (optional)
            _buildReasonInput(isTablet),

            SizedBox(height: AppTheme.spacing32),

            // Confirm button
            _buildConfirmButton(isTablet),

            SizedBox(height: AppTheme.spacing24),

            // Important information
            _buildImportantInfo(isTablet),
          ],
        ),
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Plan B", "Ella", cyangwa "IUD" kugira ngo uhitemo, cyangwa "Emeza" kugira ngo wemeze',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi guhitamo',
      ),
    );
  }

  Widget _buildWarningCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: AppTheme.errorColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(
                'BYIHUTIRWA',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          Text(
            'Kurinda inda mu ihutirwa ni uburyo bukoresha nyuma y\'imibonano idafite uburyo bwo kurinda inda. Ikora neza iyo ikoreshwa vuba.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildTimeSensitivityCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: AppTheme.warningColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(
                'Igihe ni ingenzi',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          Text(
            'Kurinda inda mu ihutirwa gikora neza iyo gikoreshwa vuba nyuma y\'imibonano. Ntutegereze igihe kinini.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildIncidentDateSelector(bool isTablet) {
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
          Text(
            'Itariki y\'imibonano',
            style: AppTheme.headingSmall.copyWith(fontSize: isTablet ? 18 : 16),
          ),
          SizedBox(height: AppTheme.spacing16),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 7)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _incidentDate = date;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.all(
                isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppTheme.primaryColor,
                    size: isTablet ? 24 : 20,
                  ),
                  SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Text(
                      _incidentDate != null
                          ? DateFormat('EEEE, MMMM d, y').format(_incidentDate!)
                          : 'Hitamo itariki',
                      style: AppTheme.bodyMedium.copyWith(
                        color:
                            _incidentDate != null
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildEmergencyOptions(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hitamo uburyo',
          style: AppTheme.headingMedium.copyWith(fontSize: isTablet ? 20 : 18),
        ),
        SizedBox(height: AppTheme.spacing16),
        ..._emergencyOptions.map(
          (option) => _buildOptionCard(option, isTablet),
        ),
      ],
    );
  }

  Widget _buildOptionCard(EmergencyContraceptiveInfo option, bool isTablet) {
    final isSelected = _selectedType == option.type;

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color:
              isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectType(option.type),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: EdgeInsets.all(
              isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Radio<EmergencyContraceptiveType>(
                      value: option.type,
                      groupValue: _selectedType,
                      onChanged: (value) => _selectType(value!),
                      activeColor: AppTheme.primaryColor,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.name,
                            style: AppTheme.labelLarge.copyWith(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          Text(
                            'Igihe: ${option.timeWindow} • Ubushobozi: ${option.effectiveness}%',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacing12),
                Text(option.description, style: AppTheme.bodyMedium),
                SizedBox(height: AppTheme.spacing8),
                Text(
                  'Aho biboneka: ${option.availability}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.3, duration: 600.ms);
  }

  Widget _buildReasonInput(bool isTablet) {
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
          Text(
            'Impamvu (optional)',
            style: AppTheme.headingSmall.copyWith(fontSize: isTablet ? 18 : 16),
          ),
          SizedBox(height: AppTheme.spacing16),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Sobanura impamvu yo gukoresha kurinda inda mu ihutirwa...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(bool isTablet) {
    final canConfirm = _selectedType != null && _incidentDate != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canConfirm && !_isLoading ? _confirmSelection : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  'Emeza amakuru',
                  style: AppTheme.labelLarge.copyWith(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildImportantInfo(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.infoColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(
                'Ibintu by\'ingenzi',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.infoColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildInfoItem(
            'Kurinda inda mu ihutirwa ntabwo ari uburyo busanzwe',
            isTablet,
          ),
          _buildInfoItem('Ntikurinda indwara zandurira mu mibonano', isTablet),
          _buildInfoItem(
            'Reba umuganga niba ufite ibibazo cyangwa ingaruka',
            isTablet,
          ),
          _buildInfoItem(
            'Tekereza gukoresha uburyo busanzwe bwo kurinda inda',
            isTablet,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildInfoItem(String text, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 6 : 4,
            height: isTablet ? 6 : 4,
            margin: EdgeInsets.only(
              top: isTablet ? 8 : 6,
              right: AppTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: AppTheme.infoColor,
              borderRadius: BorderRadius.circular(isTablet ? 3 : 2),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class EmergencyContraceptiveInfo {
  final EmergencyContraceptiveType type;
  final String name;
  final String timeWindow;
  final int effectiveness;
  final String description;
  final List<String> sideEffects;
  final String availability;

  EmergencyContraceptiveInfo({
    required this.type,
    required this.name,
    required this.timeWindow,
    required this.effectiveness,
    required this.description,
    required this.sideEffects,
    required this.availability,
  });
}
