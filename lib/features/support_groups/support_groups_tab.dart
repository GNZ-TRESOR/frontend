import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/support_group.dart';
import '../../core/providers/community_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/auto_translate_widget.dart';
import 'create_support_group_form.dart';
import 'support_group_detail_screen.dart';

class SupportGroupsTab extends ConsumerStatefulWidget {
  const SupportGroupsTab({super.key});

  @override
  ConsumerState<SupportGroupsTab> createState() => _SupportGroupsTabState();
}

class _SupportGroupsTabState extends ConsumerState<SupportGroupsTab> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportGroupsProvider.notifier).loadSupportGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final supportGroupsState = ref.watch(supportGroupsProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child:
                supportGroupsState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : supportGroupsState.error != null
                    ? _buildErrorWidget(supportGroupsState.error!)
                    : _buildGroupsList(supportGroupsState.groups),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "create_support_group",
        onPressed: () => _showCreateGroupDialog(),
        backgroundColor: AppColors.communityTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      'All',
      'Mental Health',
      'Chronic Conditions',
      'Pregnancy & Parenting',
      'Addiction Recovery',
      'Disability Support',
      'General Health',
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected =
              _selectedCategory == category ||
              (_selectedCategory == null && category == 'All');

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: category.at(),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory =
                      selected ? (category == 'All' ? null : category) : null;
                });
                ref
                    .read(supportGroupsProvider.notifier)
                    .setSelectedCategory(_selectedCategory);
              },
              selectedColor: AppColors.communityTeal.withValues(alpha: 0.2),
              checkmarkColor: AppColors.communityTeal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          'Error loading support groups'.at(
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(supportGroupsProvider.notifier)
                  .loadSupportGroups(category: _selectedCategory);
            },
            child: 'Retry'.at(),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList(List<SupportGroup> groups) {
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            'No support groups found'.at(
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            'Be the first to create a support group!'.at(
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildGroupCard(group);
      },
    );
  }

  Widget _buildGroupCard(SupportGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToGroupDetail(group),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: group.name.at(
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (group.isPrivate)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: 'Private'.at(
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (group.description != null)
                Text(
                  group.description!,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  '${group.memberCount} members'.at(
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: group.category.at(
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              if (group.meetingSchedule != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        group.meetingSchedule!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          group.isActive
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: group.statusText.at(
                      style: TextStyle(
                        fontSize: 12,
                        color: group.isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: group.isFull ? null : () => _joinGroup(group),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.communityTeal,
                      foregroundColor: Colors.white,
                    ),
                    child: group.isFull ? 'Full'.at() : 'Join'.at(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGroupDetail(SupportGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportGroupDetailScreen(group: group),
      ),
    );
  }

  void _joinGroup(SupportGroup group) {
    if (group.id != null) {
      ref.read(supportGroupsProvider.notifier).joinGroup(group.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: 'Joined ${group.name} successfully!'.at(),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateSupportGroupForm(),
    );
  }
}
