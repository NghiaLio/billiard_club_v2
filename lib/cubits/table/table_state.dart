import 'package:equatable/equatable.dart';
import '../../models/billiard_table.dart';

abstract class TableState extends Equatable {
  const TableState();

  @override
  List<Object?> get props => [];
}

class TableInitial extends TableState {}

class TableLoading extends TableState {}

class TableLoaded extends TableState {
  final List<BilliardTable> tables;

  const TableLoaded(this.tables);

  List<BilliardTable> get availableTables =>
      tables.where((t) => t.status == 'available').toList();

  List<BilliardTable> get occupiedTables =>
      tables.where((t) => t.status == 'occupied').toList();

  List<BilliardTable> get reservedTables =>
      tables.where((t) => t.status == 'reserved').toList();

  BilliardTable? getTableById(String id) {
    try {
      return tables.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [tables];
}

class TableError extends TableState {
  final String message;

  const TableError(this.message);

  @override
  List<Object?> get props => [message];
}

