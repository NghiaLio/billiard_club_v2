import 'package:equatable/equatable.dart';
import '../../models/invoice.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<Invoice> invoices;

  const InvoiceLoaded(this.invoices);

  double getTotalRevenue() {
    return invoices.fold(0, (sum, invoice) => sum + invoice.totalAmount);
  }

  double getRevenueByDateRange(DateTime start, DateTime end) {
    return invoices
        .where((invoice) =>
            invoice.createdAt.isAfter(start) &&
            invoice.createdAt.isBefore(end))
        .fold(0, (sum, invoice) => sum + invoice.totalAmount);
  }

  double getTodayRevenue() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getRevenueByDateRange(startOfDay, endOfDay);
  }

  double getThisMonthRevenue() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    return getRevenueByDateRange(startOfMonth, endOfMonth);
  }

  int getTodayInvoiceCount() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return invoices.where((invoice) => invoice.createdAt.isAfter(startOfDay)).length;
  }

  @override
  List<Object?> get props => [invoices];
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object?> get props => [message];
}

