import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../services/database_service.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  Future<void> loadUsers() async {
    try {
      emit(UserLoading());
      final users = await DatabaseService.instance.getAllUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> addUser(User user) async {
    try {
      await DatabaseService.instance.insertUser(user);
      await loadUsers();
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await DatabaseService.instance.updateUser(user);
      await loadUsers();
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await DatabaseService.instance.deleteUser(id);
      await loadUsers();
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}

