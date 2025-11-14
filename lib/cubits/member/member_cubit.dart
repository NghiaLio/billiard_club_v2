import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/member.dart';
import '../../services/database_service.dart';
import 'member_state.dart';

class MemberCubit extends Cubit<MemberState> {
  MemberCubit() : super(MemberInitial());

  Future<void> loadMembers() async {
    try {
      emit(MemberLoading());
      final members = await DatabaseService.instance.getAllMembers();
      emit(MemberLoaded(members));
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> addMember(Member member) async {
    try {
      await DatabaseService.instance.insertMember(member);
      await loadMembers();
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> updateMember(Member member) async {
    try {
      await DatabaseService.instance.updateMember(member);
      await loadMembers();
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> deleteMember(String id) async {
    try {
      await DatabaseService.instance.deleteMember(id);
      await loadMembers();
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }
}

