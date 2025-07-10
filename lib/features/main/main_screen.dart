import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../dashboard/dashboard_screen.dart';
import '../health_worker/health_worker_dashboard.dart';
import '../admin/admin_dashboard.dart';

class MainScreen extends StatelessWidget {
  final User? user;

  const MainScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    // Get current user (in a real app, this would come from authentication service)
    final currentUser = user ?? SampleUsers.getCurrentUser();

    // Route to appropriate dashboard based on user role
    switch (currentUser.role) {
      case UserRole.client:
        return const DashboardScreen(); // Client dashboard
      case UserRole.healthWorker:
        return HealthWorkerDashboard(user: currentUser);
      case UserRole.admin:
        return AdminDashboard(user: currentUser);
    }
  }
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            children: [
              const Spacer(),

              // Title
              Text(
                'Hitamo uruhare rwawe',
                style: TextStyle(
                  fontSize: isTablet ? 32 : 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Hitamo uruhare rwawe kugira ngo ugere ku bikorwa byawe',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Role Cards
              _buildRoleCard(
                title: 'Umunyangire',
                subtitle:
                    'Koresha app kugira ngo wige no gukurikirana ubuzima bwawe',
                icon: Icons.person_rounded,
                color: const Color(0xFF3B82F6),
                role: UserRole.client,
                isTablet: isTablet,
              ),

              const SizedBox(height: 16),

              _buildRoleCard(
                title: 'Umukozi w\'ubuzima',
                subtitle: 'Gucunga abakiriya no gutanga inama z\'ubuzima',
                icon: Icons.medical_services_rounded,
                color: const Color(0xFF10B981),
                role: UserRole.healthWorker,
                isTablet: isTablet,
              ),

              const SizedBox(height: 16),

              _buildRoleCard(
                title: 'Umuyobozi',
                subtitle: 'Gucunga sisiteme no gukurikirana imikorere',
                icon: Icons.admin_panel_settings_rounded,
                color: const Color(0xFF8B5CF6),
                role: UserRole.admin,
                isTablet: isTablet,
              ),

              const Spacer(),

              // Continue Button
              if (_selectedRole != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _navigateToMainScreen();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 20 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Komeza',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required UserRole role,
    required bool isTablet,
  }) {
    final isSelected = _selectedRole == role;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : const Color(0xFFE5E7EB),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedRole = role;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 60 : 50,
                  height: isTablet ? 60 : 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
                  ),
                  child: Icon(icon, color: color, size: isTablet ? 28 : 24),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToMainScreen() {
    if (_selectedRole == null) return;

    // Get sample user for the selected role
    final users = SampleUsers.getUsersByRole(_selectedRole!);
    final user = users.isNotEmpty ? users.first : SampleUsers.users.first;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreen(user: user)),
    );
  }
}
