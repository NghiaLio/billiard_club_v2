import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/table/table_cubit.dart';
import '../cubits/table/table_state.dart';
import '../cubits/product/product_cubit.dart';
import '../cubits/product/product_state.dart';
import '../cubits/order/order_cubit.dart';
import '../cubits/order/order_state.dart';
import '../cubits/member/member_cubit.dart';
import '../cubits/member/member_state.dart';
import '../cubits/invoice/invoice_cubit.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../models/billiard_table.dart';
import '../models/member.dart';
import '../models/invoice.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  BilliardTable? _selectedTable;
  Member? _selectedMember;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thu ngân',
          style: AppTextStyles.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Container(
        color: AppColors.background,
        child: Row(
          children: [
            // Left side - Table and Member selection
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Table selection
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Chọn bàn',
                          style: AppTextStyles.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        BlocBuilder<TableCubit, TableState>(
                          builder: (context, state) {
                            final occupiedTables = state is TableLoaded ? state.occupiedTables : [];
                            return DropdownButtonFormField<BilliardTable>(
                              value: _selectedTable,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Chọn bàn đang chơi...',
                              ),
                              items: occupiedTables.map((table) {
                                return DropdownMenuItem<BilliardTable>(
                                  value: table,
                                  child: Text('${table.tableName} - ${AppFormatters.formatDuration(table.playingDuration)}'),
                                );
                              }).toList(),
                              onChanged: (table) {
                                setState(() {
                                  _selectedTable = table;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Member selection (optional)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Thành viên (tùy chọn)',
                              style: AppTextStyles.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_selectedMember != null)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedMember = null;
                                  });
                                },
                                child: const Text('Xóa'),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        BlocBuilder<MemberCubit, MemberState>(
                          builder: (context, state) {
                            final activeMembers = state is MemberLoaded ? state.activeMembers : [];
                            return DropdownButtonFormField<Member>(
                              value: _selectedMember,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Chọn thành viên...',
                              ),
                              items: activeMembers.map((member) {
                                return DropdownMenuItem<Member>(
                                  value: member,
                                  child: Text('${member.fullName} - ${member.phone}'),
                                );
                              }).toList(),
                              onChanged: (member) {
                                setState(() {
                                  _selectedMember = member;
                                });
                              },
                            );
                          },
                        ),
                        if (_selectedMember != null) ...[
                          const SizedBox(height: AppSizes.paddingSmall),
                          Container(
                            padding: const EdgeInsets.all(AppSizes.paddingSmall),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Giảm giá: ${_selectedMember!.discountRate.toStringAsFixed(0)}% (${MembershipTypes.getTypeName(_selectedMember!.membershipType)})',
                              style: AppTextStyles.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Products grid
                  Expanded(
                    child: BlocBuilder<ProductCubit, ProductState>(
                      builder: (context, state) {
                        final products = state is ProductLoaded ? state.availableProducts : [];

                        if (products.isEmpty) {
                          return const Center(
                            child: Text('Không có sản phẩm nào'),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(AppSizes.paddingMedium),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 150,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: AppSizes.paddingSmall,
                            mainAxisSpacing: AppSizes.paddingSmall,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return _ProductItem(
                              product: product,
                              onTap: () {
                                if (_selectedTable == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Vui lòng chọn bàn trước'),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                  return;
                                }
                                context.read<OrderCubit>()
                                    .addItemToOrder(
                                  _selectedTable!.id,
                                  product,
                                  1,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Right side - Order details and checkout
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.white,
                child: _selectedTable == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 80,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: AppSizes.paddingMedium),
                            Text(
                              'Chọn bàn để bắt đầu',
                              style: AppTextStyles.roboto(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildCheckoutPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutPanel() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final orderItems = state.getOrderItemsForTable(_selectedTable!.id);
        final orderTotal = state.getOrderTotalForTable(_selectedTable!.id);

        // Calculate table charges
        final playingHours = _selectedTable!.playingDuration;
        final tableCharge = _selectedTable!.currentCost;

        // Calculate subtotal
        final subtotal = tableCharge + orderTotal;

        // Calculate discount
        final discountRate = _selectedMember?.discountRate ?? 0;
        final discount = subtotal * (discountRate / 100);

        // Calculate tax (if applicable)
        final tax = 0.0;

        // Calculate total
        final total = subtotal - discount + tax;

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _selectedTable!.tableName,
                    style: AppTextStyles.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Thời gian: ${AppFormatters.formatDuration(playingHours)}',
                    style: AppTextStyles.roboto(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Order items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                children: [
                  // Table charge
                  _BillItem(
                    label: 'Tiền bàn',
                    value: AppFormatters.formatCurrency(tableCharge),
                    isHeader: true,
                  ),
                  const Divider(),
                  // Order items
                  if (orderItems != null && orderItems.isNotEmpty) ...[
                    _BillItem(
                      label: 'Đồ ăn & uống',
                      value: '',
                      isHeader: true,
                    ),
                    ...orderItems.map((item) {
                      return _OrderItemTile(
                        item: item,
                        onQuantityChanged: (newQty) {
                          context.read<OrderCubit>().updateItemQuantity(
                            _selectedTable!.id,
                            item.id,
                            newQty,
                          );
                        },
                        onRemove: () {
                          context.read<OrderCubit>().removeItemFromOrder(
                            _selectedTable!.id,
                            item.id,
                          );
                        },
                      );
                    }),
                    const Divider(),
                  ],
                ],
              ),
            ),
            // Summary
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Column(
                children: [
                  _BillItem(
                    label: 'Tạm tính',
                    value: AppFormatters.formatCurrency(subtotal),
                  ),
                  if (discount > 0) ...[
                    const SizedBox(height: 4),
                    _BillItem(
                      label: 'Giảm giá (${discountRate.toStringAsFixed(0)}%)',
                      value: '-${AppFormatters.formatCurrency(discount)}',
                      valueColor: AppColors.success,
                    ),
                  ],
                  if (tax > 0) ...[
                    const SizedBox(height: 4),
                    _BillItem(
                      label: 'Thuế',
                      value: AppFormatters.formatCurrency(tax),
                    ),
                  ],
                  const Divider(thickness: 2),
                  _BillItem(
                    label: 'TỔNG CỘNG',
                    value: AppFormatters.formatCurrency(total),
                    isTotal: true,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  ElevatedButton(
                    onPressed: () => _showPaymentDialog(
                      context,
                      _selectedTable!,
                      orderItems ?? [],
                      tableCharge,
                      orderTotal,
                      subtotal,
                      discount,
                      tax,
                      total,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.paddingMedium,
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      'THANH TOÁN',
                      style: AppTextStyles.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    BilliardTable table,
    List orderItems,
    double tableCharge,
    double orderTotal,
    double subtotal,
    double discount,
    double tax,
    double total,
  ) {
    String paymentMethod = 'cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Xác nhận thanh toán'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppFormatters.formatCurrency(total),
                style: AppTextStyles.roboto(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              const Text('Phương thức thanh toán:'),
              const SizedBox(height: AppSizes.paddingSmall),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'cash',
                    child: Text(PaymentMethods.getMethodName('cash')),
                  ),
                  DropdownMenuItem(
                    value: 'card',
                    child: Text(PaymentMethods.getMethodName('card')),
                  ),
                  DropdownMenuItem(
                    value: 'online',
                    child: Text(PaymentMethods.getMethodName('online')),
                  ),
                ],
                onChanged: (value) {
                  setState(() => paymentMethod = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _processPayment(
                  context,
                  table,
                  paymentMethod,
                  tableCharge,
                  orderTotal,
                  subtotal,
                  discount,
                  tax,
                  total,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('XÁC NHẬN'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(
    BuildContext context,
    BilliardTable table,
    String paymentMethod,
    double tableCharge,
    double orderTotal,
    double subtotal,
    double discount,
    double tax,
    double total,
  ) async {
    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state;
    
    String createdById = '';
    if (authState is AuthAuthenticated) {
      createdById = authState.user.id;
    }

    // Create invoice
    final invoice = Invoice(
      id: const Uuid().v4(),
      tableId: table.id,
      tableName: table.tableName,
      memberId: _selectedMember?.id,
      memberName: _selectedMember?.fullName,
      startTime: table.startTime!,
      endTime: DateTime.now(),
      playingHours: table.playingDuration,
      tableCharge: tableCharge,
      orderTotal: orderTotal,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      totalAmount: total,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      createdBy: createdById,
    );

    // Save invoice
    await context.read<InvoiceCubit>().createInvoice(invoice);

    // Save order if exists
    final orderState = context.read<OrderCubit>().state;
    if (orderState.getOrderItemsForTable(table.id) != null) {
      await context.read<OrderCubit>().saveOrder(table.id, table.currentSessionId!);
    }

    // Close table
    await context.read<TableCubit>().closeTable(table.id);

    // Clear order
    context.read<OrderCubit>().clearOrderForTable(table.id);

    if (context.mounted) {
      Navigator.pop(context); // Close payment dialog
      setState(() {
        _selectedTable = null;
        _selectedMember = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanh toán thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

class _ProductItem extends StatelessWidget {
  final dynamic product;
  final VoidCallback onTap;

  const _ProductItem({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ProductCategories.getCategoryIcon(product.category),
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Text(
                product.name,
                style: AppTextStyles.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                AppFormatters.formatCurrency(product.price),
                style: AppTextStyles.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final dynamic item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _OrderItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTextStyles.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  AppFormatters.formatCurrency(item.price),
                  style: AppTextStyles.roboto(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () => onQuantityChanged(item.quantity - 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Container(
                width: 30,
                alignment: Alignment.center,
                child: Text(
                  '${item.quantity}',
                  style: AppTextStyles.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => onQuantityChanged(item.quantity + 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              AppFormatters.formatCurrency(item.subtotal),
              style: AppTextStyles.roboto(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: AppColors.danger),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _BillItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isHeader;
  final bool isTotal;
  final Color? valueColor;

  const _BillItem({
    required this.label,
    required this.value,
    this.isHeader = false,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.roboto(
              fontSize: isTotal ? 18 : (isHeader ? 16 : 14),
              fontWeight: isTotal || isHeader ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: AppTextStyles.roboto(
                fontSize: isTotal ? 20 : (isHeader ? 16 : 14),
                fontWeight: isTotal || isHeader ? FontWeight.bold : FontWeight.normal,
                color: valueColor ??
                    (isTotal ? AppColors.success : AppColors.textPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

