import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/database_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<bool> login(String username, String password) async {
    try {
      emit(AuthLoading());
      final user = await DatabaseService.instance.login(username, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
        return true;
      } else {
        emit(AuthUnauthenticated());
        return false;
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      return false;
    }
  }

  void logout() {
    emit(AuthUnauthenticated());
  }
}

