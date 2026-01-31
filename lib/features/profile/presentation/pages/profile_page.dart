import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pathau_now/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pathau_now/core/services/locale_service.dart';
import 'package:pathau_now/core/localization/app_localizations.dart';
import 'package:pathau_now/features/map/presentation/pages/map_screen.dart';
import 'package:pathau_now/features/auth/presentation/pages/account_details_screen.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = '/profile';
  final VoidCallback? onNavigateBack;
  final Color primaryColor;

  const ProfilePage({
    super.key,
    this.onNavigateBack,
    this.primaryColor = const Color(0xFFF57C00),
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Color get kPrimary => widget.primaryColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      await authVm.getCurrentUser();
    });
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.of(context).pop('en'),
            ),
            ListTile(
              title: const Text('नेपाली (Nepali)'),
              onTap: () => Navigator.of(context).pop('ne'),
            ),
            ListTile(
              title: const Text('Cancel'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );

    if (selected != null && selected.isNotEmpty) {
      try {
        await Provider.of<LocaleService>(
          context,
          listen: false,
        ).setLocale(selected);
        if (!mounted) return;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).t('language_set')),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to set language: $e')));
      }
    }
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'ne':
        return 'नेपाली (Nepali)';
      case 'en':
      default:
        return 'English';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _showImageSourceSheet(
    BuildContext context,
    AuthViewModel authVm,
  ) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.of(context).pop();
                final picker = ImagePicker();
                final XFile? picked = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (picked == null) return;
                final file = File(picked.path);
                if (!mounted) return;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) =>
                      const Center(child: CircularProgressIndicator()),
                );
                try {
                  await authVm.updateProfileImage(file);
                  if (!mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(' Profile photo updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {});
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(' Update failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final picker = ImagePicker();
                final XFile? picked = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (picked == null) return;
                final file = File(picked.path);
                if (!mounted) return;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) =>
                      const Center(child: CircularProgressIndicator()),
                );
                try {
                  await authVm.updateProfileImage(file);
                  if (!mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(' Profile photo updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {});
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(' Update failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: RefreshIndicator(
        onRefresh: () async {
          final authVm = Provider.of<AuthViewModel>(context, listen: false);
          print(' Pull-to-refresh: Fetching user from API...');
          await authVm.getCurrentUser();
          print(' Pull-to-refresh: Done. User = ${authVm.user?.name}');
        },
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 22 : 16,
            vertical: 16,
          ),
          children: [
            Consumer<AuthViewModel>(
              builder: (context, authVm, _) {
                final user = authVm.user;

                print(' ProfileView: Building profile view');
                print(' ProfileView: User is null: ${user == null}');
                if (user != null) {
                  print(' ProfileView: User name: ${user.name}');
                  print(' ProfileView: User email: ${user.email}');
                  print(' ProfileView: User phone: ${user.phone}');
                }
                print(' ProfileView: AuthVM isLoggedIn: ${authVm.isLoggedIn}');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header matching requested layout
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed:
                                widget.onNavigateBack ??
                                () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context).t('my_profile'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () =>
                                Navigator.pushNamed(context, '/settings'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _CardShell(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await _showImageSourceSheet(
                                        context,
                                        authVm,
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 36,
                                      backgroundColor: kPrimary.withOpacity(
                                        .12,
                                      ),
                                      backgroundImage:
                                          user?.profileImage != null
                                          ? NetworkImage(user!.profileImage!)
                                          : null,
                                      child: user?.profileImage == null
                                          ? Icon(
                                              Icons.person_rounded,
                                              color: kPrimary,
                                              size: 36,
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    right: -6,
                                    bottom: -6,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        padding: const EdgeInsets.all(6),
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          size: 18,
                                          color: Color(0xFFF57C00),
                                        ),
                                        onPressed: () => _showImageSourceSheet(
                                          context,
                                          authVm,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (user != null)
                                ElevatedButton(
                                  onPressed: () async {
                                    final nameController =
                                        TextEditingController(text: user.name);
                                    final phoneController =
                                        TextEditingController(text: user.phone);

                                    await showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(
                                          AppLocalizations.of(
                                            ctx,
                                          ).t('edit_profile'),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: nameController,
                                              decoration: InputDecoration(
                                                labelText: AppLocalizations.of(
                                                  ctx,
                                                ).t('full_name'),
                                              ),
                                            ),
                                            TextField(
                                              controller: phoneController,
                                              decoration: InputDecoration(
                                                labelText: AppLocalizations.of(
                                                  ctx,
                                                ).t('phone'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              try {
                                                await authVm.updateProfile(
                                                  name: nameController.text,
                                                  phone: phoneController.text,
                                                );
                                                if (!mounted) return;
                                                Navigator.of(ctx).pop();
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      ).t('profile_updated'),
                                                    ),
                                                  ),
                                                );
                                                setState(() {});
                                              } catch (e) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Update failed: $e',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              AppLocalizations.of(
                                                ctx,
                                              ).t('edit_profile'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2196F3),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).t('edit_profile'),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: user == null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Not Logged In',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Please sign in to view and manage your profile',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            Navigator.pushReplacementNamed(
                                              context,
                                              '/login',
                                            ),
                                        icon: const Icon(Icons.login, size: 18),
                                        label: const Text('Sign In'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kPrimary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              (user.name.isNotEmpty
                                                  ? user.name
                                                  : (user.email.isNotEmpty
                                                        ? user.email.split(
                                                            '@',
                                                          )[0]
                                                        : 'User')),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (user.isEmailVerified)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.green.shade200,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.verified,
                                                    size: 12,
                                                    color:
                                                        Colors.green.shade700,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    'Verified',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.green.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.email_outlined,
                                            size: 14,
                                            color: kPrimary,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              user.email,
                                              style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (user.phone.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone_outlined,
                                              size: 14,
                                              color: kPrimary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              user.phone,
                                              style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (user.createdAt != null) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Joined ${_formatDate(user.createdAt!)}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const SizedBox(height: 16),

                    if (user != null)
                      _CardShell(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.person_outline,
                              label: 'Full Name',
                              value: user.name.isNotEmpty
                                  ? user.name
                                  : 'Not set',
                              primary: kPrimary,
                            ),
                            const Divider(height: 20),
                            _InfoRow(
                              icon: Icons.email_outlined,
                              label: 'Email Address',
                              value: user.email,
                              primary: kPrimary,
                              trailing: user.isEmailVerified
                                  ? Icon(
                                      Icons.verified,
                                      size: 18,
                                      color: Colors.green.shade600,
                                    )
                                  : null,
                            ),
                            const Divider(height: 20),
                            _InfoRow(
                              icon: Icons.phone_outlined,
                              label: 'Phone Number',
                              value: user.phone.isNotEmpty
                                  ? user.phone
                                  : 'Not set',
                              primary: kPrimary,
                            ),
                            if (user.createdAt != null) ...[
                              const Divider(height: 20),
                              _InfoRow(
                                icon: Icons.calendar_today_outlined,
                                label: 'Member Since',
                                value: _formatFullDate(user.createdAt!),
                                primary: kPrimary,
                              ),
                            ],
                            if (user.addresses != null &&
                                user.addresses!.isNotEmpty) ...[
                              const Divider(height: 20),
                              _InfoRow(
                                icon: Icons.location_on_outlined,
                                label: 'Saved Addresses',
                                value: '${user.addresses!.length} address(es)',
                                primary: kPrimary,
                              ),
                            ],
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Menu
                    _CardShell(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: Text(
                              AppLocalizations.of(context).t('language'),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _languageLabel(
                                    Provider.of<LocaleService>(
                                      context,
                                    ).locale.languageCode,
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            onTap: () => _showLanguagePicker(context),
                          ),
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('Account Details'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AccountDetailsScreen.routeName,
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.location_on_rounded),
                            title: const Text('Manage Addresses'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                Navigator.pushNamed(context, '/addresses'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.map_rounded),
                            title: const Text('Location'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.pushNamed(
                              context,
                              MapScreen.routeName,
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: const Text('Help & Support'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                Navigator.pushNamed(context, '/support'),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('Log out'),
                            onTap: () async {
                              await Provider.of<AuthViewModel>(
                                context,
                                listen: false,
                              ).logout();
                              if (!mounted) return;
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            // Instruction card
            if (kDebugMode)
              _CardShell(
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: kPrimary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pull down to refresh data from server',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Card shell widget
class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Helper widget for info rows in profile section
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color primary;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.primary,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
