import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../models/billiard_table.dart';
import '../../services/database_service.dart';
import 'table_state.dart';

class TableCubit extends Cubit<TableState> {
  TableCubit() : super(TableInitial());

  Future<void> loadTables() async {
    try {
      emit(TableLoading());
      final tables = await DatabaseService.instance.getAllTables();
      emit(TableLoaded(tables));
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> addTable(BilliardTable table) async {
    try {
      await DatabaseService.instance.insertTable(table);
      await loadTables();
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> updateTable(BilliardTable table) async {
    try {
      await DatabaseService.instance.updateTable(table);
      await loadTables();
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> deleteTable(String id) async {
    try {
      await DatabaseService.instance.deleteTable(id);
      await loadTables();
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> openTable(String tableId) async {
    try {
      final currentState = state;
      if (currentState is! TableLoaded) return;

      final table = currentState.getTableById(tableId);
      if (table == null) return;

      final sessionId = const Uuid().v4();
      final updatedTable = table.copyWith(
        status: 'occupied',
        startTime: DateTime.now(),
        currentSessionId: sessionId,
      );

      await updateTable(updatedTable);
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> closeTable(String tableId) async {
    try {
      final currentState = state;
      if (currentState is! TableLoaded) return;

      final table = currentState.getTableById(tableId);
      if (table == null) return;

      final updatedTable = table.copyWith(
        status: 'available',
        startTime: null,
        currentSessionId: null,
      );

      await updateTable(updatedTable);
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> reserveTable(String tableId, String reservedBy) async {
    try {
      final currentState = state;
      if (currentState is! TableLoaded) return;

      final table = currentState.getTableById(tableId);
      if (table == null) return;

      final updatedTable = table.copyWith(
        status: 'reserved',
        reservedBy: reservedBy,
        reservationTime: DateTime.now(),
      );

      await updateTable(updatedTable);
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> cancelReservation(String tableId) async {
    try {
      final currentState = state;
      if (currentState is! TableLoaded) return;

      final table = currentState.getTableById(tableId);
      if (table == null) return;

      final updatedTable = table.copyWith(
        status: 'available',
        reservedBy: null,
        reservationTime: null,
      );

      await updateTable(updatedTable);
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }
}

