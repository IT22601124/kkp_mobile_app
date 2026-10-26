import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';

class UserProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final VoidCallback? onLogout;

  const UserProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.onLogout,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final newUrl = await authProvider.uploadAvatar(pickedFile.path);

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          title: 'Avatar Updated',
          message: 'Profile picture successfully updated!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          title: 'Upload Failed',
          message: 'Failed to upload avatar: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showImagePickerModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextMain
                    : AppColors.lightTextMain,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primaryOrange,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.cyanAccent,
              ),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadAvatar(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user;
    final name = user?.name.isNotEmpty == true
        ? user!.name
        : 'DSR Representative';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Avatar Circle with Edit Camera Badge
              GestureDetector(
                onTap: _isUploading ? null : _showImagePickerModal,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        image:
                            user?.avatarUrl != null &&
                                user!.avatarUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(user.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _isUploading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : (user?.avatarUrl != null &&
                                user!.avatarUrl!.isNotEmpty)
                          ? null
                          : Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBg : AppColors.lightBg,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextMain
                      : AppColors.lightTextMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'rep@kkpstore.lk',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.darkTextSub,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.phone,
                        color: AppColors.cyanAccent,
                      ),
                      title: const Text('Phone Number'),
                      subtitle: Text(user?.phone ?? 'N/A'),
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.badge,
                        color: AppColors.primaryOrange,
                      ),
                      title: const Text('Role / Type'),
                      subtitle: Text(user?.role ?? 'DSR_REP'),
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.business,
                        color: AppColors.purpleAccent,
                      ),
                      title: const Text('Branch Hub'),
                      subtitle: const Text('Main Distribution Branch Hub'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                        widget.isDarkMode
                            ? Icons.wb_sunny
                            : Icons.nightlight_round,
                        color: AppColors.cyanAccent,
                      ),
                      title: const Text('Dark Mode'),
                      value: widget.isDarkMode,
                      onChanged: (val) => widget.onToggleTheme(),
                    ),
                  ],
                ),
              ),
              if (widget.onLogout != null) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          title: const Row(
                            children: [
                              Icon(Icons.logout, color: AppColors.roseDanger),
                              SizedBox(width: 8),
                              Text(
                                'Confirm Logout',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          content: const Text(
                            'Are you sure you want to log out of your account?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                                widget.onLogout!();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.roseDanger,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Log Out'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text(
                      'LOG OUT FROM APP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roseDanger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
