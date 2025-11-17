import '../../models/zone.dart';

abstract class ZoneState {}

class ZoneInitial extends ZoneState {}

class ZoneLoading extends ZoneState {}

class ZoneLoaded extends ZoneState {
  final List<Zone> zones;

  ZoneLoaded(this.zones);
}

class ZoneError extends ZoneState {
  final String message;

  ZoneError(this.message);
}

