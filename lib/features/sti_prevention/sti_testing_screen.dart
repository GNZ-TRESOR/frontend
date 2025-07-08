import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/contraception_model.dart';
import '../../widgets/voice_button.dart';

class STITestingScreen extends StatefulWidget {
  const STITestingScreen({super.key});

  @override
  State<STITestingScreen> createState() => _STITestingScreenState();
}

class _STITestingScreenState extends State<STITestingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _testDate;
  STITestType _testType = STITestType.routine;
  List<String> _selectedTests = [];
  final TextEditingController _notesController = TextEditingController();
  bool _isConfidential = true;
  bool _isLoading = false;

  final List<STITestOption> _availableTests = [
    STITestOption(
      id: 'hiv',
      name: 'HIV',
      description: 'Isuzuma rya HIV/AIDS',
      isRecommended: true,
      frequency: 'Buri mezi 3-6',
    ),
    STITestOption(
      id: 'syphilis',
      name: 'Syphilis',
      description: 'Isuzuma rya Syphilis',
      isRecommended: true,
      frequency: 'Buri mwaka',
    ),
    STITestOption(
      id: 'gonorrhea',
      name: 'Gonorrhea',
      description: 'Isuzuma rya Gonorrhea',
      isRecommended: true,
      frequency: 'Buri mwaka',
    ),
    STITestOption(
      id: 'chlamydia',
      name: 'Chlamydia',
      description: 'Isuzuma rya Chlamydia',
      isRecommended: true,
      frequency: 'Buri mwaka',
    ),
    STITestOption(
      id: 'hepatitis_b',
      name: 'Hepatitis B',
      description: 'Isuzuma rya Hepatitis B',
      isRecommended: false,
      frequency: 'Rimwe gusa',
    ),
    STITestOption(
      id: 'herpes',
      name: 'Herpes',
      description: 'Isuzuma rya Herpes',
      isRecommended: false,
      frequency: 'Iyo bibaye ngombwa',
    ),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('bika') || lowerCommand.contains('save')) {
      _saveTestRecord();
    } else if (lowerCommand.contains('hiv')) {
      _toggleTest('hiv');
    } else if (lowerCommand.contains('syphilis')) {
      _toggleTest('syphilis');
    } else if (lowerCommand.contains('gonorrhea')) {
      _toggleTest('gonorrhea');
    } else if (lowerCommand.contains('chlamydia')) {
      _toggleTest('chlamydia');
    }
  }

  void _toggleTest(String testId) {
    setState(() {
      if (_selectedTests.contains(testId)) {
        _selectedTests.remove(testId);
      } else {
        _selectedTests.add(testId);
      }
    });
  }

  Future<void> _saveTestRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_testDate == null) {
      _showErrorSnackBar('Hitamo itariki y\'isuzuma');
      return;
    }

    if (_selectedTests.isEmpty) {
      _showErrorSnackBar('Hitamo byibuze isuzuma rimwe');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Save test record via API
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu kubika isuzuma');
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
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Isuzuma ryabitswe'),
        content: const Text('Amakuru y\'isuzuma yabitswe neza. Uzabona ibisubizo nyuma y\'isuzuma.'),
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
        title: const Text('Isuzuma ry\'indwara zandurira'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction card
              _buildIntroductionCard(isTablet),
              
              SizedBox(height: AppTheme.spacing24),
              
              // Test date and type
              _buildTestDetailsSection(isTablet),
              
              SizedBox(height: AppTheme.spacing24),
              
              // Available tests
              _buildTestSelectionSection(isTablet),
              
              SizedBox(height: AppTheme.spacing24),
              
              // Additional information
              _buildAdditionalInfoSection(isTablet),
              
              SizedBox(height: AppTheme.spacing32),
              
              // Save button
              _buildSaveButton(isTablet),
              
              SizedBox(height: AppTheme.spacing24),
              
              // Important information
              _buildImportantInfo(isTablet),
            ],
          ),
        ),
      ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga amazina y\'isuzuma cyangwa "Bika" kugira ngo ubike amakuru',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gukora isuzuma',
      ),
    );
  }

  Widget _buildIntroductionCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services_rounded,
                color: Colors.white,
                size: isTablet ? 32 : 24,
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  'Isuzuma ry\'indwara zandurira',
                  style: AppTheme.headingLarge.copyWith(
                    color: Colors.white,
                    fontSize: isTablet ? 24 : 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'Isuzuma ry\'indwara zandurira ni ingenzi mu kurinda ubuzima bwawe. Hitamo isuzuma ushaka gukora.',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
    );
  }

  Widget _buildTestDetailsSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amakuru y\'isuzuma',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(height: AppTheme.spacing20),
          
          // Test date
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) {
                setState(() {
                  _testDate = date;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.all(isTablet ? AppTheme.spacing16 : AppTheme.spacing12),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Itariki y\'isuzuma',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing4),
                        Text(
                          _testDate != null
                              ? DateFormat('EEEE, MMMM d, y').format(_testDate!)
                              : 'Hitamo itariki',
                          style: AppTheme.bodyMedium.copyWith(
                            color: _testDate != null 
                                ? AppTheme.textPrimary 
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: AppTheme.spacing16),
          
          // Test type
          Text(
            'Ubwoko bw\'isuzuma',
            style: AppTheme.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacing12),
          
          ..._buildTestTypeOptions(isTablet),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(
      begin: -0.3,
      duration: 600.ms,
    );
  }

  List<Widget> _buildTestTypeOptions(bool isTablet) {
    final testTypes = [
      {'value': STITestType.routine, 'title': 'Isuzuma risanzwe', 'description': 'Isuzuma rikorwa buri gihe'},
      {'value': STITestType.symptomatic, 'title': 'Isuzuma ry\'ibimenyetso', 'description': 'Isuzuma rikorwa iyo hari ibimenyetso'},
      {'value': STITestType.partnerNotification, 'title': 'Isuzuma ry\'umukunzi', 'description': 'Isuzuma rikorwa nyuma y\'umukunzi'},
      {'value': STITestType.preConception, 'title': 'Isuzuma ryo mbere y\'inda', 'description': 'Isuzuma rikorwa mbere yo gushaka inda'},
    ];

    return testTypes.map((type) {
      final isSelected = _testType == type['value'];
      return Container(
        margin: EdgeInsets.only(bottom: AppTheme.spacing8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _testType = type['value'] as STITestType;
              });
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Container(
              padding: EdgeInsets.all(isTablet ? AppTheme.spacing12 : AppTheme.spacing8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.primaryColor.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                children: [
                  Radio<STITestType>(
                    value: type['value'] as STITestType,
                    groupValue: _testType,
                    onChanged: (value) {
                      setState(() {
                        _testType = value!;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type['title'] as String,
                          style: AppTheme.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing4),
                        Text(
                          type['description'] as String,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTestSelectionSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hitamo isuzuma',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'Hitamo isuzuma ushaka gukora. Isuzuma ryose rirasabwa.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: AppTheme.spacing20),
          
          ..._availableTests.map((test) => _buildTestOption(test, isTablet)),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideX(
      begin: 0.3,
      duration: 600.ms,
    );
  }

  Widget _buildTestOption(STITestOption test, bool isTablet) {
    final isSelected = _selectedTests.contains(test.id);
    
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isSelected 
              ? AppTheme.primaryColor 
              : AppTheme.primaryColor.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleTest(test.id),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? AppTheme.spacing16 : AppTheme.spacing12),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleTest(test.id),
                  activeColor: AppTheme.primaryColor,
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            test.name,
                            style: AppTheme.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                            ),
                          ),
                          if (test.isRecommended) ...[
                            SizedBox(width: AppTheme.spacing8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing6,
                                vertical: AppTheme.spacing2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppTheme.spacing4),
                              ),
                              child: Text(
                                'Birasabwa',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 10 : 8,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        test.description,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        'Inshuro: ${test.frequency}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amakuru y\'inyongera',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(height: AppTheme.spacing20),
          
          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Inyandiko (optional)',
              hintText: 'Andika inyandiko z\'inyongera ku isuzuma...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
          
          SizedBox(height: AppTheme.spacing16),
          
          // Confidentiality
          Container(
            padding: EdgeInsets.all(isTablet ? AppTheme.spacing16 : AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.infoColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _isConfidential,
                  onChanged: (value) {
                    setState(() {
                      _isConfidential = value ?? true;
                    });
                  },
                  activeColor: AppTheme.infoColor,
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bika mu banga',
                        style: AppTheme.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.infoColor,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        'Amakuru y\'isuzuma azabikwa mu buryo bw\'ibanga',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
    );
  }

  Widget _buildSaveButton(bool isTablet) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveTestRecord,
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save_rounded),
        label: Text(
          _isLoading ? 'Urabika...' : 'Bika isuzuma',
          style: AppTheme.labelLarge.copyWith(
            color: Colors.white,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
        style: AppTheme.primaryButtonStyle.copyWith(
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
    );
  }

  Widget _buildImportantInfo(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.warningColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(
                'Ibintu by\'ingenzi',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildInfoItem('Isuzuma rikorwa mu buryo bw\'ibanga', isTablet),
          _buildInfoItem('Ibisubizo bizaboneka nyuma y\'iminsi 3-7', isTablet),
          _buildInfoItem('Niba hari ikibazo, uzahamagariwa vuba', isTablet),
          _buildInfoItem('Koresha condom kugeza ubona ibisubizo', isTablet),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
    );
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
              color: AppTheme.warningColor,
              borderRadius: BorderRadius.circular(isTablet ? 3 : 2),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class STITestOption {
  final String id;
  final String name;
  final String description;
  final bool isRecommended;
  final String frequency;

  STITestOption({
    required this.id,
    required this.name,
    required this.description,
    required this.isRecommended,
    required this.frequency,
  });
}
