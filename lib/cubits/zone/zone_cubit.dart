import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/zone.dart';
import '../../services/database_service.dart';
import 'zone_state.dart';

class ZoneCubit extends Cubit<ZoneState> {
  ZoneCubit() : super(ZoneInitial());

  Future<void> loadZones() async {
    try {
      emit(ZoneLoading());
      final zones = await DatabaseService.instance.getAllZones();
      emit(ZoneLoaded(zones));
    } catch (e) {
      emit(ZoneError(e.toString()));
    }
  }

  Future<void> loadActiveZones() async {
    try {
      emit(ZoneLoading());
      final zones = await DatabaseService.instance.getActiveZones();
      emit(ZoneLoaded(zones));
    } catch (e) {
      emit(ZoneError(e.toString()));
    }
  }

  Future<void> addZone(Zone zone) async {
    try {
      await DatabaseService.instance.insertZone(zone);
      await loadZones();
    } catch (e) {
      emit(ZoneError(e.toString()));
    }
  }

  Future<void> updateZone(Zone zone) async {
    try {
      await DatabaseService.instance.updateZone(zone);
      await loadZones();
    } catch (e) {
      emit(ZoneError(e.toString()));
    }
  }

  Future<void> deleteZone(String id) async {
    try {
      await DatabaseService.instance.deleteZone(id);
      await loadZones();
    } catch (e) {
      emit(ZoneError(e.toString()));
    }
  }
}

