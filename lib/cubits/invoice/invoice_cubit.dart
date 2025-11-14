import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/invoice.dart';
import '../../services/database_service.dart';
import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  InvoiceCubit() : super(InvoiceInitial());

  Future<void> loadInvoices() async {
    try {
      emit(InvoiceLoading());
      final invoices = await DatabaseService.instance.getAllInvoices();
      emit(InvoiceLoaded(invoices));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> createInvoice(Invoice invoice) async {
    try {
      await DatabaseService.instance.insertInvoice(invoice);
      await loadInvoices();
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<List<Invoice>> getInvoicesByDateRange(
      DateTime start, DateTime end) async {
    return await DatabaseService.instance.getInvoicesByDateRange(start, end);
  }
}

