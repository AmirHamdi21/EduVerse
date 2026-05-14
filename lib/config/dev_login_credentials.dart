import 'dev_login_credentials.local.dart';

class DevLoginCredential {
  const DevLoginCredential({
    required this.roleKey,
    required this.labelEn,
    required this.labelAr,
    required this.email,
    required this.password,
  });

  final String roleKey;
  final String labelEn;
  final String labelAr;
  final String email;
  final String password;

  String labelFor(String languageCode) {
    return languageCode == 'ar' ? labelAr : labelEn;
  }
}

class DevLoginCredentials {
  const DevLoginCredentials._();

  static List<DevLoginCredential> get all {
    return LocalDevLoginCredentials.accounts
        .map(
          (account) => DevLoginCredential(
            roleKey: account['roleKey'] ?? '',
            labelEn: account['labelEn'] ?? '',
            labelAr: account['labelAr'] ?? '',
            email: account['email'] ?? '',
            password: account['password'] ?? '',
          ),
        )
        .where((account) => account.email.isNotEmpty)
        .toList(growable: false);
  }
}
