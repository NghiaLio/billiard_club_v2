import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/invoice.dart';

class InvoiceRepository {
  final Database database;

  InvoiceRepository(this.database);

  Future<void> insertInvoice(Invoice invoice) async {
    await database.insert('invoices', invoice.toMap());
  }

  Future<List<Invoice>> getAllInvoices() async {
    final result = await database.query('invoices', orderBy: 'created_at DESC');
    return result.map((map) => Invoice.fromMap(map)).toList();
  }

  Future<List<Invoice>> getInvoicesByDateRange(DateTime start, DateTime end) async {
    final result = await database.query(
      'invoices',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Invoice.fromMap(map)).toList();
  }
}

