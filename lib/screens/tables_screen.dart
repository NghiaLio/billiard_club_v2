import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/table/table_cubit.dart';
import '../cubits/table/table_state.dart';
import '../models/billiard_table.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý bàn',
          style: AppTextStyles.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: ElevatedButton.icon(
              onPressed: () => _showAddTableDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Thêm bàn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            // Filter tabs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Tất cả',
                      isSelected: _filterStatus == 'all',
                      onTap: () => setState(() => _filterStatus = 'all'),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    _FilterChip(
                      label: 'Trống',
                      isSelected: _filterStatus == 'available',
                      color: AppColors.success,
                      onTap: () => setState(() => _filterStatus = 'available'),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    _FilterChip(
                      label: 'Đang chơi',
                      isSelected: _filterStatus == 'occupied',
                      color: AppColors.danger,
                      onTap: () => setState(() => _filterStatus = 'occupied'),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    _FilterChip(
                      label: 'Đã đặt',
                      isSelected: _filterStatus == 'reserved',
                      color: AppColors.warning,
                      onTap: () => setState(() => _filterStatus = 'reserved'),
                    ),
                  ],
                ),
              ),
            ),
            // Tables grid
            Expanded(
              child: BlocBuilder<TableCubit, TableState>(
                builder: (context, state) {
                  if (state is! TableLoaded) return const SizedBox();
                  var tables = state.tables;

                  if (_filterStatus != 'all') {
                    tables = tables.where((t) => t.status == _filterStatus).toList();
                  }

                  if (tables.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.table_bar,
                            size: 80,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          Text(
                            'Không có bàn nào',
                            style: AppTextStyles.roboto(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 280,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: AppSizes.paddingMedium,
                      mainAxisSpacing: AppSizes.paddingMedium,
                    ),
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      return _TableCard(
                        table: tables[index],
                        onTap: () => _showTableActions(context, tables[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTableActions(BuildContext context, BilliardTable table) {
    final tableProvider = context.read<TableCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              table.tableName,
              style: AppTextStyles.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              '${AppFormatters.formatCurrency(table.pricePerHour)}/giờ',
              style: AppTextStyles.roboto(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            if (table.status == 'available') ...[
              ElevatedButton.icon(
                onPressed: () async {
                  await tableProvider.openTable(table.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mở bàn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showReserveTableDialog(context, table);
                },
                icon: const Icon(Icons.bookmark),
                label: const Text('Đặt bàn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                ),
              ),
            ] else if (table.status == 'occupied') ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Column(
                  children: [
                    Text(
                      'Thời gian chơi',
                      style: AppTextStyles.roboto(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      AppFormatters.formatDuration(table.playingDuration),
                      style: AppTextStyles.roboto(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      'Chi phí hiện tại: ${AppFormatters.formatCurrency(table.currentCost)}',
                      style: AppTextStyles.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  // Navigate to cashier screen for checkout
                },
                icon: const Icon(Icons.payment),
                label: const Text('Thanh toán'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                ),
              ),
            ] else if (table.status == 'reserved') ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Column(
                  children: [
                    Text(
                      'Đặt bởi: ${table.reservedBy ?? "N/A"}',
                      style: AppTextStyles.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (table.reservationTime != null) ...[
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        'Lúc: ${AppFormatters.formatDateTime(table.reservationTime!)}',
                        style: AppTextStyles.roboto(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              ElevatedButton.icon(
                onPressed: () async {
                  await tableProvider.openTable(table.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Bắt đầu chơi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              ElevatedButton.icon(
                onPressed: () async {
                  await tableProvider.cancelReservation(table.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Hủy đặt bàn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.paddingMedium),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTableDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String tableType = 'pool';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm bàn mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên bàn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              DropdownButtonFormField<String>(
                value: tableType,
                decoration: const InputDecoration(
                  labelText: 'Loại bàn',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pool', child: Text('Pool')),
                  DropdownMenuItem(value: 'snooker', child: Text('Snooker')),
                  DropdownMenuItem(value: 'carom', child: Text('Carom')),
                ],
                onChanged: (value) => tableType = value!,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá/giờ (VNĐ)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                final table = BilliardTable(
                  id: const Uuid().v4(),
                  tableName: nameController.text,
                  tableType: tableType,
                  pricePerHour: double.parse(priceController.text),
                );

                await context.read<TableCubit>()
                    .addTable(table);

                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showReserveTableDialog(BuildContext context, BilliardTable table) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đặt ${table.tableName}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên khách hàng hoặc SĐT',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await context.read<TableCubit>()
                    .reserveTable(table.id, nameController.text);

                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Đặt bàn'),
          ),
        ],
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  final BilliardTable table;
  final VoidCallback onTap;

  const _TableCard({
    required this.table,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = TableStatus.getStatusColor(table.status);

    return Card(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        side: BorderSide(
          color: statusColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      table.tableName,
                      style: AppTextStyles.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      TableStatus.getStatusText(table.status),
                      style: AppTextStyles.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Text(
                table.tableType.toUpperCase(),
                style: AppTextStyles.roboto(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              // Icon
              Icon(
                Icons.table_bar,
                size: 64,
                color: statusColor.withOpacity(0.3),
              ),
              const Spacer(),
              // Price and Info
              if (table.status == 'occupied' && table.startTime != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppFormatters.formatDuration(table.playingDuration),
                        style: AppTextStyles.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.formatCurrency(table.currentCost),
                        style: AppTextStyles.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  '${AppFormatters.formatCurrency(table.pricePerHour)}/giờ',
                  style: AppTextStyles.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

