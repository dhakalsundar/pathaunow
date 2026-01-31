import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pathau_now/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pathau_now/core/utils/app_utils.dart';
import 'package:pathau_now/core/localization/app_localizations.dart';

class AccountDetailsScreen extends StatelessWidget {
  static const String routeName = '/account';
  const AccountDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final user = authVm.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('account_details')),
        backgroundColor: const Color(0xFFF57C00),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? Center(
                child: Text(AppLocalizations.of(context).t('not_signed_in')),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: user.profileImage != null
                          ? NetworkImage(user.profileImage!)
                          : null,
                      child: user.profileImage == null
                          ? const Icon(Icons.person_rounded)
                          : null,
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(user.email),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context).t('full_name'),
                          ),
                          subtitle: Text(user.name),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(AppLocalizations.of(context).t('email')),
                          subtitle: Text(user.email),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(AppLocalizations.of(context).t('phone')),
                          subtitle: Text(user.phone),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context).t('logged_in_as'),
                          ),
                          subtitle: Text(
                            authVm.loginIdentifierUsed ?? user.email,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('User ID'),
                          subtitle: Text(user.id),
                        ),
                        const Divider(height: 1),
                        if (user.createdAt != null)
                          ListTile(
                            title: const Text('Signed up'),
                            subtitle: Text(
                              DateTimeUtils.formatDate(user.createdAt!),
                            ),
                          ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Email verified'),
                          subtitle: Text(user.isEmailVerified ? 'Yes' : 'No'),
                          trailing: Icon(
                            user.isEmailVerified
                                ? Icons.check_circle
                                : Icons.error_outline,
                            color: user.isEmailVerified
                                ? Colors.green
                                : Colors.orange,
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
