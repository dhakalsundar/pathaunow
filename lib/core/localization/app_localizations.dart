import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'my_profile': 'My Profile',
      'guest_user': 'Guest User',
      'sign_in_to_manage': 'Sign in to manage orders and addresses',
      'edit_profile': 'Edit Profile',
      'profile_updated': 'Profile updated',
      'profile_update_failed': 'Update failed',
      'language': 'Language',
      'language_set': 'Language set',
      'account_details': 'Account Details',
      'not_signed_in': 'Not signed in',
      'full_name': 'Full Name',
      'email': 'Email',
      'phone': 'Phone',
      'user_id': 'User ID',
      'signed_up': 'Signed up',
      'email_verified': 'Email verified',
      'logged_in_as': 'Logged in as',
      'yes': 'Yes',
      'no': 'No',
    },
    'ne': {
      'my_profile': 'मेरो प्रोफाइल',
      'guest_user': 'अतिथि प्रयोगकर्ता',
      'sign_in_to_manage': 'अर्डर र ठेगाना व्यवस्थापन गर्न लग इन गर्नुहोस्',
      'edit_profile': 'प्रोफाइल सम्पादन',
      'profile_updated': 'प्रोफाइल अपडेट गरियो',
      'profile_update_failed': 'अपडेट असफल',
      'language': 'भाषा',
      'language_set': 'भाषा सेट भयो',
      'account_details': 'खाताको विवरण',
      'not_signed_in': 'साइन इन गरिएको छैन',
      'full_name': 'पूरा नाम',
      'email': 'इमेल',
      'phone': 'फोन',
      'user_id': 'प्रयोगकर्ता ID',
      'signed_up': 'साइन अप मिति',
      'email_verified': 'इमेल प्रमाणित',
      'logged_in_as': 'लगइन भएको',
      'yes': 'हो',
      'no': 'होइन',
    },
  };

  String t(String key) {
    final code = locale.languageCode;
    return _localizedValues[code]?[key] ?? _localizedValues['en']![key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ne'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
