import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class SupportGroupsScreen extends StatefulWidget {
  const SupportGroupsScreen({super.key});

  @override
  State<SupportGroupsScreen> createState() => _SupportGroupsScreenState();
}

class _SupportGroupsScreenState extends State<SupportGroupsScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<SupportGroup> _groups = [
    SupportGroup(
      id: '1',
      name: 'Abagore b\'ubwiyunge',
      description: 'Itsinda ry\'abagore biga kubana n\'ubwiyunge mu buryo bwiza',
      category: 'Family Planning',
      memberCount: 156,
      isPrivate: false,
      moderator: 'Dr. Marie Uwimana',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
      tags: ['Ubwiyunge', 'Abagore', 'Ubufasha'],
    ),
    SupportGroup(
      id: '2',
      name: 'Urubyiruko rw\'ubuzima',
      description: 'Itsinda ry\'urubyiruko rwiga ubuzima bw\'imyororokere',
      category: 'Youth Health',
      memberCount: 89,
      isPrivate: false,
      moderator: 'Nurse Jean Baptiste',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      lastActivity: DateTime.now().subtract(const Duration(minutes: 30)),
      tags: ['Urubyiruko', 'Ubuzima', 'Kwiga'],
    ),
    SupportGroup(
      id: '3',
      name: 'Abababyeyi bashya',
      description: 'Ubufasha bw\'ababyeyi bashya mu kurerea abana',
      category: 'Parenting',
      memberCount: 234,
      isPrivate: true,
      moderator: 'Dr. Grace Mukamana',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
      tags: ['Ababyeyi', 'Abana', 'Kurerea'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka amatsinda');
    } finally {
      setState(() => _isLoading = false);
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

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('gushaka') || lowerCommand.contains('search')) {
      // Focus search field
    } else if (lowerCommand.contains('kurema') || lowerCommand.contains('create')) {
      _showCreateGroupDialog();
    } else if (lowerCommand.contains('kwinjira') || lowerCommand.contains('join')) {
      // Join first available group
      if (_groups.isNotEmpty) {
        _joinGroup(_groups.first);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Amatsinda y\'ubufasha'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(isTablet),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildGroupsList(isTablet),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'create_group',
            onPressed: _showCreateGroupDialog,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          VoiceButton(
            prompt: 'Vuga: "Gushaka" kugira ngo ushake, "Kurema" kugira ngo ureme itsinda, cyangwa "Kwinjira" kugira ngo winjire mu tsinda',
            onResult: _handleVoiceCommand,
            tooltip: 'Koresha ijwi gucunga amatsinda',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Shakisha amatsinda...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          SizedBox(height: AppTheme.spacing16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'all',
                'Family Planning',
                'Youth Health',
                'Parenting',
                'Mental Health'
              ].map((category) {
                final isSelected = _selectedCategory == category;
                return Container(
                  margin: EdgeInsets.only(right: AppTheme.spacing8),
                  child: FilterChip(
                    label: Text(_getCategoryLabel(category)),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => _selectedCategory = category),
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList(bool isTablet) {
    final filteredGroups = _groups.where((group) {
      final matchesSearch = group.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          group.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'all' || group.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();

    if (filteredGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off,
              size: isTablet ? 64 : 48,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Nta matsinda aboneka',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
            ),
            SizedBox(height: AppTheme.spacing8),
            TextButton(
              onPressed: _showCreateGroupDialog,
              child: const Text('Rema itsinda'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      itemCount: filteredGroups.length,
      itemBuilder: (context, index) {
        final group = filteredGroups[index];
        return _buildGroupCard(group, isTablet, index);
      },
    );
  }

  Widget _buildGroupCard(SupportGroup group, bool isTablet, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(group.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    _getCategoryIcon(group.category),
                    color: _getCategoryColor(group.category),
                    size: 24,
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.name,
                              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (group.isPrivate)
                            Icon(
                              Icons.lock,
                              size: 16,
                              color: AppTheme.textTertiary,
                            ),
                        ],
                      ),
                      Text(
                        group.category,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Text(
              group.description,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
            SizedBox(height: AppTheme.spacing12),
            Wrap(
              spacing: AppTheme.spacing8,
              runSpacing: AppTheme.spacing4,
              children: group.tags.map((tag) => Chip(
                label: Text(
                  tag,
                  style: AppTheme.bodySmall,
                ),
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                side: BorderSide.none,
              )).toList(),
            ),
            SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppTheme.textTertiary),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  '${group.memberCount} abanyamuryango',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                ),
                SizedBox(width: AppTheme.spacing16),
                Icon(Icons.person, size: 16, color: AppTheme.textTertiary),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  group.moderator,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewGroupDetails(group),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Reba'),
                  ),
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _joinGroup(group),
                    icon: const Icon(Icons.group_add),
                    label: const Text('Kwinjira'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX();
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'all':
        return 'Byose';
      case 'Family Planning':
        return 'Ubwiyunge';
      case 'Youth Health':
        return 'Ubuzima bw\'urubyiruko';
      case 'Parenting':
        return 'Kurerea abana';
      case 'Mental Health':
        return 'Ubuzima bw\'ubwoba';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Family Planning':
        return AppTheme.primaryColor;
      case 'Youth Health':
        return AppTheme.secondaryColor;
      case 'Parenting':
        return AppTheme.accentColor;
      case 'Mental Health':
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Family Planning':
        return Icons.family_restroom;
      case 'Youth Health':
        return Icons.school;
      case 'Parenting':
        return Icons.child_care;
      case 'Mental Health':
        return Icons.psychology;
      default:
        return Icons.group;
    }
  }

  void _viewGroupDetails(SupportGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(group.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.description),
            SizedBox(height: AppTheme.spacing16),
            Text('Abanyamuryango: ${group.memberCount}'),
            Text('Umuyobozi: ${group.moderator}'),
            Text('Ubwoko: ${group.isPrivate ? 'Bwite' : 'Rusange'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Siga'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _joinGroup(group);
            },
            child: const Text('Kwinjira'),
          ),
        ],
      ),
    );
  }

  void _joinGroup(SupportGroup group) {
    if (group.isPrivate) {
      _showJoinPrivateGroupDialog(group);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Winjiye mu ${group.name}!')),
      );
    }
  }

  void _showJoinPrivateGroupDialog(SupportGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kwinjira mu tsinda ryite'),
        content: Text('${group.name} ni itsinda ryite. Usaba kwemererwa kwinjira.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Siga'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Icyifuzo cyoherejwe!')),
              );
            },
            child: const Text('Saba kwinjira'),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kurema itsinda'),
        content: const Text('Iyi fonctionnalité izaza vuba. Uzashobora kurema itsinda ryawe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sawa'),
          ),
        ],
      ),
    );
  }
}

class SupportGroup {
  final String id;
  final String name;
  final String description;
  final String category;
  final int memberCount;
  final bool isPrivate;
  final String moderator;
  final DateTime createdAt;
  final DateTime lastActivity;
  final List<String> tags;

  SupportGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.memberCount,
    required this.isPrivate,
    required this.moderator,
    required this.createdAt,
    required this.lastActivity,
    required this.tags,
  });
}
