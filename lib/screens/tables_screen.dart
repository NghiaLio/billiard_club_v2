import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/table/table_cubit.dart';
import '../cubits/table/table_state.dart';
import '../cubits/zone/zone_cubit.dart';
import '../cubits/zone/zone_state.dart';
import '../models/billiard_table.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/desktop_dialog.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  String _filterStatus = 'all';
  String _filterZone = 'all';

  @override
  void initState() {
    super.initState();
    context.read<ZoneCubit>().loadActiveZones();
  }

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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
            ),
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
              child: Row(
                children: [
                  // Status filter
                  Expanded(
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
                            onTap: () =>
                                setState(() => _filterStatus = 'available'),
                          ),
                          const SizedBox(width: AppSizes.paddingSmall),
                          _FilterChip(
                            label: 'Đang chơi',
                            isSelected: _filterStatus == 'occupied',
                            color: AppColors.danger,
                            onTap: () =>
                                setState(() => _filterStatus = 'occupied'),
                          ),
                          const SizedBox(width: AppSizes.paddingSmall),
                          _FilterChip(
                            label: 'Đã đặt',
                            isSelected: _filterStatus == 'reserved',
                            color: AppColors.warning,
                            onTap: () =>
                                setState(() => _filterStatus = 'reserved'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  // Zone filter dropdown
                  BlocBuilder<ZoneCubit, ZoneState>(
                    builder: (context, zoneState) {
                      final zones = zoneState is ZoneLoaded
                          ? zoneState.zones
                          : [];
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _filterZone,
                          underline: const SizedBox.shrink(),
                          icon: const Icon(Icons.arrow_drop_down, size: 20),
                          style: AppTextStyles.roboto(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'all',
                              child: Text('Tất cả khu vực'),
                            ),
                            ...zones.map((zone) => DropdownMenuItem(
                                  value: zone.name,
                                  child: Text(zone.name),
                                )),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _filterZone = value);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Tables grid
            Expanded(
              child: BlocBuilder<TableCubit, TableState>(
                builder: (context, state) {
                  if (state is! TableLoaded) return const SizedBox();
                  var tables = state.tables;

                  // Apply status filter
                  if (_filterStatus != 'all') {
                    tables = tables
                        .where((t) => t.status == _filterStatus)
                        .toList();
                  }

                  // Apply zone filter
                  if (_filterZone != 'all') {
                    tables = tables.where((t) => t.zone == _filterZone).toList();
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
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
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
                        onEdit: tables[index].status == 'available'
                            ? () => _showEditTableDialog(context, tables[index])
                            : null,
                        onDelete: tables[index].status == 'available'
                            ? () => _confirmDeleteTable(context, tables[index])
                            : null,
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
    String tableType = TableTypes.types.first;
    String zone = TableZones.zones.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DesktopDialog(
          title: 'Thêm bàn mới',
          maxWidth: 500,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên bàn *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              DropdownButtonFormField<String>(
                value: tableType,
                decoration: const InputDecoration(
                  labelText: 'Thương hiệu *',
                  border: OutlineInputBorder(),
                ),
                items: TableTypes.types
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => tableType = value!);
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              DropdownButtonFormField<String>(
                value: zone,
                decoration: const InputDecoration(
                  labelText: 'Khu vực *',
                  border: OutlineInputBorder(),
                ),
                items: TableZones.zones
                    .map((z) => DropdownMenuItem(
                          value: z,
                          child: Text(z),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => zone = value!);
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá/giờ (VNĐ) *',
                  border: OutlineInputBorder(),
                ),
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
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  final table = BilliardTable(
                    id: const Uuid().v4(),
                    tableName: nameController.text,
                    tableType: tableType,
                    zone: zone,
                    pricePerHour: double.parse(priceController.text),
                  );

                  await context.read<TableCubit>().addTable(table);

                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTableDialog(BuildContext context, BilliardTable table) {
    final nameController = TextEditingController(text: table.tableName);
    final priceController = TextEditingController(
      text: table.pricePerHour.toString(),
    );
    String tableType = table.tableType;
    String zone = table.zone;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DesktopDialog(
          title: 'Sửa thông tin bàn',
          maxWidth: 500,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên bàn *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              DropdownButtonFormField<String>(
                value: tableType,
                decoration: const InputDecoration(
                  labelText: 'Thương hiệu *',
                  border: OutlineInputBorder(),
                ),
                items: TableTypes.types
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => tableType = value!);
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              DropdownButtonFormField<String>(
                value: zone,
                decoration: const InputDecoration(
                  labelText: 'Khu vực *',
                  border: OutlineInputBorder(),
                ),
                items: TableZones.zones
                    .map((z) => DropdownMenuItem(
                          value: z,
                          child: Text(z),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => zone = value!);
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá/giờ (VNĐ) *',
                  border: OutlineInputBorder(),
                ),
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
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  final updatedTable = BilliardTable(
                    id: table.id,
                    tableName: nameController.text,
                    tableType: tableType,
                    zone: zone,
                    pricePerHour: double.parse(priceController.text),
                  );

                  await context.read<TableCubit>().updateTable(updatedTable);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật bàn thành công'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTable(BuildContext context, BilliardTable table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa ${table.tableName}?\n\n'
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<TableCubit>().deleteTable(table.id);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Xóa bàn thành công'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showReserveTableDialog(BuildContext context, BilliardTable table) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => DesktopDialog(
        title: 'Đặt ${table.tableName}',
        maxWidth: 500,
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên khách hàng hoặc SĐT *',
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
                await context.read<TableCubit>().reserveTable(
                  table.id,
                  nameController.text,
                );

                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
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
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TableCard({
    required this.table,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = TableStatus.getStatusColor(table.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header với tên và menu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      table.tableName,
                      style: AppTextStyles.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      TableStatus.getStatusText(table.status),
                      style: AppTextStyles.roboto(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Sửa'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: AppColors.danger,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Xóa',
                                  style: TextStyle(color: AppColors.danger),
                                ),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                    ),
                ],
              ),
            ),
            // Hình ảnh bàn bida với thông tin overlay
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Hình ảnh bàn bida
                    ColorFiltered(
                      colorFilter: table.status == 'available'
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            )
                          : ColorFilter.mode(
                              Colors.grey.withOpacity(0.5),
                              BlendMode.saturation,
                            ),
                      child: Image.asset(
                        'assets/images/download.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Overlay tối cho bàn đang dùng
                    if (table.status != 'available')
                      Container(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    // Thông tin ở giữa bàn
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (table.status == 'occupied' &&
                                table.startTime != null) ...[
                              Text(
                                AppFormatters.formatDuration(
                                  table.playingDuration,
                                ),
                                style: AppTextStyles.roboto(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppFormatters.formatCurrency(table.currentCost),
                                style: AppTextStyles.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ] else ...[
                              Text(
                                table.tableType.toUpperCase(),
                                style: AppTextStyles.roboto(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppFormatters.formatCurrency(table.pricePerHour),
                                style: AppTextStyles.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '/giờ',
                                style: AppTextStyles.roboto(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
