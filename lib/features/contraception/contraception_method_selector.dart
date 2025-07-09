import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/contraception_model.dart';
import '../../widgets/voice_button.dart';

class ContraceptionMethodSelector extends StatefulWidget {
  final ContraceptionMethod? currentMethod;
  final Function(ContraceptionMethod) onMethodSelected;

  const ContraceptionMethodSelector({
    super.key,
    this.currentMethod,
    required this.onMethodSelected,
  });

  @override
  State<ContraceptionMethodSelector> createState() =>
      _ContraceptionMethodSelectorState();
}

class _ContraceptionMethodSelectorState
    extends State<ContraceptionMethodSelector> {
  ContraceptionType? _selectedType;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<ContraceptionMethodInfo> _methods = [
    ContraceptionMethodInfo(
      type: ContraceptionType.pill,
      name: 'Imiti y\'kurinda inda',
      description: 'Imiti ifatwa buri munsi',
      effectiveness: 91.0,
      duration: 'Buri munsi',
      pros: [
        'Yoroshye gukoresha',
        'Irashobora guhagarika vuba',
        'Igabanya ububabare bw\'imihango',
      ],
      cons: [
        'Igomba kwibukwa buri munsi',
        'Ingaruka z\'imiti',
        'Ntikurinda indwara',
      ],
      suitableFor: ['Abakobwa bakuru', 'Abashaka gukumira inda by\'agateganyo'],
      icon: Icons.medication_rounded,
      color: AppTheme.primaryColor,
    ),
    ContraceptionMethodInfo(
      type: ContraceptionType.iud,
      name: 'IUD',
      description: 'Igikoresho gishyirwa mu nyababyeyi',
      effectiveness: 99.2,
      duration: '3-10 imyaka',
      pros: [
        'Ikora igihe kinini',
        'Ntikenewe kwibukwa',
        'Irashobora gukurwa vuba',
      ],
      cons: [
        'Ikenewe umuganga',
        'Irashobora guteza ububabare',
        'Igiciro kinini',
      ],
      suitableFor: [
        'Abashaka gukumira inda igihe kinini',
        'Abatashaka kwibuka buri munsi',
      ],
      icon: Icons.device_hub_rounded,
      color: AppTheme.secondaryColor,
    ),
    ContraceptionMethodInfo(
      type: ContraceptionType.implant,
      name: 'Implant',
      description: 'Igikoresho gishyirwa mu ukuboko',
      effectiveness: 99.95,
      duration: '3 imyaka',
      pros: ['Ikora cyane', 'Ntikenewe kwibukwa', 'Irashobora gukurwa vuba'],
      cons: [
        'Ikenewe umuganga',
        'Irashobora guhindura imihango',
        'Igiciro kinini',
      ],
      suitableFor: [
        'Abashaka gukumira inda igihe kinini',
        'Abatashaka kwibuka buri munsi',
      ],
      icon: Icons.linear_scale_rounded,
      color: AppTheme.accentColor,
    ),
    ContraceptionMethodInfo(
      type: ContraceptionType.injection,
      name: 'Urushinge',
      description: 'Urushinge ruterwa buri mezi atatu',
      effectiveness: 94.0,
      duration: '3 amezi',
      pros: [
        'Ntikenewe kwibukwa buri munsi',
        'Irashobora guhagarika imihango',
        'Ryoroshye gukoresha',
      ],
      cons: [
        'Ikenewe umuganga',
        'Irashobora gutinda gusubira mu buzima',
        'Ingaruka z\'imiti',
      ],
      suitableFor: [
        'Abatashaka kwibuka buri munsi',
        'Abashaka guhagarika imihango',
      ],
      icon: Icons.vaccines_rounded,
      color: AppTheme.warningColor,
    ),
    ContraceptionMethodInfo(
      type: ContraceptionType.condom,
      name: 'Condom',
      description: 'Igikoresho gikoresha mu gihe cy\'imibonano',
      effectiveness: 82.0,
      duration: 'Buri gihe',
      pros: ['Ikurinda indwara', 'Iboneka vuba', 'Nta ngaruka z\'imiti'],
      cons: [
        'Igomba gukoreshwa buri gihe',
        'Irashobora gucika',
        'Igabanya ubwoba',
      ],
      suitableFor: ['Abantu bose', 'Abashaka kurinda indwara'],
      icon: Icons.shield_rounded,
      color: AppTheme.successColor,
    ),
    ContraceptionMethodInfo(
      type: ContraceptionType.naturalFamilyPlanning,
      name: 'Gahunda y\'umuryango kamere',
      description: 'Gukoresha ubumenyi bw\'umubiri',
      effectiveness: 76.0,
      duration: 'Buri munsi',
      pros: ['Nta miti', 'Nta giciro', 'Kwiga umubiri wawe'],
      cons: ['Bigoye gukoresha', 'Bikenewe kwiga', 'Ntikora cyane'],
      suitableFor: ['Abashaka gukoresha uburyo kamere', 'Abatashaka imiti'],
      icon: Icons.nature_rounded,
      color: AppTheme.infoColor,
    ),
  ];

  List<ContraceptionMethodInfo> get _filteredMethods {
    return _methods.where((method) {
      final matchesSearch =
          method.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          method.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == null || method.type == _selectedType;
      return matchesSearch && matchesType;
    }).toList();
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('imiti') || lowerCommand.contains('pill')) {
      _selectMethod(ContraceptionType.pill);
    } else if (lowerCommand.contains('iud')) {
      _selectMethod(ContraceptionType.iud);
    } else if (lowerCommand.contains('implant')) {
      _selectMethod(ContraceptionType.implant);
    } else if (lowerCommand.contains('urushinge') ||
        lowerCommand.contains('injection')) {
      _selectMethod(ContraceptionType.injection);
    } else if (lowerCommand.contains('condom')) {
      _selectMethod(ContraceptionType.condom);
    } else if (lowerCommand.contains('kamere') ||
        lowerCommand.contains('natural')) {
      _selectMethod(ContraceptionType.naturalFamilyPlanning);
    }
  }

  void _selectMethod(ContraceptionType type) {
    final method = _methods.firstWhere((m) => m.type == type);
    _showMethodDetails(method);
  }

  void _showMethodDetails(ContraceptionMethodInfo methodInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _MethodDetailsSheet(
            methodInfo: methodInfo,
            onSelect: () {
              Navigator.of(context).pop();
              _confirmMethodSelection(methodInfo);
            },
          ),
    );
  }

  void _confirmMethodSelection(ContraceptionMethodInfo methodInfo) {
    final method = ContraceptionMethod(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: methodInfo.type,
      name: methodInfo.name,
      description: methodInfo.description,
      startDate: DateTime.now(),
      effectiveness: methodInfo.effectiveness,
      instructions: 'Koresha nk\'uko byasabwe',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onMethodSelected(method);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Hitamo uburyo bwo kurinda inda'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filter
          _buildSearchAndFilter(isTablet),

          // Methods list
          Expanded(child: _buildMethodsList(isTablet)),
        ],
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Imiti" kugira ngo uhitemo imiti, "IUD", "Implant", "Urushinge", "Condom", cyangwa "Kamere" kugira ngo uhitemo uburyo',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi guhitamo',
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Shakisha uburyo...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.backgroundColor,
            ),
          ),

          SizedBox(height: AppTheme.spacing12),

          // Filter chips
          SizedBox(
            height: isTablet ? 50 : 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Byose', null, isTablet),
                _buildFilterChip('Imiti', ContraceptionType.pill, isTablet),
                _buildFilterChip('IUD', ContraceptionType.iud, isTablet),
                _buildFilterChip(
                  'Implant',
                  ContraceptionType.implant,
                  isTablet,
                ),
                _buildFilterChip(
                  'Urushinge',
                  ContraceptionType.injection,
                  isTablet,
                ),
                _buildFilterChip('Condom', ContraceptionType.condom, isTablet),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3, duration: 600.ms);
  }

  Widget _buildFilterChip(
    String label,
    ContraceptionType? type,
    bool isTablet,
  ) {
    final isSelected = _selectedType == type;

    return Container(
      margin: EdgeInsets.only(right: AppTheme.spacing8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = selected ? type : null;
          });
        },
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: AppTheme.bodySmall.copyWith(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMethodsList(bool isTablet) {
    if (_filteredMethods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: isTablet ? 64 : 48,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Nta buryo buboneka',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      itemCount: _filteredMethods.length,
      itemBuilder: (context, index) {
        final method = _filteredMethods[index];
        return _buildMethodCard(method, isTablet, index);
      },
    );
  }

  Widget _buildMethodCard(
    ContraceptionMethodInfo method,
    bool isTablet,
    int index,
  ) {
    return Container(
          margin: EdgeInsets.only(bottom: AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.softShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showMethodDetails(method),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Padding(
                padding: EdgeInsets.all(
                  isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                            isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
                          ),
                          decoration: BoxDecoration(
                            color: method.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              isTablet ? 16 : 12,
                            ),
                          ),
                          child: Icon(
                            method.icon,
                            color: method.color,
                            size: isTablet ? 32 : 24,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.name,
                                style: AppTheme.headingSmall.copyWith(
                                  fontSize: isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: AppTheme.spacing4),
                              Text(
                                method.description,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppTheme.textTertiary,
                          size: isTablet ? 20 : 16,
                        ),
                      ],
                    ),

                    SizedBox(height: AppTheme.spacing16),

                    Row(
                      children: [
                        _buildInfoChip(
                          'Ubushobozi: ${method.effectiveness}%',
                          method.color,
                          isTablet,
                        ),
                        SizedBox(width: AppTheme.spacing8),
                        _buildInfoChip(
                          'Igihe: ${method.duration}',
                          AppTheme.textSecondary,
                          isTablet,
                        ),
                      ],
                    ),

                    SizedBox(height: AppTheme.spacing12),

                    Text(
                      'Bikwiye: ${method.suitableFor.join(", ")}',
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
        )
        .animate(delay: (index * 100).ms)
        .fadeIn()
        .slideX(begin: -0.3, duration: 600.ms);
  }

  Widget _buildInfoChip(String text, Color color, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.spacing4),
      ),
      child: Text(
        text,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: isTablet ? 10 : 8,
        ),
      ),
    );
  }
}

class _MethodDetailsSheet extends StatelessWidget {
  final ContraceptionMethodInfo methodInfo;
  final VoidCallback onSelect;

  const _MethodDetailsSheet({required this.methodInfo, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Container(
      height: size.height * 0.8,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                        ),
                        decoration: BoxDecoration(
                          color: methodInfo.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 20 : 16,
                          ),
                        ),
                        child: Icon(
                          methodInfo.icon,
                          color: methodInfo.color,
                          size: isTablet ? 40 : 32,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              methodInfo.name,
                              style: AppTheme.headingLarge.copyWith(
                                fontSize: isTablet ? 28 : 24,
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            Text(
                              methodInfo.description,
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.spacing32),

                  // Effectiveness
                  _buildDetailSection(
                    'Ubushobozi',
                    '${methodInfo.effectiveness}% mu koresha gusanzwe',
                    Icons.shield_rounded,
                    methodInfo.color,
                    isTablet,
                  ),

                  SizedBox(height: AppTheme.spacing24),

                  // Pros
                  _buildListSection(
                    'Inyungu',
                    methodInfo.pros,
                    Icons.check_circle_rounded,
                    AppTheme.successColor,
                    isTablet,
                  ),

                  SizedBox(height: AppTheme.spacing24),

                  // Cons
                  _buildListSection(
                    'Ibibazo',
                    methodInfo.cons,
                    Icons.warning_rounded,
                    AppTheme.warningColor,
                    isTablet,
                  ),

                  SizedBox(height: AppTheme.spacing24),

                  // Suitable for
                  _buildListSection(
                    'Bikwiye',
                    methodInfo.suitableFor,
                    Icons.people_rounded,
                    AppTheme.infoColor,
                    isTablet,
                  ),

                  SizedBox(height: AppTheme.spacing32),

                  // Select button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onSelect,
                      style: AppTheme.primaryButtonStyle.copyWith(
                        padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(
                            vertical:
                                isTablet
                                    ? AppTheme.spacing20
                                    : AppTheme.spacing16,
                          ),
                        ),
                      ),
                      child: Text(
                        'Hitamo ubu buryo',
                        style: AppTheme.labelLarge.copyWith(
                          color: Colors.white,
                          fontSize: isTablet ? 18 : 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    String content,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: isTablet ? 24 : 20),
          SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(content, style: AppTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: isTablet ? 24 : 20),
            SizedBox(width: AppTheme.spacing8),
            Text(
              title,
              style: AppTheme.headingSmall.copyWith(
                color: color,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacing12),
        ...items.map(
          (item) => Padding(
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
                    color: color,
                    borderRadius: BorderRadius.circular(isTablet ? 3 : 2),
                  ),
                ),
                Expanded(child: Text(item, style: AppTheme.bodyMedium)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ContraceptionMethodInfo {
  final ContraceptionType type;
  final String name;
  final String description;
  final double effectiveness;
  final String duration;
  final List<String> pros;
  final List<String> cons;
  final List<String> suitableFor;
  final IconData icon;
  final Color color;

  ContraceptionMethodInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.effectiveness,
    required this.duration,
    required this.pros,
    required this.cons,
    required this.suitableFor,
    required this.icon,
    required this.color,
  });
}
