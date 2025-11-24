import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../models/billiard_table.dart';
import '../../services/database_service.dart';
import 'table_state.dart';

class TableCubit extends Cubit<TableState> {
  TableCubit() : super(TableInitial());

  List<BilliardTable> _tables = [];

  List<BilliardTable> get tables => _tables;

  Future<void> loadTables() async {
    await _syncTablesFromDatabase(showLoading: true);
  }

  Future<void> addTable(BilliardTable table) async {
    try {
      await DatabaseService.instance.insertTable(_stripRuntimeState(table));
      await _syncTablesFromDatabase();
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> updateTable(BilliardTable table) async {
    try {
      await DatabaseService.instance.updateTable(_stripRuntimeState(table));
      await _syncTablesFromDatabase();
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> deleteTable(String id) async {
    try {
      await DatabaseService.instance.deleteTable(id);
      _tables = _tables.where((table) => table.id != id).toList();
      await _syncTablesFromDatabase();
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> openTable(String tableId) async {
    final table = _findTableById(tableId);
    if (table == null) return;

    final sessionId = const Uuid().v4();
    final updatedTable = table.copyWith(
      status: 'occupied',
      startTime: DateTime.now(),
      currentSessionId: sessionId,
      reservedBy: null,
      reservationTime: null,
    );

    _applyInMemoryUpdate(updatedTable);
  }

  Future<void> closeTable(String tableId) async {
    final table = _findTableById(tableId);
    if (table == null) return;

    final updatedTable = table.copyWith(
      status: 'available',
      startTime: null,
      currentSessionId: null,
      reservedBy: null,
      reservationTime: null,
    );

    _applyInMemoryUpdate(updatedTable);
  }

  Future<void> reserveTable(String tableId, String reservedBy) async {
    final table = _findTableById(tableId);
    if (table == null) return;

    final updatedTable = table.copyWith(
      status: 'reserved',
      startTime: null,
      currentSessionId: null,
      reservedBy: reservedBy,
      reservationTime: DateTime.now(),
    );

    _applyInMemoryUpdate(updatedTable);
  }

  Future<void> cancelReservation(String tableId) async {
    final table = _findTableById(tableId);
    if (table == null) return;

    final updatedTable = table.copyWith(
      status: 'available',
      reservedBy: null,
      reservationTime: null,
      startTime: null,
      currentSessionId: null,
    );

    _applyInMemoryUpdate(updatedTable);
  }

  Future<void> resetAllTables() async {
    if (_tables.isEmpty) return;

    _tables = _tables
        .map(
          (table) => table.copyWith(
            status: 'available',
            startTime: null,
            currentSessionId: null,
            reservedBy: null,
            reservationTime: null,
          ),
        )
        .toList();

    emit(TableLoaded(List.unmodifiable(_tables)));
  }

  Future<void> _syncTablesFromDatabase({bool showLoading = false}) async {
    try {
      if (showLoading) {
        emit(TableLoading());
      }

      final dbTables = await DatabaseService.instance.getAllTables();
      final previousTables = _tables;

      final mergedTables = dbTables.map((table) {
        final runtime = _findTableIn(previousTables, table.id);
        if (runtime != null) {
          return table.copyWith(
            status: runtime.status,
            startTime: runtime.startTime,
            currentSessionId: runtime.currentSessionId,
            reservedBy: runtime.reservedBy,
            reservationTime: runtime.reservationTime,
          );
        }

        return table.copyWith(
          status: 'available',
          startTime: null,
          currentSessionId: null,
          reservedBy: null,
          reservationTime: null,
        );
      }).toList();

      _tables = mergedTables;
      emit(TableLoaded(List.unmodifiable(_tables)));
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  void _applyInMemoryUpdate(BilliardTable updatedTable) {
    final index = _tables.indexWhere((table) => table.id == updatedTable.id);
    if (index == -1) return;

    final updatedTables = List<BilliardTable>.from(_tables);
    updatedTables[index] = updatedTable;
    _tables = updatedTables;
    emit(TableLoaded(List.unmodifiable(_tables)));
  }

  BilliardTable? _findTableById(String id) {
    try {
      return _tables.firstWhere((table) => table.id == id);
    } catch (_) {
      return null;
    }
  }

  BilliardTable? _findTableIn(List<BilliardTable> source, String id) {
    try {
      return source.firstWhere((table) => table.id == id);
    } catch (_) {
      return null;
    }
  }

  BilliardTable _stripRuntimeState(BilliardTable table) {
    return BilliardTable(
      id: table.id,
      tableName: table.tableName,
      tableType: table.tableType,
      zone: table.zone,
      pricePerHour: table.pricePerHour,
    );
  }
}
