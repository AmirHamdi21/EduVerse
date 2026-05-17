import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import 'shared_settings_role.dart';

class SettingsRoleResolver {
  const SettingsRoleResolver._();

  static SharedSettingsRole fromQuery(String? role) {
    return SharedSettingsRoleX.fromRaw(role);
  }

  static SharedSettingsRole inferFromContext(BuildContext context) {
    try {
      final profileState = context.read<ProfileCubit>().state;
      if (profileState is ProfileLoaded) {
        return SharedSettingsRoleX.fromRaw(
          profileState.profile.primaryRoleName,
        );
      }
    } catch (_) {
      // Some isolated route tests do not install the app-level profile cubit.
    }

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        return SharedSettingsRoleX.fromRaw(authState.user.primaryRoleName);
      }
    } catch (_) {
      // Fall through to the public student settings style.
    }

    return SharedSettingsRole.student;
  }

  static SharedSettingsRole fromQueryOrContext(
    BuildContext context,
    String? role,
  ) {
    if (role != null && role.trim().isNotEmpty) {
      return fromQuery(role);
    }
    return inferFromContext(context);
  }
}
