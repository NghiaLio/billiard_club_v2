import 'package:equatable/equatable.dart';
import '../../models/member.dart';

abstract class MemberState extends Equatable {
  const MemberState();

  @override
  List<Object?> get props => [];
}

class MemberInitial extends MemberState {}

class MemberLoading extends MemberState {}

class MemberLoaded extends MemberState {
  final List<Member> members;

  const MemberLoaded(this.members);

  List<Member> get activeMembers =>
      members.where((m) => m.isActive).toList();

  Member? getMemberById(String id) {
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Member> searchMembers(String query) {
    final lowerQuery = query.toLowerCase();
    return members.where((m) {
      return m.fullName.toLowerCase().contains(lowerQuery) ||
          m.phone.contains(query);
    }).toList();
  }

  @override
  List<Object?> get props => [members];
}

class MemberError extends MemberState {
  final String message;

  const MemberError(this.message);

  @override
  List<Object?> get props => [message];
}

