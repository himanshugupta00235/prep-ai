import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:prep_ai/core/constants/app_colors.dart';
import 'package:prep_ai/core/constants/app_strings.dart';
import 'package:prep_ai/viewmodels/auth_viewmodel.dart';
import 'package:prep_ai/viewmodels/profile_viewmodel.dart';
import 'package:prep_ai/widgets/custom_button.dart';
import 'package:prep_ai/widgets/custom_text_field.dart';
import 'package:prep_ai/widgets/error_widget.dart';
import 'package:prep_ai/widgets/loading_indicator.dart';

/// Profile screen displaying user information and preparation stats.
///
/// Allows the user to update their target company, view stats
/// (total questions, bookmarked count), and sign out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _targetCompanyController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  /// Loads the user profile and populates the target company field.
  Future<void> _loadProfile() async {
    final profileVM = context.read<ProfileViewModel>();
    await profileVM.loadProfile();
    if (mounted && profileVM.user != null) {
      _targetCompanyController.text = profileVM.user!.targetCompany;
    }
  }

  @override
  void dispose() {
    _targetCompanyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
      ),
      body: _buildBody(profileVM),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  /// Builds the main body based on the current ViewModel state.
  Widget _buildBody(ProfileViewModel profileVM) {
    // Loading state
    if (profileVM.isLoading) {
      return const LoadingIndicator();
    }

    // Error state
    if (profileVM.errorMessage != null && profileVM.user == null) {
      return AppErrorWidget(
        message: profileVM.errorMessage!,
        onRetry: _loadProfile,
      );
    }

    final user = profileVM.user;
    if (user == null) {
      return const AppErrorWidget(message: 'User profile not found.');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ─── Avatar ──────────────────────────────────────────
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primarySurface,
            child: Text(
              _getInitials(user.name),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── User Name ───────────────────────────────────────
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),

          // ─── User Email ──────────────────────────────────────
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),

          // ─── Target Company ──────────────────────────────────
          _buildTargetCompanySection(profileVM),
          const SizedBox(height: 32),

          // ─── Stats Section ───────────────────────────────────
          _buildStatsSection(profileVM),
          const SizedBox(height: 40),

          // ─── Logout Button ───────────────────────────────────
          CustomButton(
            text: AppStrings.logout,
            icon: Icons.logout,
            isOutlined: true,
            onPressed: () => _showLogoutConfirmation(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Builds the target company field with a save button.
  Widget _buildTargetCompanySection(ProfileViewModel profileVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.targetCompany,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _targetCompanyController,
                hintText: 'e.g. Google, Microsoft...',
                prefixIcon: Icons.business,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: profileVM.isSaving
                    ? null
                    : () async {
                        final company = _targetCompanyController.text.trim();
                        if (company.isEmpty) return;

                        final success = await context
                            .read<ProfileViewModel>()
                            .updateTargetCompany(company);

                        if (mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Target company updated!'),
                            ),
                          );
                        }
                      },
                child: profileVM.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : const Text(AppStrings.save),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the stats section with total questions and bookmarked count.
  Widget _buildStatsSection(ProfileViewModel profileVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.quiz_outlined,
                label: AppStrings.totalQuestions,
                value: profileVM.totalQuestions.toString(),
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.bookmark,
                label: AppStrings.bookmarkedQuestions,
                value: profileVM.bookmarkedCount.toString(),
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a single stat card with icon, label, and value.
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before signing out.
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await context.read<AuthViewModel>().signOut();
              if (mounted) {
                context.go('/login');
              }
            },
            child: Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Extracts up to two initials from a name string.
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Standard bottom navigation bar shared across main screens.
  Widget _buildBottomNavBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: 3,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/home');
          case 1:
            context.go('/questions');
          case 2:
            context.go('/bookmarks');
          case 3:
            break; // Already on Profile
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: AppStrings.home,
        ),
        NavigationDestination(
          icon: Icon(Icons.quiz_outlined),
          selectedIcon: Icon(Icons.quiz),
          label: AppStrings.questions,
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_border),
          selectedIcon: Icon(Icons.bookmark),
          label: AppStrings.bookmarks,
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: AppStrings.profile,
        ),
      ],
    );
  }
}
